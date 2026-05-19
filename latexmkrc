my $toggles = '';

if ($ENV{HOMM3_PRINTABLE}) {
  $toggles .= '\toggletrue{printable}';
}
if ($ENV{HOMM3_NO_ART_BACKGROUND}) {
  $toggles .= '\toggletrue{noartbackground}';
}
if ($ENV{HOMM3_GITHUB_BUILD}) {
  $toggles .= '\toggletrue{githubbuild}'
}

if ($toggles) {
  &alt_tex_cmds;
  $pre_tex_code = '\AtBeginDocument{'.$toggles.'}';
}

my %icu_locale_map = (
  en => 'en_US',
  pl => 'pl_PL',
  es => 'es_ES',
  fr => 'fr_FR',
  ua => 'uk_UA',
  ru => 'ru_RU',
  cs => 'cs_CZ',
  he => 'he_IL',
  de => 'de_DE',
  cn => 'zh-u-co-pinyin',
);

if ($ENV{HOMM3_PRINTABLE}) {
  my $locale = $ENV{ICU_LOCALE} // $icu_locale_map{$ENV{HOMM3_LANG} // ''} // 'en_US';
  $makeindex = "bash -c 'upmendex -s <(cat index_style.ist; echo icu_locale \\\"$locale\\\") -o %D %S'";
}
