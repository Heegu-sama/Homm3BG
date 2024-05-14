if ($ENV{HOMM3_PRINTABLE}) {
  &alt_tex_cmds;
  $pre_tex_code = '\AtBeginDocument{\toggletrue{printable}}';
}

$makeindex = 'tools/makeindex.py --i %S --o %D';
