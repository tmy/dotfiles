#!/usr/bin/env perl
use strict;
use warnings;
use Encode;
my $east = qr/(?!\p{M})(?:\p{Han}|\p{Katakana}|\p{Hiragana})/;
my $west = qr/(?!\p{M})(?:\p{Latin}|\p{Greek}|\p{Cyrillic})/;
binmode STDOUT, ':utf8';
while(<>){
    $_ = decode 'utf8', $_;
    s/($east)($west)/$1 $2/g;
    s/($west)($east)/$1 $2/g;
    print;
}
