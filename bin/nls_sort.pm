#!/usr/bin/perl

package nls_sort;

$debug = 1;


################ tests ###############

# print to_utf8("\000Ä"), "\n";
# print to_utf8("\001\010"), "=\304\210\n";

#$str = "sch".to_utf8("\000ö")."nes Beispiel.\n";
#for ($i=0; $i<10; $i++) {
#  print "$i: ", get_utf8char(\$str), " ", $str, "\n";
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
sub get_utf8char {
  my $str_ref = $_[0];
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

#  if ($debug) {
#    print "to_utf8: ", unpack("B32",$uchr), "->", unpack("B8" x length($chrs), $chrs), "\n";
#  }  	

  return $chrs;
}

# komparu du signarojn per nacilingva ordig-funkcio
sub cmp_nls {
  my ($w1,$w2,$lng) = @_;
  my $cmp;
  my $fnc = \&{"letterval_$lng"};

  unless (defined &$fnc) { 
#      $fnc = sub { my ($d,$e) = @_; return ($d cmp $e); };
      $fnc = \&letterval_en;
  }
  
  #unless (defined &$fnc) { $fnc = \&cmp; };
  #print $fnc if ($debug);

  # komparu krude (sen atento de uskleco kaj similaj diferencoj)
  my ($x,$y) = ($w1,$w2);
  do {
    $cmp = &$fnc(get_utf8char(\$x),1) <=> &$fnc(get_utf8char(\$y),1);
  } while ($cmp == 0 and ($x or $y));

  # se la vortoj egalas, komparu pli subtile
  if ($cmp == 0) {
	  # komparu krude (sen atento de uskleco kaj similaj diferencoj)
	  my ($x,$y) = ($w1,$w2);
	  do {
	    $cmp = &$fnc(get_utf8char(\$x),2) <=> &$fnc(get_utf8char(\$y),2);
	  } while ($cmp == 0 and ($x or $y));
  }

  return $cmp;
}

# germana ordigfunckio
sub letterval_de {
  my ($chr,$level) = @_;
  my $offset;

  if ($level == 1) {
	$offset = 0;     # kruda
  } else {
      $offset = 0.1;   # subtila
  };

  my %values = (
    to_utf8("\000Ä") => ord('a')+2*$offset,    # Ä egalas/post A
    to_utf8("\000ä") => ord('a')+3*$offset,    # ä egalas/post a
    to_utf8("\000Ö") => ord('o')+2*$offset,    # Ö egalas/post o
    to_utf8("\000ö") => ord('o')+3*$offset,    # ö egalas/post o
    to_utf8("\000Ü") => ord('u')+2*$offset,    # Ü egalas/post u
    to_utf8("\000ü") => ord('u')+3*$offset,    # ü egalas/post u
    to_utf8("\000ß") => ord('s')+0.5,          # ß chiam post s
    );

  if (! $chr) {
  	return 0;
  } elsif ($chr =~ /^[A-Z]$/) {
  	return ord(lc($chr));
  } elsif ($chr =~  /^[a-z]$/) {
	return ord(lc($chr)) + $offset;
  } elsif ( exists $values{$chr} ) {
      return $values{$chr};
  } else {
      return 999;
  }
}

# anlga ordigfuncio
sub letterval_en {
  my ($chr,$level) = @_;
  my $offset;

  if ($level == 1) {
	$offset = 0;     # kruda
  } else {
      $offset = 0.1;   # subtila
  };

  if (! $chr) {
  	return 0;
  } elsif ($chr =~  /^[A-Z]$/) {
	return ord(lc($chr));
  } elsif ($chr =~  /^[a-z]$/) {
	return ord(lc($chr)) + $offset;
  } else {
      return 999;
  }
}

# esperanta ordigfuncio
sub letterval_eo {
  my ($chr,$level) = @_;
  my $offset;

  if ($level == 1) {
	$offset = 0;     # kruda
  } else {
      $offset = 0.1;   # subtila
  };

  my %values = (
    to_utf8("\001\010") => ord('c')+2*$offset, # Cx post c
    to_utf8("\001\011") => ord('c')+3*$offset, # cx post c
    to_utf8("\001\034") => ord('g')+2*$offset, # Gx post g
    to_utf8("\001\035") => ord('g')+3*$offset, # gx post g
    to_utf8("\001\044") => ord('h')+2*$offset, # Hx post h
    to_utf8("\001\045") => ord('h')+3*$offset, # hx post h
    to_utf8("\001\064") => ord('j')+2*$offset, # Jx post j
    to_utf8("\001\065") => ord('j')+3*$offset, # jx post j
    to_utf8("\001\134") => ord('s')+2*$offset, # Sx post s
    to_utf8("\001\135") => ord('s')+3*$offset, # sx post s
    to_utf8("\001\154") => ord('u')+2*$offset, # Ux post u
    to_utf8("\001\155") => ord('u')+3*$offset, # ux post u
  );

  if (! $chr) {
  	return 0;
  } elsif ($chr =~  /^[A-Z]$/) {
	return ord(lc($chr));
  } elsif ($chr =~  /^[a-z]$/) {
	return ord(lc($chr)) + $offset;
  } elsif ( exists $values{$chr} ) {
      return $values{$chr};
  } else {
      return 999;
  }
}

1;
