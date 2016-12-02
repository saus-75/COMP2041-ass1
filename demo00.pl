#!/usr/bin/perl -w
# put your demo script here
$x = 0;
while ($x < 100){
    if ($x == 25){
        print "Suprise!\n"; 
    } elsif ($x == 50){
        print "Didn't expect me to come back, did you?\n";
    } elsif ($x == 75){
        print "Good bye\n";
    } else {
        print "$x\n";
    }
    $x++;
}
