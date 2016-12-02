#!/usr/bin/perl -w
# put your demo script here
$j = 0;
foreach $i (0..50){
    while ($j < $i){
        print "*";
        $j++;
    }
    print "\n";
    $j=0;
}