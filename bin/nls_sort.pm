package nls_sort;

require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw(pop_utf8char first_utf8char last_utf8char 
	     cmp_nls reverse_utf8 letter_nls letter_asci_nls); 
#@EXPORT_OK = qw(...);         # symbols to export on request
#%EXPORT_TAGS = tag => [...];  # define names for sets of symbols
                                                                              

$debug = 0;


################ tests ###############

# print to_utf8("\000Ä"), "\n";
# print to_utf8("\001\010"), "=\304\210\n";

#$str = "sch".to_utf8("\000ö")."nes Beispiel.\n";
#for ($i=0; $i<10; $i++) {
#  print "$i: ", pop_utf8char($str), " ", $str, "\n";
#}


#print "schon <=> schonen = ", cmp_nls("schon","schonen","de"), "\n";
#print "schonen <=> schöne = ", cmp_nls("schonen","sch".to_utf8("\000ö")."ne","de"), "\n";
#print "alt <=> schön = ", cmp_nls("alt","sch".to_utf8("\000ö")."n","de"), "\n";

#$sz = to_utf8("\000ß");
#$oe = to_utf8("\000ö");
#$ae = to_utf8("\000ä");
#$Ae = to_utf8("\000Ä");
#$Cx = to_utf8("\001\010");
#$cx = to_utf8("\001\011");

#@woerter = ("sch${oe}n","alt","${ae}lt","Alt","${Ae}lt","sch${oe}ne","schonen","zwei","schon","Bi${sz}","bis","Biss","Schon","Bis");
#print join(",",sort { cmp_nls($a,$b,"de") } @woerter), "\n";

#@vortoj = ("${cx}i", "ci", "Ci", "${Cx}i", "dio", "Dio", "abelo");
#print join(",",sort { cmp_nls($a,$b,"eo") } @vortoj), "\n";
#print join(",",sort { cmp_nls($a,$b,"la") } @vortoj), "\n";

#@words = ("Ape","ape","ant","apple","Apple");
#print join(",",sort { cmp_nls($a,$b,"en") } @words), "\n";

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
    
    $$str_ref = reverse($$str_ref);
    $chr = chop $$str_ref;
    
    if (ord($chr) < 0x80) {
	# nothing
    } elsif (ord($chr) < 0xD0) {
	$chr .= chop $$str_ref;
    } elsif (ord($chr) < 0xF0) {
	$chr .= chop $$str_ref;
	$chr .= chop $$str_ref;
    } else {
	$chr .= chop $$str_ref;
	$chr .= chop $$str_ref;
	$chr .= chop $$str_ref;
    };
    
    $$str_ref = reverse($$str_ref);
    return $chr;  
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

# komparu du signarojn per nacilingva ordig-funkcio
sub cmp_nls {
    my ($w1,$w2,$lng) = @_;
    my $cmp;
    my $fnc = \&{"letterval_$lng"};
    my $prep = \&{"sortprep_$lng"};
    
    unless (defined &$fnc) { 
	$fnc = \&letterval_en;
    }

    if (defined &$prep) {
	$w1 = &$prep($w1);
	$w2 = &$prep($w2);
    }
    
    # komparu krude (sen atento de uskleco kaj similaj diferencoj)
    my ($x,$y) = ($w1,$w2);
    do {
	$cmp = &$fnc(pop_utf8char($x),1) <=> &$fnc(pop_utf8char($y),1);
    } while ($cmp == 0 and ($x or $y));
    
    # se la vortoj egalas, komparu pli subtile
    if ($cmp == 0) {
	# komparu krude (sen atento de uskleco kaj similaj diferencoj)
	my ($x,$y) = ($w1,$w2);
	do {
	    $cmp = &$fnc(pop_utf8char($x),2) <=> &$fnc(pop_utf8char($y),2);
	} while ($cmp == 0 and ($x or $y));
    }
    
    return $cmp;
}

# sub kiu litero en alfabeto aperu vorto komencighanta kun $chr
# (plej ofte majuskloj kaj supersignaj literoj enordighas che la minuskloj)
sub letter_nls {
    my ($chr,$lng) = @_;
    my $fnc = \&{"letter_$lng"};
    
    if (defined &$fnc) {
	return &$fnc($chr);
    } else {
	return lc(substr($chr,0,1));
    }
}

# ASCII-prezento de (minuskla) litero el la alfabeto,
# ekz. por dosiernomoj
sub letter_asci_nls {
    my ($chr,$lng) = @_;
    my $fnc = \&{"letter_asci_$lng"};
    
    if (defined &$fnc) {
	return &$fnc($chr);
    } else {
	return $chr;
    }
}


########################## germana ###########################

my %values_de_1 = (
    to_utf8("\000Ä") => 10*ord('a'),    # Ä egalas a
    to_utf8("\000ä") => 10*ord('a'),    # ä egalas a
    to_utf8("\000Ö") => 10*ord('o'),    # Ö egalas o
    to_utf8("\000ö") => 10*ord('o'),    # ö egalas o
    to_utf8("\000Ü") => 10*ord('u'),    # Ü egalas u
    to_utf8("\000ü") => 10*ord('u'),    # ü egalas u
    to_utf8("\000ß") => 10*ord('s')+1   # ß post s
    );

