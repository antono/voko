package nls_sort;

require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw(pop_utf8char first_utf8char last_utf8char 
	     cmp_nls reverse_utf8 letter_nls letter_asci_nls); 
#@EXPORT_OK = qw(...);         # symbols to export on request
#%EXPORT_TAGS = tag => [...];  # define names for sets of symbols
                                                                              

$debug = 1;


################ tests ###############

# print to_utf8("\000�"), "\n";
# print to_utf8("\001\010"), "=\304\210\n";

#$str = "sch".to_utf8("\000�")."nes Beispiel.\n";
#for ($i=0; $i<10; $i++) {
#  print "$i: ", pop_utf8char($str), " ", $str, "\n";
#}


#print "schon <=> schonen = ", cmp_nls("schon","schonen","de"), "\n";
#print "schonen <=> sch�ne = ", cmp_nls("schonen","sch".to_utf8("\000�")."ne","de"), "\n";
#print "alt <=> sch�n = ", cmp_nls("alt","sch".to_utf8("\000�")."n","de"), "\n";

#$sz = to_utf8("\000�");
#$oe = to_utf8("\000�");
#$ae = to_utf8("\000�");
#$Ae = to_utf8("\000�");
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
    utf8(hex($_[0]));
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
	$chr;
    }
}

# komparu du signarojn per nacilingva ordig-funkcio
sub cmp_nls {
    my ($w1,$w2,$lng) = @_;
    my $cmp;
    my $fnc = \&{"letterval_$lng"};
    
    unless (defined &$fnc) { 
	$fnc = \&letterval_en;
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
	return lc($chr);
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
    to_utf8("\000�") => 10*ord('a'),    # � egalas a
    to_utf8("\000�") => 10*ord('a'),    # � egalas a
    to_utf8("\000�") => 10*ord('o'),    # � egalas o
    to_utf8("\000�") => 10*ord('o'),    # � egalas o
    to_utf8("\000�") => 10*ord('u'),    # � egalas u
    to_utf8("\000�") => 10*ord('u'),    # � egalas u
    to_utf8("\000�") => 10*ord('s')+1   # � post s
    );

my %values_de_2 = (
    to_utf8("\000�") => 10*ord('a')+1,    # � post a
    to_utf8("\000�") => 10*ord('a')+2,    # � post �
    to_utf8("\000�") => 10*ord('o')+1,    # � post o
    to_utf8("\000�") => 10*ord('o')+2,    # � post �
    to_utf8("\000�") => 10*ord('u')+1,    # � post u
    to_utf8("\000�") => 10*ord('u')+2,    # � post �
    to_utf8("\000�") => 10*ord('s')+1     # � post s
    );

my %values_de_3 = (
    to_utf8("\000�") => 'a', 
    to_utf8("\000�") => 'a',
    to_utf8("\000�") => 'o',
    to_utf8("\000�") => 'o',
    to_utf8("\000�") => 'u',
    to_utf8("\000�") => 'u' 
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
	return 10 * ord(lc($chr)) - $offset;
    } elsif ( exists $$values{$chr} ) {
	return $$values{$chr};
    } else {
	return 9999;
    }
}


