#!/usr/bin/perl

read_nls_cfg("/home/revo/voko/bin/nls.cfg");
#dump_nls_info("eo");
dump_nls_info("fr");

sub dump_nls_info {
    $lng = shift;

    print "[$lng]\n";

    foreach $ali (keys %{"aliases_$lng"}) {
        print "$ali=".${"aliases_$lng"}{$ali}."\n";
    }
    foreach $lit (keys %{"letters_$lng"}) {
        print "$lit: ".join(',',@{${"letters_$lng"}{$lit}})."\n";
    }
    print "\n";
}

sub read_nls_cfg {
    $cfg_file = shift;
    my $lng='';
    my ($a,$b,$c);

    open CFG, $cfg_file or die "Ne povis malfermi \"$cfg_file\": $!\n";
    while ($line=<CFG>) {
	if ($line !~ /^#|^\s*$/) { 
                   # ignoru komantariojn kaj malplenajn liniojn
	    
	    # chu nova lingvo-sekcio?
	    if ($line =~ /^\[(..)\]\s*$/) {
		$lng = $1;
		($a,$b,$c)=(0,0,0);
	    }
	    # chu anstatauigo de litergrupo
	    elsif ($line =~ /^\+([^=]+)=(.*)$/) {
		${"aliases_$lng"}{traduce_non_ascii($1)}=traduce_non_ascii($2);
	    }
	    # chu liter-priskribo
            elsif ($line =~ /^([a-z]+):\s*(.*)\s*$/) {
		$ascii = $1;
		$a++; ($b,$c) = (0,0);
		@literoj = split(',',$2);
		foreach $litgrp (@literoj) {
		    $b++; $c=0;
		    $litgrp =~ s/^\s*//;
		    $litgrp =~ s/\s*$//;
		    foreach $lit (split /\s+/, $litgrp) {
			$c++;
			$lit = traduce_non_ascii($lit);
			${"letters_$lng"}{$lit}=
			    [100*$a+10*$b,100*$a+10*$b+$c,$ascii];
		    }
		}
	    } 
	    # erara linio
            else {
		die "Sintakseraro en linio $.: \"$line\"\n";
	    }
        }
    }
    close CFG;
}

sub traduce_non_ascii {
    my $text = shift;

    $text =~ s/\\u([a-f0-9]{4})/hex_utf8($1)/ieg;
    $text =~ s/([\200-\377])/to_utf8("\000$1")/ieg;
   
    return $text;
}

# tranformas unuopan unikodan signon al UTF8
sub to_utf8 {
    my $uchr = $_[0];
    my $uval = ord($uchr)*256+ord(substr($uchr,1,1)); 
    my $chrs = '';
    
    if ($uval < 0x80) {
	$chrs .= ($uchr);
    }
    elsif ($uval < 0x800) {
	$chrs .= chr(0xC0 | $uval >> 6);
	$chrs .= chr(0x80 | $uval & 0x3F);
    }
    elsif ($uval < 0x10000) {
	$chrs .= chr(0xE0 | $uval >> 12);
	$chrs .= chr(0x80 | $uval >> 6 & 0x3F);
	$chrs .= chr(0x80 | $uval & 0x3F);
    }
    elsif ($uval < 0x200000) {
	$chrs .= chr(0xF0 | $uval >> 18);
	$chrs .= chr(0x80 | $uval >> 12 & 0x3F);
	$chrs .= chr(0x80 | $uval >> 6 & 0x3F);
	$chrs .= chr(0x80 | $uval & 0x3F);
    }

    return $chrs;
}


# transformas entjeran valoron de unikoda signo al UTF-8
# (tre simile al to_utf8, ne uzata momente)
sub int_utf8 { 
    my($c)=@_;
    return $c < 0x80 ? chr($c) : 
        $c < 0x800 ? chr($c >>6&0x3F|0xC0) . chr($c & 0x3F | 0x80) :
            chr($c >>12&0x0F|0xE0).chr($c >>6&0x3F|0x80).chr($c &0x3F|0x80);
} 

# transformas deksesuman prezenton de unikoda signo al UTF-8
sub hex_utf8 {
    int_utf8(hex($_[0]));
}