my %values_de_2 = (
    to_utf8("\000Ä") => 10*ord('a')+3,    # Ä post ä
    to_utf8("\000ä") => 10*ord('a')+2,    # ä post A
    to_utf8("\000Ö") => 10*ord('o')+3,    # Ö post ö
    to_utf8("\000ö") => 10*ord('o')+2,    # ö post O
    to_utf8("\000Ü") => 10*ord('u')+3,    # Ü post ü
    to_utf8("\000ü") => 10*ord('u')+2,    # ü post U
    to_utf8("\000ß") => 10*ord('s')+2     # ß post S
    );

my %values_de_3 = (
    to_utf8("\000Ä") => 'a', 
    to_utf8("\000ä") => 'a',
    to_utf8("\000Ö") => 'o',
    to_utf8("\000ö") => 'o',
    to_utf8("\000Ü") => 'u',
    to_utf8("\000ü") => 'u' 
    );

sub letterval_de {
    my ($chr,$level) = @_;
    my ($offset,$values);
    
    if ($level == 1) {
	$values = \%values_de_1; # kruda
	$offset = 0;
    } else {
	$values = \%values_de_2; # subtila
	$offset = 1;
    };
    
    if (! $chr) {
	return 0;
    } elsif (ord($chr) >= ord('a') and ord($chr) <= ord('z')) {
	return 10 * ord($chr);
    } elsif (ord($chr) >= ord('A') and ord($chr) <= ord('Z')) {
	return 10 * ord(lc($chr)) + $offset;
    } elsif ( exists $$values{$chr} ) {
	return $$values{$chr};
    } else {
	return 9999;
    }
}


sub letter_de {
    my $letter =  first_utf8char(shift);
    my $chr;

    if (ord($letter) >= ord('a') and ord($letter) <= ord('z')) {
	return $letter;
    } elsif (ord($letter) >= ord('A') and ord($letter) <= ord('Z')) {
	return lc($letter);
    } elsif ( exists $values_de_3{$letter} ) {
	return $values_de_3{$letter};
    } else {
	return '0';
    }
}

######################### angla #####################

sub letterval_en {
    my ($chr,$level) = @_;
    my $offset;
    
    if ($level == 1) {
	$offset = 0;
    } else {
	$offset = 1;
    };
    
    if (! $chr) {
	return 0;
    } elsif (ord($chr) >= ord('a') and ord($chr) <= ord('z')) {
	return 10 * ord($chr);
    } elsif (ord($chr) >= ord('A') and ord($chr) <= ord('Z')) {
	return 10 * ord(lc($chr)) - $offset;
    } else {
	return 9999;
    }
}

sub letter_en {
    my $letter =  first_utf8char(shift);
    my $chr;

    if (ord($letter) >= ord('a') and ord($letter) <= ord('z')) {
	return $letter;
    } elsif (ord($letter) >= ord('A') and ord($letter) <= ord('Z')) {
	return lc($letter);
    } else {
	return "0";
    }
}


##################### Esperanto #####################

my %values_eo_1 = (
    to_utf8("\001\010") => 10*ord('c')+1, # Cx post c
    to_utf8("\001\011") => 10*ord('c')+1, # cx post c
    to_utf8("\001\034") => 10*ord('g')+1, # Gx post g
    to_utf8("\001\035") => 10*ord('g')+1, # gx post g
    to_utf8("\001\044") => 10*ord('h')+1, # Hx post h
    to_utf8("\001\045") => 10*ord('h')+1, # hx post h
    to_utf8("\001\064") => 10*ord('j')+1, # Jx post j
    to_utf8("\001\065") => 10*ord('j')+1, # jx post j
    to_utf8("\001\134") => 10*ord('s')+1, # Sx post s
    to_utf8("\001\135") => 10*ord('s')+1, # sx post s
    to_utf8("\001\154") => 10*ord('u')+1, # Ux post u
    to_utf8("\001\155") => 10*ord('u')+1  # ux post u
  );
my %values_eo_2 = (
    to_utf8("\001\010") => 10*ord('c')+1, # Cx post c
    to_utf8("\001\011") => 10*ord('c')+2, # cx post Cx
    to_utf8("\001\034") => 10*ord('g')+1, # Gx post g
    to_utf8("\001\035") => 10*ord('g')+2, # gx post Gx
    to_utf8("\001\044") => 10*ord('h')+1, # Hx post h
    to_utf8("\001\045") => 10*ord('h')+2, # hx post Hx
    to_utf8("\001\064") => 10*ord('j')+1, # Jx post j
    to_utf8("\001\065") => 10*ord('j')+2, # jx post Jx
    to_utf8("\001\134") => 10*ord('s')+1, # Sx post s
    to_utf8("\001\135") => 10*ord('s')+2, # sx post Sx
    to_utf8("\001\154") => 10*ord('u')+1, # Ux post u
    to_utf8("\001\155") => 10*ord('u')+2  # ux post Ux
  );


