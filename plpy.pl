#!/usr/bin/perl -w

# written by andrewt@cse.unsw.edu.au September 2016
# as a starting point for COMP2041/9041 assignment 
# http://cgi.cse.unsw.edu.au/~cs2041/assignments/plpy/
# Replace this comment with your own header comment

#to deal with if statements that does not 
#take into account of the final else statement
$triggered = 0;
$stdin = 0;

#Checks the whole code for modules that is needed
my @codeSnippet;
while ($checker= <>) {
    if ($checker =~ /(<STDIN>|ARGV)/){
        $stdin = 1;
    }
    push @codeSnippet, $checker;
}

#The manipuation starts here
foreach $line (@codeSnippet){
    #special subroutine for ARGV
    $line = atOp($line);
    # translate #! line
    if ($line =~ /^#!/) {
        print "#!/usr/local/bin/python3.5 -u\n";
        if ($stdin == 1){
            print "import sys\n";
        }
    # Blank & comment lines can be passed unchanged
    } elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
        print $line;
#----------------------------DONT PUT ANYTHING BEFORE THIS LINE OR #! WILL BREAK----------------------------------------#
    # for last or next
    } elsif ($line =~ /(last;|next;|exit;)/){
        $line = laxt($line);
        $line = funcOp($line);
        print "$line";
    #if the line contains print("somthing"\n);
    } elsif ($line =~ /^\s*print\s*"(.*)\\n"[\s;]( *#?.*)$/) {
        $capture = $1;
        $comment = $2;
        #subroutine
        $capture = logOp($capture);
        $capture = atOp($capture);
        $capture = stdOp($capture);
        $capture = compOp($capture);
        $capture = funcOp($capture);
        $capture = inde($capture);
        $capture = ddot($capture);
        $capture = catOp($capture);
        ############
        #There might be prints with variables
        if ($capture =~ /\$/){
            $capture =~ s/\$//g;
            #padding fix
            if ($line =~ /^( *)/){
                print "$1" . "print($capture)$comment\n";
            } else {
                print "print($capture)\n$comment\n";    
            }
        } else {
            if ($line =~ /^( *)/){
                print "$1" . "print(\"$capture\")\n$comment";
            } else {
                print "print(\"$capture\")\n$comment";    
            }
        }
    #for the while loop that doesn't have a variable
    } elsif ($line =~ /while [^\$]*/){
        #subroutines
        $line = logOp($line);
        $line = elOp($line);
        $line = atOp($line);
        $line = stdOp($line);
        $line = compOp($line);
        $line = funcOp($line);
        $line = inde($line);
        $line = ddot($line);
        $line = catOp($line); 
        ############
        $line =~ s/(\$|;)//g;
        $line =~ s/\(|\)//g;
        $line =~ s/ *{/:/g;
        print "$line";
    #if the line contains a $ sign 
    } elsif ($line =~ /.*\$.*/){
        #gets rid of $ or ;
        if ($line =~ /for\ *\(/){
            $line =~ s/\$//g;
        } else {
            $line =~ s/(\$|;)//g;
        }
        #subroutines
        $line = logOp($line);
        $line = elOp($line);
        $line = atOp($line);
        $line = stdOp($line);
        $line = compOp($line);
        $line = funcOp($line);
        $line = inde($line);
        $line = catOp($line);
        ############
        if ($line =~ /\\n/){
            # gets rid the weird comma then break
            $line =~ s/, \"\\n\"//g;
        }
        #for print statement that didnt get captured
        if ($line =~ /print (.*)/){
            $expr = $1;
            #print variables can't have double qoutes
            $expr =~ s/"//g;
            if ($line =~ /^( *)/){
                print "$1" . "print\($expr\)\n";
                $triggered = 1;
            } else {
                print "print\($expr\)\n";   
                $triggered = 1; 
            }
        }
        #for loop and foreach loop translation
        if ($line =~ /for\ *\(.*|foreach/){
            if ($line =~ /for\ *\(.*/){
                #a truly disgusting regex but it works...
                $line =~ /for\ *\(\ *(.*)\ *;\ *(.*)\ *;\ *(.*)/;
                print "$1\n";
                $sub = $2;
                $sub =~ /([^ \+\=\<\>]*)[\ \+\=\<\>]*([^ ]*)/;
                print "for $1 in range($2):\n";
            } else {
                $line =~ s/foreach( *)([^ ]*)( *)(\(.*\))/for$1$2 in$3$4/g;
                $line =~ s/\(|\)//g;
                #special subroutine
                $line = ddot($line);
                $line =~ s/ *{/:/g;
                print $line;
            }
        #if there is braces and brackets
        }elsif ($line =~ /\((.*)\) *\{/){
            $line =~ s/ *{/:/g;
            $line =~ s/\(|\)//g;
            $line = ddot($line);
            if ($line =~ /}.*/){
                $line =~ s/} *//g;
                print "$line";
            } else {
                print "$line";
            }
        # for regex } [$something] {
        }elsif ($line =~ /\ *\}.*\{/){
            $line =~ s/} *//g;
            $line =~ s/ *{//g;
            print "$line";
        # everything else with $
        } elsif ($triggered != 1) {
            print "$line";
        }
        $triggered = 0;
    #for regex } [something] {
    } elsif ($line =~ /\ *\}.*\{/){
        #subroutines
        $line = elOp($line);
        $line = atOp($line);
        $line = stdOp($line);
        $line = compOp($line);
        $line = funcOp($line);
        $line = inde($line);
        $line = catOp($line); 
        ############
        $line =~ s/} *//g;
        $line =~ s/ *{/:/g;
        $line = ddot($line);
        print "$line";
    #lonely braces
    } elsif ($line =~ /\ *}\ *$/){
        $line =~ s/\ *}\ *//g;
    #Last line of defense against prints
    } elsif ($line =~ /(\ *)print\ *(.*)/){
        $spaces = $1;
        $cap = $2;
        #subroutines
        $cap = logOp($cap);
        $cap = elOp($cap);
        $cap = atOp($cap);
        $cap = stdOp($cap);
        $cap = compOp($cap);
        $cap = funcOp($cap);
        $cap = inde($cap);
        $cap = ddot($cap); 
        $cap = catOp($cap); 
        $cap =~ s/(\\n|;)//g;
        $cap =~ s/, ".*"//g;
        chomp $cap;
        ############
        print "$spaces"."print($cap)\n";
    } else {
        # Lines we can't translate are turned into comments
        print "#$line";
    }
}

#---------------------------------Subroutines------------------------------------#
#subroutine in regex for elsif
sub elOp {
    $el = shift;
    $el =~ s/elsif/elif/g;
    return $el;
}

#subroutine for concats
sub catOp {
    $dot = shift;
    if ($dot =~ /(\'|\"| )\.(\'|\"|\ )/){
        $dot =~ s/\./\+/g;
    }
    return $dot;
}

#subroutine for <STDIN>
sub stdOp {
    $stdin = shift;
    if ($stdin =~ /(for|foreach|while).*<STDIN>/){
        $stdin =~ s/<STDIN>/sys.stdin/g;
    } else {
        $stdin =~ s/<STDIN>/sys.stdin.readline()/g;
    }
    return $stdin;
}
#subroutine for last and next
sub laxt {
    $ln = shift;
    if ($ln =~ /[^'"]last;[^'"]/){
        $ln =~ s/last;/break/g;
    } elsif ($ln =~ /[^'"]next;[^'"]/){
        $ln =~ s/next;/continue/g;
    }
    return $ln;
}

#subroutine for @
sub atOp {
    $at = shift;
    if ($at =~ /\@ARGV/){
        $at =~ s/\@ARGV/sys\.argv\[1\:\]/g;
    } else {
        $at =~ s/\@//g;
    }
    return $at;
}

#subroutine for ..
sub ddot {
    $dd = shift;
    $dd =~ s/\[?(\d*)\.\.(\d*)\]?/range($1, $2+1)/g;
    return $dd;
}

#subroutine for comparators
sub compOp {
    $com = shift;
    if ($com =~ /.* eq .*/){
        $com =~ s/eq/==/g;
    } elsif ($com =~ /.* lt .*/){
        $com =~ s/lt/</g;
    } elsif ($com =~ /.* gt .*/){
        $com =~ s/gt/>/g;
    } elsif ($com =~ /.* le .*/){
        $com =~ s/le/<=/g;
    } elsif ($com =~ /.* ge .*/){
        $com =~ s/ge/>=/g;
    } elsif ($com =~ /.* ne .*/){
        $com =~ s/ne/!=/g;
    } elsif ($com =~ /.* cmp .*/){
        $com =~ s/eq/<>/g;
    }
    return $com;
}

#Subroutine for func (chomp, split, join, exit)
sub funcOp{
    $csje = shift;
    #chomp
    if ($csje =~ /^(\ *)chomp\ *(.*)/){
        $csje = "$1$2 = $2.rstrip()\n";
    #exit
    } elsif ($csje =~ /exit;/){
        $csje =~ s/exit;/exit()/g;
    #join
    } elsif ($csje =~ /(.*)join\ *\((.*), (.*)\)(.*)/){
        $csje = "$1$2.join\($3\)$4\n";
    #split
    } elsif ($csje =~ /(.*)split\ *\((.*), (.*)\)(.*)/){
        $qoute = $2;
        $x = $1;
        $y = $3;
        $z = $4;
        $qoute =~ s/\//'/g;
        $csje = "$x$y.split\($qoute\)$z\n";
    }
    return $csje;
}

#subroutine for ++ and --
sub inde {
    $ie = shift;
    #++$x;
    if ($ie =~ /^(\ *)\+\+([^\ ]*)/){
        $exp = $2;
        chomp $exp;
        $ie = "$1$exp += 1\n";
    #--$x;
    } elsif ($ie =~ /^(\ *)\-\-([^\ ]*)/){
        $exp = $2;
        chomp $exp;
        $ie = "$1$exp -= 1\n";
    #$x++;
    } elsif ($ie =~ /^(\ *)([^\ ]*)\+\+/){
        $ie = "$1$2 += 1\n";
    #$x--;
    } elsif ($ie =~ /^(\ *)([^\ ]*)\-\-/){
        $ie = "$1$2 -= 1\n";
    }
    return $ie;
}

#Subroutine for operators
sub logOp {
    $logic = shift;
    #<=>
    if ($logic =~ /.*<=>.*/){
        $logic =~ s/<=>/<>/g;
    }
    #||
    if ($logic =~ /.*\|\|.*/){
        if ($logic =~ /\ \|\| /){
            $logic =~ s/\|\|/or/g;
        } else{
            $logic =~ s/\|\|/ or /g;
        }
    }
    #&&
    if ($logic =~ /.*&&.*/){
        if ($logic =~ /\ && /){
            $logic =~ s/&&/and/g;
        } else{
            $logic =~ s/&&/ and /g;
        }
    }
    return $logic;
}

