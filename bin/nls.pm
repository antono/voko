package nls;

require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw(read_nls_cfg pop_utf8char first_utf8char last_utf8char 
	     defined_nls cmp_nls reverse_utf8 letter_nls letter_asci_nls
             convert_non_ascii replace to_utf8 utf8_hex nls_lingvoj); 



#read_nls_cfg("/home/revo/voko/cfg/nls.cfg");
#dump_nls_info("de");
#dump_nls_info("hu");
#dump_nls_info("eo");
#dump_nls_info("fr");
#dump_nls_info("ru");
#dump_nls_info("ko");

# $interpunkcio = '[\s,;\.:\(\)\-\'\/\?!\"]';
$interpunkcio = '[\s,;\.:\(\)\-\'\/\"]';

##################

# bytes | bits | representation
#     1 |    7 | 0vvvvvvv
#     2 |   11 | 110vvvvv 10vvvvvv
#     3 |   16 | 1110vvvv 10vvvvvv 10vvvvvv
#     4 |   21 | 11110vvv 10vvvvvv 10vvvvvv 10vvvvvv


# elprenas UTF-8-signon de la komenco de signaro
# kaj mallongigas ghin je unu litero

sub pop_utf8char {
    my $str_ref = \$_[0];
    my $chr;
    my $rez;
    
    #$$str_ref = reverse($$str_ref);
    $chr = ord(substr($$str_ref,0,1));
    
    if ($chr < 0x80) {
	$rez = substr($$str_ref,0,1);
    } elsif ($chr < 0xE0) {
	$rez = substr($$str_ref,0,2);
    } elsif ($chr < 0xF0) {
	$rez = substr($$str_ref,0,3);
    } else {
	$rez = substr($$str_ref,0,4);
    };
    
    $$str_ref = substr($$str_ref,length($rez));
    return $rez;  
}

# redonas UTF-8-signon de la komenco de signaro 
#  (sed ne shanghas la signaron)
sub first_utf8char {
    my $str = $_[0];
    return pop_utf8char($str);
}

# redonas UTF-8-signon de la fino de signaro 
#  (sed ne shanghas la signaron)
sub last_utf8char {
    my $str = $_[0];
    my $chr; 
    
    while ($str) {
	$chr = pop_utf8char($str);
    }
    
    return $chr;
}

sub reverse_utf8 {
    my $str = shift;
    my $result = '';

    while ($str) {
	$result = pop_utf8char($str) . $result;
    }

    return $result;
}


# transformas UTF-8-signon al deksesuma prezento
sub utf8_hex{
    my $chr = shift;
    my $format='0x%04X';
    
    if ($chr =~ /([\xC0-\xDF])([\x80-\xBF])/) {
	sprintf($format,
		unpack("c",$1)<<6&0x07C0|
		unpack("c",$2)&0x003F);
    } elsif ($chr =~ /([\xE0-\xEF])([\x80-\xBF])([\x80-\xBF])/) {
	sprintf($format,
		unpack("c",$1)<<12&0xF000|
		unpack("c",$2)<<6&0x0FC0|
		unpack("c",$3)&0x003F);
    } elsif ($chr =~ /([\xF0-\xF7])([\x80-\xBF])([\x80-\xBF])([\x80-\xBF])/) {
	sprintf($format,
		unpack("c",$1)<<18&0x1C0000|
		unpack("c",$2)<<12&0x3F000|
		unpack("c",$3)<<6&0x0FC0|
		unpack("c",$4)&0x003F);
    } else {
	sprintf($format,
		unpack("c",$chr));
    }
}