sub letterval_eo {
    my ($chr,$level) = @_;
    my $offset;
    my $values;
    
    if ($level == 1) {
	$values = \%values_eo_1; # kruda
	$offset = 0;
    } else {
	$values = \%values_eo_2; # subtila
	$offset = 1;
    };
    
    if (! $chr) {
	return 0;
    } elsif (ord($chr) >= ord('a') and ord($chr) <= ord('z')) {
	return 10 * ord($chr);
    } elsif (ord($chr) >= ord('A') and ord($chr) <= ord('Z')) {
	return 10 * ord(lc($chr)) - $offset;
    } elsif ( exists $$values{$chr} ) {
	return $$values{$chr};
    } else {
	return 9999;
    }
}

sub letter_eo {
    my $letter =  first_utf8char(shift);

    if (ord($letter) >= ord('a') and ord($letter) <= ord('z')) {
	return $letter;
    } elsif (ord($letter) >= ord('A') and ord($letter) <= ord('Z')) {
	return lc($letter);
    } elsif ($letter =~ /\304[\210\211]/) {
	return "\304\211";
    } elsif ($letter =~ /\304[\234\235]/) {
	return "\304\235";
    } elsif ($letter =~ /\304[\244\245]/) {
	return "\304\245";
    } elsif ($letter =~ /\304[\264\265]/) {
	return "\304\265";
    } elsif ($letter =~ /\305[\234\235]/) {
	return "\305\235";
    } elsif ($letter =~ /\305[\254\255]/) {
	return "\305\255";
    } else {
	return "0";
    }
}

sub letter_asci_eo {
    my $chr = shift;
    $chr =~ s/\304\210/Cx/g;
    $chr =~ s/\304\234/Gx/g;
    $chr =~ s/\304\244/Hx/g;
    $chr =~ s/\304\264/Jx/g;
    $chr =~ s/\305\234/Sx/g;
    $chr =~ s/\305\254/Ux/g;
    $chr =~ s/\304\211/cx/g;
    $chr =~ s/\304\235/gx/g;
    $chr =~ s/\304\245/hx/g;
    $chr =~ s/\304\265/jx/g;
    $chr =~ s/\305\235/sx/g;
    $chr =~ s/\305\255/ux/g;      
    return $chr;
}


