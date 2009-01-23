#!/usr/bin/perl

use strict;
my $ascii     = "[\x00-\x09\x0b-\x0c\x0e-\x19\x21-\x7f]";
my $non_ascii = "[^\x00-\x7f]";

while (<>) {
    s{((?<=$non_ascii) +($ascii)|($ascii) +(?=$non_ascii))}
    {$2||$3}eg;
    print;
}