# komparu du signovicojn per nacilingva ordig-funkcio
sub cmp_nls {
    my ($vorto1,$vorto2,$lng) = @_;
    my $cmp;

    my $letters = \%{"letters_$lng"};
    my $aliases = \%{"aliases_$lng"};
    
    unless (defined %$letters) { 
	$letters = \%letters_la;
    }

    # ignoru interpunkcion
    $vorto1 =~ s/$interpunkcio//g;
    $vorto2 =~ s/$interpunkcio//g;

    if (defined %$aliases) {
	while (($from,$to)=each %$aliases) {
	    $vorto1 = replace($vorto1,$from,$to);
	    $vorto2 = replace($vorto2,$from,$to);
	}
    }
    
    # komparu krude (sen atento de uskleco kaj similaj diferencoj)
    my ($x,$y) = ($vorto1,$vorto2);
    do {
	$cmp = ( $x? (${$$letters{pop_utf8char($x)}}[0] || 99999) : 0 ) 
	    <=> ( $y? (${$$letters{pop_utf8char($y)}}[0] || 99999) : 0 );
        } while ($cmp == 0 and ($x or $y));
    
    # se la vortoj egalas, komparu pli subtile
    if ($cmp == 0) {
	# komparu krude (sen atento de uskleco kaj similaj diferencoj)
        my ($x,$y) = ($vorto1,$vorto2);
        do {
	    $cmp = ( $x? (${$$letters{pop_utf8char($x)}}[1] || 99999) : 0 ) 
	        <=> ( $y? (${$$letters{pop_utf8char($y)}}[1] || 99999) : 0 );
            } while ($cmp == 0 and ($x or $y));
    }
    
    return $cmp;
}

# sub kiu litero en alfabeto aperu vorto komencighanta kun $chr
# (plej ofte majuskloj kaj supersignaj literoj enordighas che la minuskloj)
sub letter_nls {
    my ($chr,$lng) = @_;
    my $letters = \%{"letters_$lng"};
    my $aliases = \%{"aliases_$lng"};

    unless (defined %$letters) {
	$letters = \%{"letters_la"};
    }
    
    if (defined %$aliases) {
	while (($from,$to)=each %$aliases) {
	    $chr = replace($chr,$from,$to); 
	}
    }
   
    if (defined %$letters) {
	return ( ${$$letters{first_utf8char($chr)}}[2] || '?' );
    } else {
	return lc(substr($chr,0,1));
    }
}

sub replace {
    my ($str,$from,$to) = @_;
    my $lfrom = length($from);
    my $lto = length($to);

    return $str unless($from);

    $pos = index($str,$from);
    while ($pos>=0) {
	$str = substr($str,0,$pos).$to.substr($str,$pos+$lfrom);
	$pos = index($str,$from,$pos+$lto);
    }

    return $str;
}


# ASCII-prezento de (minuskla) litero el la alfabeto,
# ekz. por dosiernomoj
sub letter_asci_nls {
    my ($chr,$lng) = @_;
    my $letters = \%{"letters_$lng"};
    my $aliases = \%{"aliases_$lng"};
    
    unless (defined %$letters) {
	$letters = \%{"letters_la"};
    }

    if (defined %$aliases) {
	while (($from,$to)=each %$aliases) {
	    $chr = replace($chr,$from,$to); 
	}
    }
       
    if (defined %$letters) {
	return ( ${$$letters{first_utf8char($chr)}}[3] || '0' );
    } else {
	$chr =~ s/[^A-Za-z]/0/; # specialaj signoj ne estu en dosiernomoj
	return $chr;
    }
}



# nur por testado

sub dump_nls_info {
    $lng = shift;

    print "[$lng]\n";

    foreach $ali (keys %{"aliases_$lng"}) {
        print "$ali=".${"aliases_$lng"}{$ali}."\n";
    }
#    foreach $lit (keys %{"letters_$lng"}) {
  foreach $lit (sort
      {cmp_nls($a,$b,$lng)}
      keys %{"letters_$lng"}) {

        print "$lit: ".join(',',@{${"letters_$lng"}{$lit}})."\n";
    }
    print "\n";
}

# legas la agordodosieron kun la lingvo-informoj
# pri ordigado kaj alfabeto

