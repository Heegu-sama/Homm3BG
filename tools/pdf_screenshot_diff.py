#!/usr/bin/env python3

"""
pdf_screenshot_diff.py

Compare two PDF documents using their internal structure.

Designed for layout changes such as:

    BEFORE                         AFTER

    Heading                        Heading
    Paragraph A                    Paragraph A
    Paragraph B                    NEW TEXT
    Paragraph C                    Paragraph B
                                   Paragraph C

Possible classifications:

    MOVED
    ADDED
    REMOVED

Usage:

    python pdf_screenshot_diff.py before.pdf after.pdf --output-dir dir

Dependencies:

    pip install pymupdf opencv-python numpy scikit-image
"""

from __future__ import annotations

from pathlib import Path
import re
import difflib

import argparse
from dataclasses import dataclass, field
from typing import Optional

import cv2
import numpy as np

import fitz  # PyMuPDF


# ============================================================
# Configuration
# ============================================================

@dataclass
class Config:
  pass

# ============================================================
# Visualization
# ============================================================

COLORS = {
    "moved":   (0, 90, 255),       # Blue
    #"changed": (255, 150, 0),      # Orange
    "added":   (0, 190, 0),        # Green
    "removed": (255, 0, 0),        # Red
}

COLORSFILL = { name: (b,g,r, 20) for name, (r,g,b) in COLORS.items()}
COLORSLINE = { name: (b,g,r, 255) for name, (r,g,b) in COLORS.items()}


# ============================================================
# Console output
# ============================================================

def print_results(
    result,
):

    classifications = result[
        "classifications"
    ]

    layout_shifts = result[
        "layout_shifts"
    ]

    counts = {}

    for item in classifications:

        counts[item.kind] = (
            counts.get(
                item.kind,
                0,
            )
            + 1
        )

    print()
    print("=" * 72)
    print("PDF SCREENSHOT DIFF")
    print("=" * 72)

    print()

    for kind in (
        "moved",
        "changed",
        "added",
        "removed",
    ):

        print(
            f"{kind.upper():10s}: "
            f"{counts.get(kind, 0)}"
        )

    print(
        f"{'LAYOUT SHIFT':10s}: "
        f"{len(layout_shifts)}"
    )

    print()
    print("-" * 72)

    for index, item in enumerate(
        classifications,
        start=1,
    ):

        if item.kind == "moved":

            print(
                f"MOVED #{index}: "
                f"region={item.region.bbox} "
                f"dx={item.dx:+.1f} "
                f"dy={item.dy:+.1f} "
                f"features={item.feature_count}"
            )

        elif item.kind == "changed":

            print(
                f"CHANGED #{index}: "
                f"region={item.region.bbox} "
                f"features={item.feature_count}"
            )

        elif item.kind == "added":

            print(
                f"ADDED #{index}: "
                f"region={item.region.bbox}"
            )

        elif item.kind == "removed":

            print(
                f"REMOVED #{index}: "
                f"region={item.region.bbox}"
            )

    if layout_shifts:

        print()
        print("-" * 72)
        print("LAYOUT SHIFTS")
        print("-" * 72)

    for index, shift in enumerate(
        layout_shifts,
        start=1,
    ):

        print(
            f"SHIFT #{index}: "
            f"dx={shift.dx:+.1f} "
            f"dy={shift.dy:+.1f} "
            f"regions={len(shift.regions)} "
            f"features={len(shift.features)} "
            f"confidence={shift.confidence:.3f}"
        )

    print()



# ============================================================
# PDF structural comparison
# ============================================================

@dataclass
class PDFObject:
    page: int
    kind: str
    text: str = ""
    bbox: tuple = (0, 0, 0, 0)
    font: str = ""
    size: float = 0.0
    color: tuple = ()
    number: int = 0
    spans: tuple = ()



def _norm_text(s: str) -> str:
    return re.sub(r"\s+", " ", s or "").strip()


def _merge_bboxes(spans):
            boxes = [
                span.get("bbox")
                for span in spans
                if span.get("bbox")
            ]
            bbox = (
                min(b[0] for b in boxes),
                min(b[1] for b in boxes),
                max(b[2] for b in boxes),
                max(b[3] for b in boxes),
            )
            return bbox



