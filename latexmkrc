if ($ENV{HOMM3_PRINTABLE}) {
  &alt_tex_cmds;
  $pre_tex_code = '\AtBeginDocument{\toggletrue{printable}}';
  
  if ($ENV{HOMM3_PRINTABLE_NO_BACKGROUND}) {
    $pre_tex_code = '\AtBeginDocument{\toggletrue{printable}\toggletrue{printablenobg}}';
  }

  my $lang = $ENV{HOMM3_LANG};
  $makeindex = "sh -c 'upmendex -s <(cat index_style.ist; echo icu_locale \"$lang\") -o %D %S'";
}
