#!/usr/bin/env perl

print <<END;
     0 1 2 3 4 5 6 7 8 9 A B C D E F  
---+---------------------------------
END

foreach $i (0x0 .. 0xF) {
    print ' ', $i, ' |';
    foreach $j (0x0 .. 0xF) {
        $char = $i * 0x10 + $j;
        print ' ', pack('s', $char);
    }
    print "\n";
}
