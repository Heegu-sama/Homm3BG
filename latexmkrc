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
  my $lang = $ENV{HOMM3_LANG};
  $makeindex = "bash -c 'upmendex -s <(cat index_style.ist; echo icu_locale \"$lang\") -o %D %S'";
}