############################ franca ############################

 my %values_fr_1 = (
    to_utf8("\000Á") => 10*ord('a'),    # Á egalas a
    to_utf8("\000á") => 10*ord('a'),    # á egalas a
    to_utf8("\000À") => 10*ord('a'),    # À egalas a
    to_utf8("\000à") => 10*ord('a'),    # à egalas a
    to_utf8("\000Â") => 10*ord('a'),    # Â egalas a
    to_utf8("\000â") => 10*ord('a'),    # â egalas a

    to_utf8("\000É") => 10*ord('e'),    # É egalas e
    to_utf8("\000é") => 10*ord('e'),    # é egalas e
    to_utf8("\000È") => 10*ord('e'),    # È egalas e
    to_utf8("\000è") => 10*ord('e'),    # è egalas e
    to_utf8("\000Ê") => 10*ord('e'),    # Ê egalas e
    to_utf8("\000ê") => 10*ord('e'),    # ê egalas e

    to_utf8("\000Í") => 10*ord('i'),    # Í egalas i
    to_utf8("\000í") => 10*ord('i'),    # í egalas i
    to_utf8("\000Ì") => 10*ord('i'),    # Ì egalas i
    to_utf8("\000ì") => 10*ord('i'),    # ì egalas i
    to_utf8("\000Î") => 10*ord('i'),    # Î egalas i
    to_utf8("\000î") => 10*ord('i'),    # î egalas i

    to_utf8("\000Ó") => 10*ord('o'),    # Ó egalas o
    to_utf8("\000ó") => 10*ord('o'),    # ó egalas o
    to_utf8("\000Ò") => 10*ord('o'),    # Ò egalas o
    to_utf8("\000ò") => 10*ord('o'),    # ò egalas o
    to_utf8("\000Ô") => 10*ord('o'),    # Ô egalas o
    to_utf8("\000ô") => 10*ord('o'),    # ô egalas o

    to_utf8("\000Ú") => 10*ord('u'),    # Ú egalas u
    to_utf8("\000ú") => 10*ord('u'),    # ú egalas u
    to_utf8("\000Ù") => 10*ord('u'),    # Ù egalas u
    to_utf8("\000ù") => 10*ord('u'),    # ù egalas u
    to_utf8("\000Û") => 10*ord('u'),    # Û egalas u
    to_utf8("\000û") => 10*ord('u')     # û egalas u            
		    );
                       
 my %values_fr_2 = (
    to_utf8("\000Á") => 10*ord('a')+1,    # Á post a
    to_utf8("\000á") => 10*ord('a')+2,    # á post Á
    to_utf8("\000À") => 10*ord('a')+1,    # À post a
    to_utf8("\000à") => 10*ord('a')+2,    # à post À
    to_utf8("\000Â") => 10*ord('a')+1,    # Â post a
    to_utf8("\000â") => 10*ord('a')+2,    # â post Â

    to_utf8("\000É") => 10*ord('e')+1,    # É post e
    to_utf8("\000é") => 10*ord('e')+2,    # é post É
    to_utf8("\000È") => 10*ord('e')+1,    # È post e
    to_utf8("\000è") => 10*ord('e')+2,    # è post È
    to_utf8("\000Ê") => 10*ord('e')+1,    # Ê post e
    to_utf8("\000ê") => 10*ord('e')+2,    # ê post Ê

    to_utf8("\000Í") => 10*ord('i')+1,    # Í post i
    to_utf8("\000í") => 10*ord('i')+2,    # í post Í
    to_utf8("\000Ì") => 10*ord('i')+1,    # Ì post i
    to_utf8("\000ì") => 10*ord('i')+2,    # ì post Ì
    to_utf8("\000Î") => 10*ord('i')+1,    # Î post i
    to_utf8("\000î") => 10*ord('i')+2,    # î post Î

    to_utf8("\000Ó") => 10*ord('o')+1,    # Ó post o
    to_utf8("\000ó") => 10*ord('o')+2,    # ó post Ó
    to_utf8("\000Ò") => 10*ord('o')+1,    # Ò post o
    to_utf8("\000ò") => 10*ord('o')+2,    # ò post Ò
    to_utf8("\000Ô") => 10*ord('o')+1,    # Ô post o
    to_utf8("\000ô") => 10*ord('o')+2,    # ô post Ô

    to_utf8("\000Ú") => 10*ord('u')+1,    # Ú post u
    to_utf8("\000ú") => 10*ord('u')+2,    # ú post Ú
    to_utf8("\000Ù") => 10*ord('u')+1,    # Ù post u
    to_utf8("\000ù") => 10*ord('u')+2,    # ù post Ù
    to_utf8("\000Û") => 10*ord('u')+1,    # Û post u
    to_utf8("\000û") => 10*ord('u')+2,    # û post Û   
		    );

 my %values_fr_3 = (
    to_utf8("\000Á") => 'a', 
    to_utf8("\000á") => 'a', 
    to_utf8("\000À") => 'a', 
    to_utf8("\000à") => 'a', 
    to_utf8("\000Â") => 'a', 
    to_utf8("\000â") => 'a', 

    to_utf8("\000É") => 'e', 
    to_utf8("\000é") => 'e', 
    to_utf8("\000È") => 'e', 
    to_utf8("\000è") => 'e', 
    to_utf8("\000Ê") => 'e', 
    to_utf8("\000ê") => 'e', 

    to_utf8("\000Í") => 'i', 
    to_utf8("\000í") => 'i', 
    to_utf8("\000Ì") => 'i', 
    to_utf8("\000ì") => 'i', 
    to_utf8("\000Î") => 'i', 
    to_utf8("\000î") => 'i', 

    to_utf8("\000Ó") => 'o', 
    to_utf8("\000ó") => 'o', 
    to_utf8("\000Ò") => 'o', 
    to_utf8("\000ò") => 'o', 
    to_utf8("\000Ô") => 'o', 
    to_utf8("\000ô") => 'o', 
    to_utf8("\001\122") => 'o',
    to_utf8("\001\123") => 'o',    

    to_utf8("\000Ú") => 'u', 
    to_utf8("\000ú") => 'u', 
    to_utf8("\000Ù") => 'u', 
    to_utf8("\000ù") => 'u', 
    to_utf8("\000Û") => 'u', 
    to_utf8("\000û") => 'u' 
    );

$OElig = to_utf8("\001\122");
$oelig = to_utf8("\001\123");

sub sortprep_fr {
    my $w = shift;

    print "$w -> " if ($debug);

    $w =~ s/$OElig/Oe/g;
    $w =~ s/$oelig/oe/g;

    print "-> $w\n" if ($debug);

    return $w;
}

sub letterval_fr {
    my ($chr,$level) = @_;
    my $offset;
    my $values;
    
    if ($level == 1) {
	$values = \%values_fr_1; # kruda
	$offset = 0;
    } else {
	$values = \%values_fr_2; # subtila
	$offset = 1;
    };
    
    if (! $chr) {
	return 0;
    } elsif (ord($chr) >= ord('a') and ord($chr) <= ord('z')) {
	return 10 * ord($chr);
    } elsif (ord($chr) >= ord('A') and ord($chr) <= ord('Z')) {
	return 10 * ord(lc($chr)) - $offset;
    } elsif ( exists $$values{$chr} ) {
	return $$values{$chr};
    } else {
	return 9999;
    }
}

sub letter_fr {
    my $letter =  first_utf8char(shift);
    my $chr;

    if (ord($letter) >= ord('a') and ord($letter) <= ord('z')) {
	return $letter;
    } elsif (ord($letter) >= ord('A') and ord($letter) <= ord('Z')) {
	return lc($letter);
    } elsif ( exists $values_fr_3{$letter} ) {
	return $values_fr_3{$letter};
    } else {
	return '0';
    }
}

######################### rusa ############################

