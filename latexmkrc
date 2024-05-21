if ($ENV{HOMM3_PRINTABLE}) {
  &alt_tex_cmds;
  $pre_tex_code = '\AtBeginDocument{\toggletrue{printable}}';

  my $lang = $ENV{HOMM3_LANG};
  $lang = $lang . '_' . uc($lang) . '.UTF-8';
  $makeindex = "tools/makeindex.py --input %S --output %D --language $lang";
}
