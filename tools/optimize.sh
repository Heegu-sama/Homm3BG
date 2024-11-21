#!/usr/bin/env bash

# Default values
LANGUAGE="en"
CONVERSION_MODE=""

# Valid language codes
VALID_LANGUAGES=("en" "pl" "es" "fr" "ua" "ru" "cs" "he" "de")

# Function to print usage information
usage() {
  echo "Usage: $0 [language] [--mono|--cmyk]"
  echo "Positional arguments:"
  echo "  language           Language code: ${VALID_LANGUAGES[*]}"
  echo "                     Defaults to 'en' if not specified"
  echo "Options:"
  echo "  --mono             Convert to monochrome (black and white)"
  echo "  --cmyk             Convert to CMYK color space"
  exit 1
}

# Function to check if language is valid
is_valid_language() {
  local lang="$1"
  for valid_lang in "${VALID_LANGUAGES[@]}"; do
    if [[ "$lang" = "$valid_lang" ]]; then
      return 0
    fi
  done
  return 1
}

# Check if first argument is a language code
if [[ $1 =~ ^[a-z]{2}$ ]]; then
  if is_valid_language "$1"; then
    LANGUAGE="$1"
    shift
  else
    echo "Error: Invalid language code '$1'. Valid codes are: ${VALID_LANGUAGES[*]}" >&2
    exit 1
  fi
fi

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
gs -o main_${LANGUAGE}_optimized.pdf \
   -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.5 \
   -dPDFSETTINGS=/prepress \
   -dDetectDuplicateImages=true \
   ${CONVERSION_MODE} main_${LANGUAGE}.pdf