def extract_pdf_objects(path: str, pagenum:int):
    """Extract paragraph/block-level text plus vector/image objects from a PDF."""
    doc = fitz.open(path)
    pages = []

    for page_index, page in enumerate(doc):
      if page_index + 1 == pagenum:
        objects = []
        data = page.get_text("dict")

        # Treat each PDF text block as one semantic object. A PDF paragraph
        # may contain many lines and many spans; comparing spans/words causes
        # one MOVED result per word. Blocks give us a useful paragraph-level
        # unit without needing OCR.
        for block in data.get("blocks", []):
            if block.get("type") != 0:
                continue

            lines = block.get("lines", [])
            if not lines:
                continue

            text_lines = []
            spans = []

            for line in lines:
                line_spans = line.get("spans", [])
                line_text = "".join(
                    span.get("text", "") for span in line_spans
                ).strip()
                if line_text:
                    text_lines.append(line_text)
                spans.extend(line_spans)

            text_value = _norm_text(" ".join(text_lines))
            if not text_value or not spans:
                continue

            boxes = [
                span.get("bbox")
                for span in spans
                if span.get("bbox")
            ]
            if not boxes:
                continue

            bbox = (
                min(b[0] for b in boxes),
                min(b[1] for b in boxes),
                max(b[2] for b in boxes),
                max(b[3] for b in boxes),
            )

            dominant = max(
                spans,
                key=lambda s: len(_norm_text(s.get("text", "")))
            )

            objects.append(
                PDFObject(
                    page=page_index,
                    kind="text",
                    text=text_value,
                    bbox=bbox,
                    font=dominant.get("font", ""),
                    size=float(dominant.get("size", 0)),
                    color=(
                        fitz.sRGB_to_rgb(dominant.get("color", 0))
                        if hasattr(fitz, "sRGB_to_rgb") else ()
                    ),
                    spans=tuple(spans),
                )
            )

        # Drawings are kept as coarse structural objects.
        for drawing in page.get_drawings():
            rect = drawing.get("rect")
            if rect:
                objects.append(
                    PDFObject(
                        page=page_index,
                        kind="drawing",
                        bbox=(rect.x0, rect.y0, rect.x1, rect.y1),
                    )
                )

        # Images: record placement rather than raster-comparing their pixels.
        for image in page.get_images(full=True):
            xref = image[0]
            for rect in page.get_image_rects(xref):
                objects.append(
                    PDFObject(
                        page=page_index,
                        kind="image",
                        bbox=(rect.x0, rect.y0, rect.x1, rect.y1),
                        number=xref,
                    )
                )

        pages.append(objects)

    doc.close()
    return pages


def _bbox_distance(a, b):
    ax = (a[0] + a[2]) / 2
    ay = (a[1] + a[3]) / 2
    bx = (b[0] + b[2]) / 2
    by = (b[1] + b[3]) / 2
    return float(np.hypot(ax - bx, ay - by))


def _bbox_size(a):
    return max(0.0, a[2] - a[0]), max(0.0, a[3] - a[1])



def _text_similarity(a, b):
    """Whitespace/case-insensitive similarity for paragraph matching."""
    import difflib
    return difflib.SequenceMatcher(
        None,
        _norm_text(a).casefold(),
        _norm_text(b).casefold(),
    ).ratio()


def _same_page_text_candidates(before_items, after_item, used_before):
    """Find plausible paragraph matches, preferring exact text."""
    exact = [
        (bi, bo) for bi, bo in before_items
        if bi not in used_before and bo.text == after_item.text
    ]
    if exact:
        return exact

    fuzzy = []
    for bi, bo in before_items:
        if bi in used_before:
            continue

        score = _text_similarity(bo.text, after_item.text)
        distance = _bbox_distance(bo.bbox, after_item.bbox)

        # Strong text similarity OR substantial shared content. Keep the
        # spatial constraint so repeated words elsewhere aren't matched.
        if score >= 0.80 and distance <= 120:
            fuzzy.append((score, distance, bi, bo))

    fuzzy.sort(key=lambda x: (-x[0], x[1]))
    return [(bi, bo) for _, _, bi, bo in fuzzy[:3]]


