#!/usr/bin/env bash

LANGUAGE="en"
valid_languages=("en" "pl" "es" "fr" "ua" "ru" "cs" "he" "de")
declare -A icu_locale_map=(
  ["en"]="en_US"
  ["pl"]="pl_PL"
  ["es"]="es_ES"
  ["fr"]="fr_FR"
  ["ua"]="uk_UA"  # "ua" is the country code; ICU uses "uk" for Ukrainian
  ["ru"]="ru_RU"
  ["cs"]="cs_CZ"
  ["he"]="he_IL"
  ["de"]="de_DE"
)

# Function to check if language is valid
is_valid_language() {
  local lang="$1"
  for valid_lang in "${valid_languages[@]}"; do
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
    echo "Error: Invalid language code '$1'. Valid codes are: ${valid_languages[*]}" >&2
    exit 1
  fi
fi

export ICU_LOCALE="${icu_locale_map[$LANGUAGE]}"