my %values_ru_3 = (
		    0x0430 => 'a',
		    0x0431 => 'b',
		    0x0432 => 'v',
		    0x0433 => 'g',
		    0x0434 => 'd',
		    0x0435 => 'je',
		    0x0436 => 'zh',
		    0x0437 => 'z',
		    0x0438 => 'i',
		    0x0439 => 'j',
		    0x043a => 'k',
		    0x043b => 'l',
		    0x043c => 'm',
		    0x043d => 'n',
		    0x043e => 'o',
		    0x043f => 'p',
		    0x0440 => 'r',
		    0x0441 => 's',
		    0x0442 => 't',
		    0x0443 => 'u',
		    0x0444 => 'f',
		    0x0445 => 'h',
		    0x0446 => 'c',
		    0x0447 => 'ch',
		    0x0448 => 'sh',
		    0x0449 => 'shch',
		    0x044a => 'mm',
		    0x044b => 'y',
		    0x044c => 'mo',
		    0x044d => 'e',
		    0x044e => 'ju',
		    0x044f => 'ja'
		    );

sub letterval_ru {
    my ($chr,$level) = @_;
    my $uval = hex(utf8_hex($chr));
    
    if ($level == 1) {
	if ( 0x410 <= $uval and $uval <= 0x42f ) { #majusklo
	    return 10*$uval;
	} elsif ( 0x430 <= $uval and $uval <= 0x44f) { #minuklo
	    return 10*($uval - 0x20);
	} else {
	    return 999999;
	}
    } else {
	if ( 0x410 <= $uval and $uval <= 0x42f ) { #majusklo
	    return 10*$uval + 1;
	} elsif ( 0x430 <= $uval and $uval <= 0x44f) { #minuklo
	    return 10*($uval - 0x20);
	} else {
	    return 999999;
	}
    };
}

sub letter_ru {
    my $letter =  first_utf8char(shift);
    my $uval = hex(utf8_hex($letter));
    
    if ( 0x410 <= $uval and $uval <= 0x42f ) { #majusklo
	return int_utf8($uval + 0x20);
    } elsif ( 0x430 <= $uval and $uval <= 0x44f) { #minuklo
	return int_utf8($uval);
    } else {
	return 0;
    }
}

sub letter_asci_ru {
    return $values_ru_3{hex(utf8_hex($_[0]))};
}



############################ turka ############################

 my %values_tr_1 = (
    to_utf8("\000Â") => 10*ord('a'),    # Â egalas a
    to_utf8("\000â") => 10*ord('a'),    # â egalas a

    to_utf8("\000Ç") => 10*ord('c')+5,    # Ç post c
    to_utf8("\000ç") => 10*ord('c')+5,    # ç post c
    to_utf8("\001\036") => 10*ord('g')+5, # G~ post g
    to_utf8("\001\037") => 10*ord('g')+5, # g~ post g

    "I" => 10*ord('h')+5,               # I post h
    to_utf8("\001\061") => 10*ord('h')+5, # i sen . post h
    to_utf8("\001\060") => 10*ord('i'), # I. egalas i
    "i" => 10*ord('i'),                 # i egalas i	    
    to_utf8("\000Î") => 10*ord('i'),    # Î egalas i
    to_utf8("\000î") => 10*ord('i'),    # î egalas i

    to_utf8("\000Ö") => 10*ord('o')+5,  # Ö post o
    to_utf8("\000ö") => 10*ord('o')+5,  # ö post o
    to_utf8("\001\136") => 10*ord('s')+5, # S, post s
    to_utf8("\001\137") => 10*ord('s')+5, # s, post s

    to_utf8("\000Û") => 10*ord('u'),    # Û egalas u
    to_utf8("\000û") => 10*ord('u'),    # û egalas u
    to_utf8("\000Ü") => 10*ord('u')+5,    # Ü post u
    to_utf8("\000ü") => 10*ord('u')+5,    # ü post u
		    );
                       

 my %values_tr_2 = (
    to_utf8("\000Â") => 10*ord('a')+1,    # Â post a
    to_utf8("\000â") => 10*ord('a')+2,    # â post Â

    to_utf8("\000Ç") => 10*ord('c')+5,    # Ç post c
    to_utf8("\000ç") => 10*ord('c')+6,    # ç post Ç
    to_utf8("\001\036") => 10*ord('g')+5, # G~ post g
    to_utf8("\001\037") => 10*ord('g')+6, # g~ post G~

    "I" => 10*ord('h')+5,               # I post h
    to_utf8("\001\061") => 10*ord('h')+6, # i sen . post I
    to_utf8("\001\060") => 10*ord('i')-1, # I. antau i
    "i" => 10*ord('i'),                 # i egalas i	
    to_utf8("\000Î") => 10*ord('i')+1,    # Î post i
    to_utf8("\000î") => 10*ord('i')+2,    # î post Î

    to_utf8("\000Ö") => 10*ord('o')+5,  # Ö post o
    to_utf8("\000ö") => 10*ord('o')+6,  # ö post Ö
    to_utf8("\001\136") => 10*ord('s')+5, # S, post s
    to_utf8("\001\137") => 10*ord('s')+6, # s, post S,

    to_utf8("\000Û") => 10*ord('u')+1,    # Û post u
    to_utf8("\000û") => 10*ord('u')+2,    # û post Û
    to_utf8("\000Ü") => 10*ord('u')+5,    # Ü post u
    to_utf8("\000ü") => 10*ord('u')+6,    # ü post Ü
		    );

 my %values_tr_3 = (
    to_utf8("\000Â") => 'a',
    to_utf8("\000â") => 'a',

    to_utf8("\000Ç") => to_utf8("\000ç"),
    to_utf8("\000ç") => to_utf8("\000ç"),
    to_utf8("\001\036") => to_utf8("\001\037"),
    to_utf8("\001\037") => to_utf8("\001\037"),

    "I" => to_utf8("\001\061"),
    to_utf8("\001\061") =>to_utf8("\001\061"),
    to_utf8("\001\060") => 'i',
    "i" => 'i',
    to_utf8("\000Î") => 'i',
    to_utf8("\000î") => 'i',

    to_utf8("\000Ö") => to_utf8("\000ö"),
    to_utf8("\000ö") => to_utf8("\000ö"),
    to_utf8("\001\136") => to_utf8("\001\137"),
    to_utf8("\001\137") => to_utf8("\001\137"),

    to_utf8("\000Û") => 'u',
    to_utf8("\000û") => 'u',
    to_utf8("\000Ü") => to_utf8("\000ü"),
    to_utf8("\000ü") => to_utf8("\000ü"),
    );