def compare_pdf_structure(before_pdf, after_pdf, before_page, after_page):
    """
    Match PDF objects semantically.

    Text is matched by exact normalized content first, then by
    fuzzy spatial similarity. Drawings/images are matched by kind
    and geometry. Returns page-level structural changes.
    """
    before_pages = extract_pdf_objects(before_pdf, before_page)
    after_pages = extract_pdf_objects(after_pdf, after_page)

    results = []

    for page_no in range(max(len(before_pages), len(after_pages))):
        before = before_pages[page_no] if page_no < len(before_pages) else []
        after = after_pages[page_no] if page_no < len(after_pages) else []

        used_before = set()
        used_after = set()

        # ---- text: exact content matching first ----
        text_before = [
            (i, o) for i, o in enumerate(before) if o.kind == "text"
        ]
        text_after = [
            (i, o) for i, o in enumerate(after) if o.kind == "text"
        ]

        for ai, ao in text_after:
            candidates = _same_page_text_candidates(
                text_before,
                ao,
                used_before,
            )

            if candidates:
                bi, bo = min(
                    candidates,
                    key=lambda x: _bbox_distance(x[1].bbox, ao.bbox)
                )
                used_before.add(bi)
                used_after.add(ao.text)

                dx = ao.bbox[0] - bo.bbox[0]
                dy = ao.bbox[1] - bo.bbox[1]
                old_w, old_h = _bbox_size(bo.bbox)
                new_w, new_h = _bbox_size(ao.bbox)

                if abs(dx) > 1 or abs(dy) > 1:
                    results.append({
                        "page": page_no,
                        "kind": "moved",
                        "bbox": ao.bbox,
                        "dx": dx,
                        "dy": dy,
                        "text": ao.text,
                    })
                if (
                    abs(ao.size - bo.size) > 0.25
                    or ao.font != bo.font
                ):
                    results.append({
                        "page": page_no,
                        "kind": "removed",
                        "bbox": bo.bbox,
                        "text": bo.text,
                    })
                    results.append({
                        "page": page_no,
                        "kind": "added",
                        "bbox": ao.bbox,
                        "text": ao.text,
                    })
                else:
                  aospans = spread(ao.spans)
                  bospans = spread(bo.spans)
                  matcher = difflib.SequenceMatcher()
                  matcher.set_seqs([s["match"] for s in bospans], [s["match"] for s in aospans])
                  for tag, i1, i2, j1, j2 in matcher.get_opcodes():
                    if tag == "delete":
                     for i in range(i1, i2):
                      results.append({
                        "page": page_no,
                        "kind": "removed",
                        "bbox": bospans[i]["bbox"],
                        "text": bospans[i]["text"],
                      })
                    elif tag == "insert":
                     for j in range(j1, j2):
                      results.append({
                        "page": page_no,
                        "kind": "added",
                        "bbox": aospans[j]["bbox"],
                        "text": aospans[j]["text"],
                      })
                    elif tag == "replace":
                     for i in range(i1, i2):
                      results.append({
                        "page": page_no,
                        "kind": "removed",
                        "bbox": bospans[i]["bbox"],
                        "text": bospans[i]["text"],
                      })
                     for j in range(j1, j2):
                      results.append({
                        "page": page_no,
                        "kind": "added",
                        "bbox": aospans[j]["bbox"],
                        "text": aospans[j]["text"],
                      })

        # ---- text that is new / removed ----

        for ai, ao in text_after:
            if ao.text in used_after:
                continue
            if not any(
                bo.kind == "text"
                and bo.text == ao.text
                and bi in used_before
                for bi, bo in text_before
            ):
                    results.append({
                        "page": page_no,
                        "kind": "added",
                        "bbox": ao.bbox,
                        "text": ao.text,
                    })

        for bi, bo in text_before:
            if bi not in used_before:
                results.append({
                    "page": page_no,
                    "kind": "removed",
                    "bbox": bo.bbox,
                    "text": bo.text,
                })

        continue
        # ---- coarse drawings/images ----
        for kind in ("drawing", "image"):
            old = [(i, o) for i, o in enumerate(before) if o.kind == kind]
            new = [(i, o) for i, o in enumerate(after) if o.kind == kind]

            used_old = set()
            for ai, ao in new:
                candidates = [
                    (bi, bo) for bi, bo in old
                    if bi not in used_old
                ]
                if not candidates:
                    results.append({
                        "page": page_no,
                        "kind": "added",
                        "bbox": ao.bbox,
                    })
                    continue

                bi, bo = min(
                    candidates,
                    key=lambda x: _bbox_distance(x[1].bbox, ao.bbox)
                )
                used_old.add(bi)

                dx = ao.bbox[0] - bo.bbox[0]
                dy = ao.bbox[1] - bo.bbox[1]
                if abs(dx) > 1 or abs(dy) > 1:
                    results.append({
                        "page": page_no,
                        "kind": "moved",
                        "bbox": ao.bbox,
                        "dx": dx,
                        "dy": dy,
                    })

            for bi, bo in old:
                if bi not in used_old:
                    results.append({
                        "page": page_no,
                        "kind": "removed",
                        "bbox": bo.bbox,
                    })

    return results

def spread(spans):
  result = []
  for s in spans:
    for w in s["text"].split(' '):
      if w == '':
        continue
      news = s.copy()
      news["match"] = f"{w} {s['font']}"
      result.append(news)
  return result


