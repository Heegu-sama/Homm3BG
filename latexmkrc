if ($ENV{HOMM3_PRINTABLE}) {
  my %langs = (
    de => ['german', 'din5007-utf8'],
    en => ['english', 'utf8'],
    es => ['spanish', 'modern-utf8'],
    fr => ['french', 'utf8'],
    pl => ['polish', 'utf8'],
    ru => ['russian', 'utf8'],
    ua => ['ukrainian', 'utf8'],
  );
  $makeindex = 'texindy -L ' . $langs{$ENV{HOMM3_LANG}}[0] . ' -C ' . $langs{$ENV{HOMM3_LANG}}[1] . ' -o %D -M index_style %S';

  &alt_tex_cmds;
  $pre_tex_code = '\AtBeginDocument{\toggletrue{printable}}';
}
