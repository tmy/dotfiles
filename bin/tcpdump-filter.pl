#!/usr/local/bin/perl

# $Id: tcpdump-filter.pl,v 1.2 2002/02/17 11:07:28 68user Exp $

while(<STDIN>){
    if(m/^[ \t]/){
        s/^\s+0x\w{4}:\s+//;
        s/\s{2}\S+$//;
        s/\s+//g;
        $store .= $_
    } else {
        s/^[^ ]* //;
        s/:[^:]*$//;
        print "$_\n";
        $_ = $store;
        s/\s//g;
        s/^.{120}//;
        s/[0-9A-Fa-f][0-9A-Fa-f]/pack("C", hex $&)/eg;
        s/[\x7f-\xff]/?/g;
        print "$_\n";
        $store = "";
    }
}
