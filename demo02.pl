#!/usr/bin/perl -w
# put your demo script here
#use in.txt to use this script please

$x = 3;

while (1){
    $line = <STDIN>;
    chomp $line;
    if ($line eq "grapes"){
        $x = $x + 20 * 10 + 10;
    } else {
        if ($line eq "baked"){
            $x -= 3;
            print "$x\n";
            last;
        }
    }
    print "$line\n";
}