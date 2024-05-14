$makeindex = 'tools/makeindex.py %S > %D';

if ($ENV{HOMM3_PRINTABLE}) {
  &alt_tex_cmds;
  $pre_tex_code = '\AtBeginDocument{\toggletrue{printable}}';
}
