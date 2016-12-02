#!/usr/bin/perl -w
# put your demo script here
#something i wrote up, it wont work with my traslator tho maybe someone elses might work :P

$url = $ARGV[0];

open U, "wget -q -O- $url|";

if (U ne " "){
    while ($line = <U>){
        if ($line =~ m/\.mp3<\/a>/ig){
            $line =~ s/<td>//g;
            $line =~ s/^[\t]*//g;
            $line =~ s/<a href="//g;
            $line =~ s/">.*//g;
            #print "Wgetting this site $line";
            open V, "wget -q -O- $line|";
            if (V ne " "){
                while ($dl = <V>){
                    if ($dl =~ m/<audio id.*/ig){
                        $dl =~ s/.*src="//g;
                        $dl =~ s/" controls.*//g;
                        system "wget $dl";
                        print $dl;
                    }
                }
            }
        }
    }
}