def render_pdf_structural_diff(after_pdf, structural_changes, kind, fname, pagenum):
    """Render the AFTER PDF with structural changes highlighted."""
    doc = fitz.open(after_pdf)
    rendered = []

    for page_no, page in enumerate(doc):
      if page_no + 1 == pagenum:
        pix = page.get_pixmap(matrix=fitz.Matrix(2, 2), alpha=False)
        image = np.frombuffer(pix.samples, dtype=np.uint8).reshape(
            pix.height, pix.width, pix.n
        )
        if pix.n == 4:
            image = cv2.cvtColor(image, cv2.COLOR_RGBA2BGRA)
        else:
            image = cv2.cvtColor(image, cv2.COLOR_RGB2BGRA)

        highlights = np.zeros((pix.height, pix.width, 1), dtype=np.uint8)

        for change in structural_changes:
            if change["page"] != page_no:
              pass
              #continue
            if change["kind"] != kind:
              continue

            x0, y0, x1, y1 = change["bbox"]
            scale = 2.0
            p1 = (int(x0 * scale), int(y0 * scale))
            p2 = (int(x1 * scale), int(y1 * scale))

            color = COLORS.get(change["kind"], (0, 150, 255))

            #cv2.rectangle(image, p1, p2, color, 2, cv2.LINE_AA)
            corners = [
                [p1[0], p1[1]],
                [p1[0], p2[1]],
                [p2[0], p2[1]],
                [p2[0], p1[1]],
            ]
            cv2.fillPoly(highlights, np.array([corners]), (255,))
        ctrs, _ = cv2.findContours(highlights, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
        highlights_c = np.zeros((pix.height, pix.width, 4), dtype=np.uint8)
        cv2.drawContours(highlights_c, ctrs, -1, COLORSFILL[kind], cv2.FILLED)
        alpha_foreground = highlights_c[:,:,3] / 255.0
        for color in range(0, 3):
          image[:,:,color] = (1-alpha_foreground)*image[:,:,color]+alpha_foreground*highlights_c[:,:,color]
        cv2.drawContours(image, ctrs, -1, COLORSLINE[kind], 2)

        cv2.imwrite(str(fname), image)
        rendered.append(str(fname))

    doc.close()
    return rendered


# ============================================================
# CLI
# ============================================================

def main():
    parser = argparse.ArgumentParser(
        description="Compare two PDFs using their internal document structure."
    )

    parser.add_argument("before", help="Original PDF")
    parser.add_argument("after", help="Modified PDF")
    parser.add_argument(
        "--output-dir",
        default="pdf_diff_pages",
        help="Directory for annotated AFTER-PDF page images",
    )
    parser.add_argument(
        "--report",
        default=None,
        help="Optional text report containing structural changes",
    )
    parser.add_argument("--before-page", type=int)
    parser.add_argument("--after-page", type=int)
    parser.add_argument("--force-output", action=argparse.BooleanOptionalAction, default=False)

    args = parser.parse_args()

    if Path(args.before).suffix.lower() != ".pdf":
        parser.error("BEFORE must be a PDF")
    if Path(args.after).suffix.lower() != ".pdf":
        parser.error("AFTER must be a PDF")

    changes = compare_pdf_structure(args.before, args.after, args.before_page, args.after_page)

    print()
    print("=" * 72)
    print("PDF STRUCTURAL DIFF")
    print("=" * 72)

    counts = {}
    for change in changes:
        counts[change["kind"]] = counts.get(change["kind"], 0) + 1

    for kind in (
        "moved",
        "added",
        "removed",
    ):
        print(f"{kind.upper():16s}: {counts.get(kind, 0)}")

    for i, change in enumerate(changes, 1):
        text_value = change.get("text", "")
        old_text = change.get("old_text", "")
        suffix = f" text={text_value!r}" if text_value else ""
        if old_text:
            suffix += f" old={old_text!r}"

        print(
            f"{i:4d}. page={change['page'] + 1} "
            f"{change['kind'].upper():14s} "
            f"bbox={tuple(round(x, 2) for x in change['bbox'])}"
            f"{suffix}"
        )

    if args.report:
        Path(args.report).write_text(
            "\n".join(repr(x) for x in changes),
            encoding="utf-8",
        )

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    changes = [change for change in changes if change["kind"] != "moved"]

    if changes or args.force_output:
      rendered = render_pdf_structural_diff(
        args.after,
        changes,
        "added",
        output_dir / f"bb-{args.after_page}.png",
        args.after_page,
      )

      render_pdf_structural_diff(
        args.before,
        changes,
        "removed",
        output_dir / f"aa-{args.before_page}.png",
        args.before_page,
      )

      print()
      print("Annotated page images:")
      for path in rendered:
          print(path)


if __name__ == "__main__":
    main()

