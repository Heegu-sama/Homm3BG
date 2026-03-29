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
  open(my $fh, '>', 'index_style_generated.ist') or die $!;
  open(my $base, '<', 'index_style.ist') or die $!;
  print $fh $_ while <$base>;
  print $fh "\nicu_locale \"$locale\"\n";
  close $fh;

  $makeindex = 'upmendex -s index_style_generated.ist -o %D %S';
}
