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

if ($ENV{HOMM3_PRINTABLE}) {
  my $locale = $ENV{ICU_LOCALE} // 'en_US';
  $makeindex = "bash -c 'upmendex -s <(cat index_style.ist; echo icu_locale \\\"$locale\\\") -o %D %S'";
}
