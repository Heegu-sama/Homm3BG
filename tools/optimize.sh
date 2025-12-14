#!/usr/bin/env bash

source tools/.language_base.sh

# Default values
CONVERSION_MODE=""

# Function to print usage information
usage() {
  echo "Usage: $0 [language] [--mono|--cmyk]"
  echo "Positional arguments:"
  echo "  language           Language code: ${valid_languages[*]}"
  echo "                     Defaults to 'en' if not specified"
  echo "Options:"
  echo "  --mono             Convert to monochrome (black and white)"
  echo "  --cmyk             Convert to CMYK color space"
  exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --mono)
      if [[ -n "$CONVERSION_MODE" ]]; then
        echo "Error: Both --mono and --cmyk options cannot be specified." >&2
        usage
      fi
      CONVERSION_MODE="-sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray"
      shift
      ;;
    --cmyk)
      if [[ -n "$CONVERSION_MODE" ]]; then
        echo "Error: Both --mono and --cmyk options cannot be specified." >&2
        usage
      fi
      CONVERSION_MODE="-sColorConversionStrategy=CMYK"
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Error: Unknown option $1"
      usage
      ;;
  esac
done

# Optimize the PDF
gs -o "main_${LANGUAGE}_optimized.pdf" \
   -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.5 \
   -dPDFSETTINGS=/prepress \
   -dDetectDuplicateImages=true \
   "${CONVERSION_MODE}" "main_${LANGUAGE}.pdf"