sub letterval_tr {
    my ($chr,$level) = @_;
    my $offset;
    my $values;
    
    if ($level == 1) {
	$values = \%values_tr_1; # kruda
	$offset = 0;
    } else {
	$values = \%values_tr_2; # subtila
	$offset = 1;
    };
    
    if (! $chr) {
	return 0;
    } elsif (ord($chr) >= ord('a') and ord($chr) <= ord('z') 
	     and ($chr ne 'i')) {
	return 10 * ord($chr);
    } elsif (ord($chr) >= ord('A') and ord($chr) <= ord('Z')
	     and ($chr ne 'I')) {
	return 10 * ord(lc($chr)) - $offset;
    } elsif ( exists $$values{$chr} ) {
	return $$values{$chr};
    } else {
	return 9999;
    }
}

sub letter_tr {
    my $letter =  first_utf8char(shift);
    my $chr;

    if (ord($letter) >= ord('a') and ord($letter) <= ord('z')
	and ($letter ne 'i')) {
	return $letter;
    } elsif (ord($letter) >= ord('A') and ord($letter) <= ord('Z')
	     and ($letter ne 'I')) {
	return lc($letter);
    } elsif ( exists $values_tr_3{$letter} ) {
	return $values_tr_3{$letter};
    } else {
	return '0';
    }
}

sub letter_asci_tr {
    my $chr = shift;

    $chr = letter_tr($chr);
    
    if ($chr eq to_utf8("\000ç"))       { return 'cx'; }
    elsif ($chr eq to_utf8("\001\037")) { return 'gx'; }
    elsif ($chr eq to_utf8("\001\061")) { return 'ix'; }
    elsif ($chr eq to_utf8("\000ö"))    { return 'ox'; }
    elsif ($chr eq to_utf8("\001\137")) { return 'sx'; }  
    elsif ($chr eq to_utf8("\000ü"))    { return 'ux'; }
    else                                { return $chr; }
}


########################## pola ###########################

my %values_pl_1 = (
    to_utf8("\000Ä") => 10*ord('a'),    # Ä egalas a
    to_utf8("\000ä") => 10*ord('a'),    # ä egalas a
    to_utf8("\000Ö") => 10*ord('o'),    # Ö egalas o
    to_utf8("\000ö") => 10*ord('o'),    # ö egalas o
    to_utf8("\000Ü") => 10*ord('u'),    # Ü egalas u
    to_utf8("\000ü") => 10*ord('u'),    # ü egalas u
    to_utf8("\000ß") => 10*ord('s')+1   # ß post s
    );

my %values_pl_2 = (
    to_utf8("\000Ä") => 10*ord('a')+3,    # Ä post ä
    to_utf8("\000ä") => 10*ord('a')+2,    # ä post A
    to_utf8("\000Ö") => 10*ord('o')+3,    # Ö post ö
    to_utf8("\000ö") => 10*ord('o')+2,    # ö post O
    to_utf8("\000Ü") => 10*ord('u')+3,    # Ü post ü
    to_utf8("\000ü") => 10*ord('u')+2,    # ü post U
    to_utf8("\000ß") => 10*ord('s')+2     # ß post S
    );

my %values_pl_3 = (
    to_utf8("\000Ä") => 'a', 
    to_utf8("\000ä") => 'a',
    to_utf8("\000Ö") => 'o',
    to_utf8("\000ö") => 'o',
    to_utf8("\000Ü") => 'u',
    to_utf8("\000ü") => 'u' 
    );

