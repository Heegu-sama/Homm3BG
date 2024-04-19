# Heroes of Might & Magic III: The Board Game 🐴 🛡️ ⚔️️<br>Rule Book Rewrite Project 📜🪶

Please see the original thread on [BoardGameGeek](https://boardgamegeek.com/thread/3235221/rule-book-rewrite-project/page/1) 🤓

This repository hosts **three** documents.
Efforts are ongoing to translate them to languages other than English.
Please reach out if you'd like to help with translating.
Click in the table to download the most recent builds in the chosen language:

|               |Progress|📜 **Rewritten Rule Book** |🖨️ **Rule Book - printable version** |📋 **Comprehensive Components List**|
|:--------------|:------:|:-------------------------:|:-----------------------------------:|:----------------------------------:|
| 🇬🇧 English    |100%|[🇬🇧📜](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/en/main_en.pdf)|[🇬🇧🖨️](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/en/printable_en.pdf)|[🇬🇧📋](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/components_list_en/components_list_en.pdf)|
| 🇵🇱 Poski      |~30%|[🇵🇱📜](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/pl/main_pl.pdf)|[🇵🇱🖨️](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/pl/printable_pl.pdf)|[n/a](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/components_list_pl/components_list_pl.pdf)|
| 🇪🇸 Español    |~8%|[🇪🇸📜](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/es/main_es.pdf)|[🇪🇸📜](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/es/printable_es.pdf)|[n/a](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/components_list_es/components_list_es.pdf)|
| 🇫🇷 Français   |0%|[n/a](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/fr/main_fr.pdf)|[n/a](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/fr/printable_fr.pdf)|[n/a](https://raw.githubusercontent.com/qwrtln/Homm3BG-build-artifacts/components_list_fr/components_list_fr.pdf)|


⚠️ The printable build appends page numbers to select clickable hyperlinks, and includes an index page at the end 🤞

Componets List lists all the cards 🃏, minis 🚹, tokens, etc. for every box.
See another [BoardGameGeek thread](https://boardgamegeek.com/thread/3265461/article/43995671#43995671) for details.

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
- [**GIMP**](https://www.gimp.org/) (optional) to edit some images in `assets` directory - see below for details
- [**aspell**](http://aspell.net/) (optional) for spellchecking - see below for details

To build the document in English, either run this in the command line:

```bash
latexmk -pdf -silent -shell-escape "main_en"
```

or press the `Build & View` ▶️ (F5) button in TeXstudio.
To build components list instead of the rule book, just replace `"main_en"` with `"components_list"`, or press `Build & View` with that file open in TeXstudio.

To build the printable version in a given language, make sure you've built a regular one first at least once.
Then, use the script:

> ⚠️ Be careful, as it edits all the files!
> Also, you'll need [Python](https://www.python.org/) for this 🐍

```bash
./make_printable.sh en
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
We are currently looking into it, how best to remediate this.

The personal dictionary `.aspell.homm3.pwd` currently contains only game-related words.
It does not contain names (e.g., "BoardGameGeek") or parameter values (e.g., "px", "svg") in order to minimize the chances of false-negatives in the main body of text.

## ✨ Assets

All assets come from publicly available sources.
Some of the images in the rule book (all in the [`assets/examples`](https://github.com/Heegu-sama/Homm3BG/tree/main/assets/examples) directory as of writing) were generated by [GIMP](https://www.gimp.org/).
Their respective XCF files reside in [`assets/gimp-files`](https://github.com/Heegu-sama/Homm3BG/tree/main/assets/gimp-files) directory.
