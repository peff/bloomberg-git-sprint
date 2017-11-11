my $src = replace_ext($TARGET, 'html', 'md');
target;
dependon qw(mkslides), $src;
formake atomic("./mkslides <$src");
