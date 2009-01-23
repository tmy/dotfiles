#!/usr/bin/env perl

use strict;
use File::Basename;
use Jcode;

sub walk {
  my ($dir) = @_;
  local *DIR;
  opendir DIR, $dir;
  while (my $f = readdir(DIR)) {
    next if $f eq '.' or $f eq '..';
    if (-d "$dir/$f") {
      print "Directry: $dir/$f\n";
      walk("$dir/$f");
    }
    my $renamed = Jcode->new($f)->utf8;
    if ($f ne $renamed) {
      print join(', ', 'rename', "$dir/$f", "$dir/$renamed"), "\n";
    }
  }
  closedir DIR;
}

foreach (@ARGV) {
  walk($_);
}