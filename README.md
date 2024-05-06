# Heroes of Might & Magic III: The Board Game 🐴 🛡️ ⚔️️<br>Rule Book Rewrite Project 📜🪶

Please see the original thread on [BoardGameGeek](https://boardgamegeek.com/thread/3235221/rule-book-rewrite-project/page/1) 🤓

Efforts are ongoing to translate the rule book to languages other than English.
Please reach out if you'd like to help with translating.
Click in the table to download the most recent builds in the chosen language:

|                 | Progress |                                📜 **Rewritten Rule Book**                                 |                              🖨️ **Rewritten Rule Book - printable version**                              |
|:----------------|:--------:|:-----------------------------------------------------------------------------------------:|:----------------------------------------------------------------------------------------------:|
| 🇬🇧 English    |   100%   | [🇬🇧📜](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/en/main_en.pdf) | [🇬🇧🖨️](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/en/printable_en.pdf) |
| 🇵🇱 Polski     |   ~95%   | [🇵🇱📜](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/pl/main_pl.pdf) | [🇵🇱🖨️](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/pl/printable_pl.pdf) |
| 🇪🇸 Español    |   ~90%   | [🇪🇸📜](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/es/main_es.pdf) | [🇪🇸🖨️](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/es/printable_es.pdf) |
| 🇫🇷 Français   |   ~95%   | [🇫🇷📜](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/fr/main_fr.pdf) | [🇫🇷🖨️](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/fr/printable_fr.pdf) |
| 🇷🇺 Русский    |   ~39%   | [🇷🇺📜](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/ru/main_ru.pdf) | [🇷🇺🖨️](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/ru/printable_ru.pdf) |
| 🇺🇦 Українська |   ~10%   | [🇺🇦📜](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/ua/main_ua.pdf) | [🇺🇦🖨️](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/ua/printable_ua.pdf)|

🖨️ The printable build appends page numbers to select clickable hyperlinks, and includes an index page at the end 🤞

This repository used to host [**Comprehensive Components List**](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/components_list_en/components_list_en.pdf) listing all the cards, minis, tokens, etc. for every box, but after a while ⚠️ ️️**Archon released their own version of it, and you should use it instead. Find it on 👉 [their website](https://archon-studio.com/downloads/heroes-iii) 👈 called "Content Guide"**.

### 💡 What Is This?

This project aims to rewrite the original rule book, in which the amount of vague language was just too vast to ignore.

This repository hosts a document that aims to explain the rules clearly and concisely, and should eventually have an answer for any basic rules query you might have.

### 🤔 Why?

The content in the official English rule book is, simply put, insufficient as a teaching tool for the game or as a general rules reference.
If you read the thread linked above you should understand how frustrating this has been for me.

### 🛠️ How?

I am completely rewriting the rule book in LaTeX.
It's possible that a finalized version will be later put together using other tools such as Adobe Visual Studio.

This is a communal effort.
This repository serves both as a means for me to preserve my work, but also for others to contribute to it as writers, proofreaders, or layout designers.
If you wish to contribute directly, please contact me on BoardGameGeek or discord, my username is Heegu on both platforms.

### 🔮 The Future

All new version of the rule book and their change logs will be published here and in the BGG thread.
I will probably submit an indefinite number of changes before changing the version number again.
The aim is to have a vastly superior "1.0" version ready before most people receive their pledges.

The current aim is to produce a document that's meant more for digital reading, as most references to other rules and sections within the document are accomplished by using hyperlinks in the text.
I know most people would also love a version that's designed more for printing, I'll see if I later have the energy to create that as well.
A printable document would probably be more of a shorter reference, this document will always have 30+ pages.

Please discuss any and all factual errors, bad language or other errors you've found by either contacting me directly or in the thread.
You can do this by reaching out to me directly or by opening pull requests with suggestions.

## 💻 Local Development

To work on the document on your machine, you need the following:

- [**MiKTeX**](https://miktex.org/) (required) to build the PDF file from LaTeX files
- [**Inkscape**](https://inkscape.org/) (required) to render glyphs in the document (while installing on Windows, make sure to tick `Add Inkscape to the System Path` option)
- [**TeXstudio**](https://www.texstudio.org/) (optional) to edit LaTeX files and rebuild the PDF file quickly
- [**po4a**](https://po4a.org/index.php.en) (optional) to work on translating the document to other languages
- [**pdftoppm**](https://linux.die.net/man/1/pdftoppm) (optional) to make screenshots of rendered PDF pages
- [**ImageMagick**](https://imagemagick.org/index.php) (optional) to combine screenshots into convenient diffs
- [**GIMP**](https://www.gimp.org/) or [**Krita**](https://krita.org/) (optional) to edit some images in `assets` directory
- [**aspell**](http://aspell.net/) (optional) for spellchecking

To build the document in English, either run this in the command line:

```bash
latexmk -pdf -silent -shell-escape "main_en"
```

or press the `Build & View` ▶️ (F5) button in TeXstudio on the `main_en.tex` file.

To build the document in any other language (currently `pl`, `es`, `fr`, `ru` and `ua` are supported), make sure you have `po4a` (version 0.70 or higher) and use the script:

```bash
tools/build.sh <LANGUAGE>
```

or press the `Build & View` ▶️ (F5) button in TeXstudio while having any `main_<LANGUAGE>.tex` file open, after running `po4a` (see `Translations` below for details).

To build components list instead of the rule book, use this:

```bash
latexmk -pdf -shell-escape components_list
```

or press `Build & View` on file `components_list.tex` open in TeXstudio.

To build the printable version in a given language, make sure you've built a regular one first at least once.
Then, use the script:

> ⚠️ Be careful, as it edits all the files!
> Also, you'll need [Python](https://www.python.org/) for this 🐍

```bash
tools/make_printable.sh <LANGUAGE>
```

### 🌍 Translations

Make sure you have [`po4a`](https://po4a.org/index.php.en) installed ([MacOS instructions](https://formulae.brew.sh/formula/po4a)).

To translate a particular section:

- Go to `translations/<section_name>` and open `<lang>.po` file, e.g., `translations/introduction.tex/pl.po`
- Choose a fragment to translate. Those start with `msgid`. Write your new text in the line below starting with `msgstr`. Example:

    ```tex
    msgid "\\addsection{Introduction}{\\spells/magic_arrow.png}"
    msgstr "\\addsection{Wprowadzenie}{\\spells/magic_arrow.png}"
    ```

  This text (`msgstr`) will replace the original (`msgid`) in your translation.
- Regenerate your localized section:

    ```bash
    po4a --no-update po4a.cfg
    ```

  Disregard the errors about mismatched `multicols`, as this is an upstream parser issue.
- Rebuild your PDF file (or press Build ▶️ in TeXStudio).

   ```bash
   latexmk -pdf -silent -shell-escape "main_<lang>"
   ```

- Commit and repeat!

#### Finding fuzzy translations

In case an already translated text is changed, `po4a` marks such a translation as _fuzzy_ in the `*.po` files.
Those excerpts will be compiled just as they are in the original (English), until the translation is corrected, and the _fuzzy_ mark is removed.
To facilitate finding them, use the script:

```bash
tools/find_fuzzy.sh <lang>
```

It will show all the fuzzy translations in the `*.po` files for the specified language.

### 📸 Screenshots

It is a good practice to share screenshots of your work in pull requests.
You can the script to make PNG images of specified page(s):

```bash
tools/pdf2image.sh <LANGUAGE> <FIRST_PAGE> <LAST_PAGE>
```

Example:

```bash
tools/pdf2image.sh en 5 7
```

To process a single page, use:

```bash
tools/pdf2image.sh en 5
```

### 🎭 Comparing two pages side by side

If you'd like to show a single image of two instances of the same page side-by-side (before|after style), you can use the following script:

```bash
tools/compare_pages.sh <FILE_COMPARED_AGAINST> <LANGUAGE> <FIRST_PAGE> <LAST_PAGE>
```

Let's assume you have `main_en.pdf` in your home directory downloaded from GitHub, and in your current working directory you have a build you're working on.
You'd like to have images comparing pages 38 through 41.
Here's how to use it:

```bash
tools/compare_pages.sh ~/main_en.pdf en 38 41
```

It will produce files: `38.png`, `39.png`, `40.png` and `41.png`.

**This script requires `pdftoppm` and `imagemagick` utilities.**

### 🔎 Spellchecking

TeXstudio has built-in spellchecking, but the first steps have been made towards automated spellchecking with aspell.
For local development, after installing the tool, you can run it from the command line for example with

```bash
aspell -d en_US -p=./.aspell.homm3.pws --mode=tex --dont-backup check main.tex
```

or when wanting to check all `.tex` files then with

```bash
find . -type f -name "*.tex" -exec aspell -d en_US -p=./.aspell.homm3.pws --mode=tex --dont-backup check {} \;
```

Please note that currently the tool will flag many parameters in LaTeX commands.
We are currently looking into how best to remediate this.

The personal dictionary `.aspell.homm3.pwd` currently contains only game-related words.
It does not contain names (e.g., "BoardGameGeek") or parameter values (e.g., "px", "svg") in order to minimize the chances of false-negatives in the main body of text.

## ✨ Assets

All assets come from publicly available sources.
Some of the images in the rule book (all in the [`assets/examples`](https://github.com/Heegu-sama/Homm3BG/tree/main/assets/examples) directory as of writing) were generated by [GIMP](https://www.gimp.org/).
Their respective XCF files reside in [`assets/gimp-files`](https://github.com/Heegu-sama/Homm3BG/tree/main/assets/gimp-files) directory.