sub read_nls_cfg {
    $cfg_file = shift;
    my $lng='';
    my ($a,$b,$c);
    my $minusklo;
    my $min = 1;
    my $ascii;

    open CFG, $cfg_file or die "Ne povis malfermi \"$cfg_file\": $!\n";
    my @cfg = <CFG>;
    close CFG;

    my $cfg_path = $cfg_file;
    $cfg_path =~ s/\/[a-z\.]+$//;

    my $i = 0;
    while ($i < $#cfg) {
	my $line = $cfg[$i]; $i++;

	# inkludenda dosiero?
	if ($line =~ /^#include\s+([^\s]+)/) {
	    my $incl = $1;
	    unless (open CFG, "$cfg_path/$incl") {
		warn "Ne povis malfermi inkluddosieron \"$cfg_path/$incl\"\n";
		next;
	    }
	    splice(@cfg,$i,0,<CFG>);
	    close CFG;

	} elsif ($line !~ /^#|^\s*$/) { 
            # ignoru komentojn kaj malplenajn liniojn
	    
	    # chu nova lingvo-sekcio?
	    if ($line =~ /^\[([a-z]{2,3})\]\s*$/) {
		$lng = $1;
		($a,$b,$c)=(0,0,0);
		$min = 1;
	    }
	    # chu MAJ?
	    elsif ($line =~ /^MAJ\s*$/) {
		$min = 2;
	    }
	    # chu anstatauigo de litergrupo
	    elsif ($line =~ /^\+([^=]+)=([^\s]*)\s*$/) {
		${"aliases_$lng"}{convert_non_ascii($1)}=convert_non_ascii($2);
	    }
	    # estas liter-priskribo
            elsif ($line =~ /^([a-z]+):\s*(.*)\s*$/) {
		$ascii = $1;
		$a++;
		my $priskribo = $2;
		
		# chu temas pri intervalo? (aziaj lingvoj)
		if ($priskribo =~ /\[\s*(.*?)\s*,\s*(.*?)\s*\]/) {

		    # eltrovu la intervallimojn
		    my ($from,$to) = ($1,$2);
		    unless ($from =~ /\\u([a-f0-9]{4})/i) {
			die "Sintakseraro: interlimojn indiku per \uffff\n";
		    }
		    $from = hex($1);
		    unless ($to =~ /\\u([a-f0-9]{4})/i) {
			die "Sintakseraro: interlimojn indiku per \uffff\n";
		    }
		    $to = hex($1);

		    # plenigu la literotabelon
		    $minusklo = int_utf8($from);
		    for ($j = $from; $j<=$to; $j++) {
			${"letters_$lng"}{int_utf8($j)}=
			    [1000*$a+($j-$from),1000*$a+($j-$from),
			     $minusklo,$ascii];
	            }
		} else {
		
		    # temas pri unuopaj literoj
		    ($b,$c) = (0,0);
		    $minusklo = '';
		    @literoj = split(',',$priskribo);

		    foreach $litgrp (@literoj) {
			$b++; $c=0;
			$litgrp =~ s/^\s*//;
			$litgrp =~ s/\s*$//;
			
			$minusklo = convert_non_ascii(
			   (split /\s+/, $litgrp)[$min -1]) unless($minusklo);
			# renversu alinomigon
			while (($from,$to)=each %{"aliases_$lng"}) {
			    if ($to) { 
				$minusklo = replace($minusklo,$to,$from);
			    }
			}

			foreach $lit (split /\s+/, $litgrp) {
			    $c++;
			    $lit = convert_non_ascii($lit);
			    ${"letters_$lng"}{$lit}=
				[100*$a+10*$b,100*$a+10*$b+$c,$minusklo,$ascii];
		        }
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

sub convert_non_ascii {
    my $text = shift;

    $text =~ s/([\200-\377])/to_utf8("\000$1")/ieg;
    $text =~ s/\\u([a-f0-9]{4})/hex_utf8($1)/ieg;
   
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

# kontrolas cxu lingvo $lng estas difinita
# redonas la difinojn tiuokaze
sub defined_nls {
  my $lng = shift;
  my $letters = \%{"letters_$lng"};
  my $aliases = \%{"aliases_$lng"};

  return unless (%$letters);

  my (%letr, @desc);

  while (($lit,$d)=each(%$letters)) {
      my @desc = @$d;
      if (defined %$aliases) {
	  while (($from,$to)=each %$aliases) {
	      if ($to) { 
		  $lit = replace($lit,$to,$from); 
		  $desc[2] = replace($desc[2],$to,$from)
		  }
	  }
      }
      $letr{$lit}=\@desc;
  }

  return %letr;
}