sub letterval_pl {
    my ($chr,$level) = @_;
    my ($offset,$values);
    
    if ($level == 1) {
	$values = \%values_pl_1; # kruda
	$offset = 0;
    } else {
	$values = \%values_pl_2; # subtila
	$offset = 1;
    };
    
    if (! $chr) {
	return 0;
    } elsif (ord($chr) >= ord('a') and ord($chr) <= ord('z')) {
	return 10 * ord($chr);
    } elsif (ord($chr) >= ord('A') and ord($chr) <= ord('Z')) {
	return 10 * ord(lc($chr)) + $offset;
    } elsif ( exists $$values{$chr} ) {
	return $$values{$chr};
    } else {
	return 9999;
    }
}


sub letter_pl {
    my $letter =  first_utf8char(shift);
    my $chr;

    if (ord($letter) >= ord('a') and ord($letter) <= ord('z')) {
	return $letter;
    } elsif (ord($letter) >= ord('A') and ord($letter) <= ord('Z')) {
	return lc($letter);
    } elsif ( exists $values_pl_3{$letter} ) {
	return $values_pl_3{$letter};
    } else {
	return '0';
    }
}

########################## hungara ###########################

my %values_hu_1 = (
    to_utf8("\000Ä") => 10*ord('a'),    # Ä egalas a
    to_utf8("\000ä") => 10*ord('a'),    # ä egalas a
    to_utf8("\000Ö") => 10*ord('o'),    # Ö egalas o
    to_utf8("\000ö") => 10*ord('o'),    # ö egalas o
    to_utf8("\000Ü") => 10*ord('u'),    # Ü egalas u
    to_utf8("\000ü") => 10*ord('u'),    # ü egalas u
    to_utf8("\000ß") => 10*ord('s')+1   # ß post s
    );

my %values_hu_2 = (
    to_utf8("\000Ä") => 10*ord('a')+3,    # Ä post ä
    to_utf8("\000ä") => 10*ord('a')+2,    # ä post A
    to_utf8("\000Ö") => 10*ord('o')+3,    # Ö post ö
    to_utf8("\000ö") => 10*ord('o')+2,    # ö post O
    to_utf8("\000Ü") => 10*ord('u')+3,    # Ü post ü
    to_utf8("\000ü") => 10*ord('u')+2,    # ü post U
    to_utf8("\000ß") => 10*ord('s')+2     # ß post S
    );

my %values_hu_3 = (
    to_utf8("\000Ä") => 'a', 
    to_utf8("\000ä") => 'a',
    to_utf8("\000Ö") => 'o',
    to_utf8("\000ö") => 'o',
    to_utf8("\000Ü") => 'u',
    to_utf8("\000ü") => 'u' 
    );

sub letterval_hu {
    my ($chr,$level) = @_;
    my ($offset,$values);
    
    if ($level == 1) {
	$values = \%values_hu_1; # kruda
	$offset = 0;
    } else {
	$values = \%values_hu_2; # subtila
	$offset = 1;
    };
    
    if (! $chr) {
	return 0;
    } elsif (ord($chr) >= ord('a') and ord($chr) <= ord('z')) {
	return 10 * ord($chr);
    } elsif (ord($chr) >= ord('A') and ord($chr) <= ord('Z')) {
	return 10 * ord(lc($chr)) + $offset;
    } elsif ( exists $$values{$chr} ) {
	return $$values{$chr};
    } else {
	return 9999;
    }
}


sub letter_hu {
    my $letter =  first_utf8char(shift);
    my $chr;

    if (ord($letter) >= ord('a') and ord($letter) <= ord('z')) {
	return $letter;
    } elsif (ord($letter) >= ord('A') and ord($letter) <= ord('Z')) {
	return lc($letter);
    } elsif ( exists $values_hu_3{$letter} ) {
	return $values_hu_3{$letter};
    } else {
	return '0';
    }
}

########################## chehha ###########################

my %values_cs_1 = (
    to_utf8("\000Á") => 10*ord('a'),
    to_utf8("\000á") => 10*ord('a'), 
    to_utf8("\001\032") => 10*ord('e'),
    to_utf8("\001\033") => 10*ord('e'),
    to_utf8("\000Í") => 10*ord('i'),
    to_utf8("\000í") => 10*ord('i'),
    to_utf8("\000Ú") => 10*ord('u'),
    to_utf8("\000ú") => 10*ord('u'),
    to_utf8("\000Ý") => 10*ord('y'),
    to_utf8("\000ý") => 10*ord('y'),
    to_utf8("\001\014") => 10*ord('c')+2,
    to_utf8("\001\015") => 10*ord('c')+2,
    to_utf8("\001\140") => 10*ord('s')+2,
    to_utf8("\001\141") => 10*ord('s')+2,
    to_utf8("\001\130") => 10*ord('r')+2,
    to_utf8("\001\131") => 10*ord('r')+2,
    to_utf8("\001\175") => 10*ord('z')+2,
    to_utf8("\001\176") => 10*ord('z')+2,
    to_utf8("\001\116") => 10*ord('d'),
    to_utf8("\001\117") => 10*ord('d'),
    to_utf8("\001\107") => 10*ord('n'),
    to_utf8("\001\110") => 10*ord('n'),
    to_utf8("\001\144") => 10*ord('t'),
    to_utf8("\001\145") => 10*ord('t'),
    "#" => 10*ord('h')+2
    );

