if ($ENV{HOMM3_PRINTABLE}) {
  my %langs = (
    de => 'german-din',
    en => 'english',
    es => 'spanish-modern',
    fr => 'french',
    pl => 'polish',
    ru => 'russian',
    ua => 'ukrainian',
  );
  $makeindex = 'texindy -L ' . $langs{$ENV{HOMM3_LANG}} . ' -C utf8 -o %D -M index_style %S';

  &alt_tex_cmds;
  $pre_tex_code = '\AtBeginDocument{\toggletrue{printable}}';
}