sub letter_de {
    my $letter = shift;
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
    my $letter = shift;
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
    my $letter = shift;

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
    $chr = shift;
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
    to_utf8("\000�") => 10*ord('a'),    # � egalas a
    to_utf8("\000�") => 10*ord('a'),    # � egalas a
    to_utf8("\000�") => 10*ord('a'),    # � egalas a
    to_utf8("\000�") => 10*ord('a'),    # � egalas a
    to_utf8("\000�") => 10*ord('a'),    # � egalas a
    to_utf8("\000�") => 10*ord('a'),    # � egalas a

    to_utf8("\000�") => 10*ord('e'),    # � egalas e
    to_utf8("\000�") => 10*ord('e'),    # � egalas e
    to_utf8("\000�") => 10*ord('e'),    # � egalas e
    to_utf8("\000�") => 10*ord('e'),    # � egalas e
    to_utf8("\000�") => 10*ord('e'),    # � egalas e
    to_utf8("\000�") => 10*ord('e'),    # � egalas e

    to_utf8("\000�") => 10*ord('i'),    # � egalas i
    to_utf8("\000�") => 10*ord('i'),    # � egalas i
    to_utf8("\000�") => 10*ord('i'),    # � egalas i
    to_utf8("\000�") => 10*ord('i'),    # � egalas i
    to_utf8("\000�") => 10*ord('i'),    # � egalas i
    to_utf8("\000�") => 10*ord('i'),    # � egalas i

    to_utf8("\000�") => 10*ord('o'),    # � egalas o
    to_utf8("\000�") => 10*ord('o'),    # � egalas o
    to_utf8("\000�") => 10*ord('o'),    # � egalas o
    to_utf8("\000�") => 10*ord('o'),    # � egalas o
    to_utf8("\000�") => 10*ord('o'),    # � egalas o
    to_utf8("\000�") => 10*ord('o'),    # � egalas o

    to_utf8("\000�") => 10*ord('u'),    # � egalas u
    to_utf8("\000�") => 10*ord('u'),    # � egalas u
    to_utf8("\000�") => 10*ord('u'),    # � egalas u
    to_utf8("\000�") => 10*ord('u'),    # � egalas u
    to_utf8("\000�") => 10*ord('u'),    # � egalas u
    to_utf8("\000�") => 10*ord('u')     # � egalas u            
		    );
                       
 my %values_fr_2 = (
    to_utf8("\000�") => 10*ord('a')+1,    # � post a
    to_utf8("\000�") => 10*ord('a')+2,    # � post �
    to_utf8("\000�") => 10*ord('a')+1,    # � post a
    to_utf8("\000�") => 10*ord('a')+2,    # � post �
    to_utf8("\000�") => 10*ord('a')+1,    # � post a
    to_utf8("\000�") => 10*ord('a')+2,    # � post �

    to_utf8("\000�") => 10*ord('e')+1,    # � post e
    to_utf8("\000�") => 10*ord('e')+2,    # � post �
    to_utf8("\000�") => 10*ord('e')+1,    # � post e
    to_utf8("\000�") => 10*ord('e')+2,    # � post �
    to_utf8("\000�") => 10*ord('e')+1,    # � post e
    to_utf8("\000�") => 10*ord('e')+2,    # � post �

    to_utf8("\000�") => 10*ord('i')+1,    # � post i
    to_utf8("\000�") => 10*ord('i')+2,    # � post �
    to_utf8("\000�") => 10*ord('i')+1,    # � post i
    to_utf8("\000�") => 10*ord('i')+2,    # � post �
    to_utf8("\000�") => 10*ord('i')+1,    # � post i
    to_utf8("\000�") => 10*ord('i')+2,    # � post �

    to_utf8("\000�") => 10*ord('o')+1,    # � post o
    to_utf8("\000�") => 10*ord('o')+2,    # � post �
    to_utf8("\000�") => 10*ord('o')+1,    # � post o
    to_utf8("\000�") => 10*ord('o')+2,    # � post �
    to_utf8("\000�") => 10*ord('o')+1,    # � post o
    to_utf8("\000�") => 10*ord('o')+2,    # � post �

    to_utf8("\000�") => 10*ord('u')+1,    # � post u
    to_utf8("\000�") => 10*ord('u')+2,    # � post �
    to_utf8("\000�") => 10*ord('u')+1,    # � post u
    to_utf8("\000�") => 10*ord('u')+2,    # � post �
    to_utf8("\000�") => 10*ord('u')+1,    # � post u
    to_utf8("\000�") => 10*ord('u')+2,    # � post �   
		    );

 my %values_fr_3 = (
    to_utf8("\000�") => 'a', 
    to_utf8("\000�") => 'a', 
    to_utf8("\000�") => 'a', 
    to_utf8("\000�") => 'a', 
    to_utf8("\000�") => 'a', 
    to_utf8("\000�") => 'a', 

    to_utf8("\000�") => 'e', 
    to_utf8("\000�") => 'e', 
    to_utf8("\000�") => 'e', 
    to_utf8("\000�") => 'e', 
    to_utf8("\000�") => 'e', 
    to_utf8("\000�") => 'e', 

    to_utf8("\000�") => 'i', 
    to_utf8("\000�") => 'i', 
    to_utf8("\000�") => 'i', 
    to_utf8("\000�") => 'i', 
    to_utf8("\000�") => 'i', 
    to_utf8("\000�") => 'i', 

    to_utf8("\000�") => 'o', 
    to_utf8("\000�") => 'o', 
    to_utf8("\000�") => 'o', 
    to_utf8("\000�") => 'o', 
    to_utf8("\000�") => 'o', 
    to_utf8("\000�") => 'o', 

    to_utf8("\000�") => 'u', 
    to_utf8("\000�") => 'u', 
    to_utf8("\000�") => 'u', 
    to_utf8("\000�") => 'u', 
    to_utf8("\000�") => 'u', 
    to_utf8("\000�") => 'u' 
    );

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
    my $letter = shift;
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
    my $letter = shift;
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




###########################################################

1;