my %values_cs_2 = (
    to_utf8("\000Á") => 10*ord('a')+2,
    to_utf8("\000á") => 10*ord('a')+3, 
    to_utf8("\001\032") => 10*ord('e')+2,
    to_utf8("\001\033") => 10*ord('e')+3,
    to_utf8("\000Í") => 10*ord('i')+2,
    to_utf8("\000í") => 10*ord('i')+3,
    to_utf8("\000Ú") => 10*ord('u')+2,
    to_utf8("\000ú") => 10*ord('u')+2,
    to_utf8("\000Ý") => 10*ord('y')+2,
    to_utf8("\000ý") => 10*ord('y')+3,
    to_utf8("\001\014") => 10*ord('c')+2,
    to_utf8("\001\015") => 10*ord('c')+3,
    to_utf8("\001\140") => 10*ord('s')+2,
    to_utf8("\001\141") => 10*ord('s')+3,
    to_utf8("\001\130") => 10*ord('r')+2,
    to_utf8("\001\131") => 10*ord('r')+3,
    to_utf8("\001\175") => 10*ord('z')+2,
    to_utf8("\001\176") => 10*ord('z')+3,
    to_utf8("\001\116") => 10*ord('d')+2,
    to_utf8("\001\117") => 10*ord('d')+3,
    to_utf8("\001\107") => 10*ord('n')+2,
    to_utf8("\001\110") => 10*ord('n')+3,
    to_utf8("\001\144") => 10*ord('t')+2,
    to_utf8("\001\145") => 10*ord('t')+3,
    "#" => 10*ord('h')+2
    );

my %values_cs_3 = (
    to_utf8("\000Á") => 'a',
    to_utf8("\000á") => 'a', 
    to_utf8("\001\032") => 'e',
    to_utf8("\001\033") => 'e',
    to_utf8("\000Í") => 'i',
    to_utf8("\000í") => 'i',
    to_utf8("\000Ú") => 'u',
    to_utf8("\000ú") => 'u',
    to_utf8("\000Ý") => 'y',
    to_utf8("\000ý") => 'y',
    to_utf8("\001\014") => to_utf8("\001\015"),
    to_utf8("\001\015") => to_utf8("\001\015"),
    to_utf8("\001\140") => to_utf8("\001\141"),
    to_utf8("\001\141") => to_utf8("\001\141"),
    to_utf8("\001\130") => to_utf8("\001\131"),
    to_utf8("\001\131") => to_utf8("\001\131"),
    to_utf8("\001\175") => to_utf8("\001\176"),
    to_utf8("\001\176") => to_utf8("\001\176"),
    to_utf8("\001\116") => 'd',
    to_utf8("\001\117") => 'd',
    to_utf8("\001\107") => 'n',
    to_utf8("\001\110") => 'n',
    to_utf8("\001\144") => 't',
    to_utf8("\001\145") => 't',
    );


sub sortprep_cs {
    my $w = shift;

    print "$w -> " if ($debug);

    $w =~ s/ch/#/ig; # ch sekvas post h

    print "-> $w\n" if ($debug);

    return $w;
}

sub letterval_cs {
    my ($chr,$level) = @_;
    my ($offset,$values);
    
    if ($level == 1) {
	$values = \%values_cs_1; # kruda
	$offset = 0;
    } else {
	$values = \%values_cs_2; # subtila
	$offset = 1;
    };
    
    if (! $chr) {
	return 0;
    } elsif (ord($chr) >= ord('a') and ord($chr) <= ord('z')) {
	return 10 * ord($chr);
    } elsif (ord($chr) >= ord('A') and ord($chr) <= ord('Z')) {
	return 10 * ord(lc($chr)) + $offset;
    } elsif ( exists $$values{$chr} ) {
	return $$values{$chr};
    } else {
	return 9999;
    }
}


sub letter_cs {
    my $letter = shift;
    my $chr;

    if ( lc($letter) =~ /^ch/ ) {
	return 'ch';

    } else {
	$letter =  first_utf8char($letter);

	if (ord($letter) >= ord('a') and ord($letter) <= ord('z')) {
	    return $letter;
	} elsif (ord($letter) >= ord('A') and ord($letter) <= ord('Z')) {
	    return lc($letter);
	} elsif ( exists $values_cs_3{$letter} ) {
	    return $values_cs_3{$letter};
	} else {
	    return '0';
	}
    }
}

sub letter_asci_cs {
    my $chr = shift;

    $chr = letter_cs($chr);
    
    if ($chr eq to_utf8("\001\015"))    { return 'cx'; }
    elsif ($chr eq to_utf8("\001\141")) { return 'sx'; }
    elsif ($chr eq to_utf8("\001\131")) { return 'rx'; }
    elsif ($chr eq to_utf8("\001\176")) { return 'zx'; }
    elsif ($chr eq "ch")                { return 'ch'; }
    else                                { return $chr; }
}


###########################################################


1;



