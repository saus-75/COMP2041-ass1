#!/usr/bin/perl -w
# put your demo script here

$a = "I have an apple\n";
$p = "I have a pen\n";

print join($a, $p), "\n";

print split(/a/, $a), "\n";