#!/usr/bin/perl

# kreas el dosiero indekso.sgml
# unuopajn indeksojn en HTML-formato
# por la diversaj fakoj, lingvoj ktp.

# voku: indeks.pl -dceldosierujo -r../art/ fontdosierujo/indekso.sgml 
# au:   indeks.pl -dceldosierujo -r../art/vortaro.html\# fontdosiero/indekso.sgml


# konstantoj

$html = '.htm'; # dosierfinajho

$|=1;

# analizu la argumentojn

if ($ARGV[0] =~ /^\-d/) {
    $dir = shift @ARGV;
    $dir =~ s/^\-d//;
} else { $dir = '.' };
if ($ARGV[0] =~ /^\-r/) {
    $refdir = shift @ARGV;
    $refdir =~ s/^\-r//;
} else { $refdir = '../art/' };
$inxfn=shift @ARGV;

# kelkaj konstantoj
$pluraj = ($refdir !~ /#$/);
$inxref = "<i><a href=\"indeksoj$html\">".
    "indeksoj</a></i>";
$inxstl = "<link titel=\"indekso-stilo\" type=\"text/css\" ".
    "rel=stylesheet href=\"../stl/indeksoj.css\">\n";

%faknomoj=('2MAN'=>'komunuza senco',
	'AGR'=>'agrikulturo',
	'ANA'=>'anatomio, histologio',
	'ARKE'=>'arkeologio',
	'ARKI'=>'arkitekturo',
	'AST'=>'astronomio',
	'AUT'=>'a�tomobiloj',
	'AVI'=>'aviado',
	'BAK'=>'bakteriologio, virusologio',
	'BELA'=>'belartoj',
	'BELE'=>'beletro',
	'BIB'=>'biblio',
	'BIO'=>'biologio, biontologio',
	'BOT'=>'botaniko',
	'BUD'=>'budhismo',
	'EKON'=>'ekonomiko, financo',
	'EKOL'=>'ekologio',
	'ELE'=>'elektro',
	'ELET'=>'elektrotekniko',
	'FAR'=>'farmacio',
	'FER'=>'fervojoj',
	'FIL'=>'filozofio',
	'FIZL'=>'fiziologio',
	'FIZ'=>'fiziko',
	'FON'=>'fonetiko',
	'FOT'=>'fotografio, optiko',
	'GEOD'=>'geodezio, topografio',
	'GEOG'=>'geografio',
	'GEOM'=>'geometrio',
	'GEOL'=>'geologio',
	'GRA'=>'gramatiko',
	'HER'=>'heraldiko',
	'HIS'=>'historio',
	'HOR'=>'hortikulturo, arbokulturo, silvikulturo',
	'ISL'=>'islamo',
	'JUR'=>'juro',
	'KAT'=>'katolikismo',
	'KEM'=>'kemio, biokemio',
	'KIN'=>'kinoarto',
	'KIR'=>'kirurgio',
	'KOME'=>'komerco',
	'KOMP'=>'komputiko',
	'KON'=>'konstrutekniko',
	'KRI'=>'kristanismo',
	'KUI'=>'kuirarto',
	'LIN'=>'lingvistiko, filologio',
	'MAR'=>'maraferoj',
	'MAS'=>'ma�inoj, mekaniko',
	'MAT'=>'matematiko',
	'MAH'=>'materialismo historia',
	'MED'=>'medicino',
	'MET'=>'meteologio',
	'MIL'=>'militaferoj',
	'MIN'=>'mineralogio',
	'MIT'=>'mitologio',
	'MUZ'=>'muziko',
	'NEO'=>'neologismo',
	'PAL'=>'paleontologio',
	'POE'=>'poetiko, poezio',
	'POL'=>'politiko, sociologio',
	'PRA'=>'prahistorio',
	'PSI'=>'psikologio, psikiatrio',
	'RAD'=>'radiofonio',
	'REL'=>'religioj ne kristanaj',
	'SCI'=>'sciencoj',
	'SPO'=>'sporto, ludoj',
	'STA'=>'statistiko',
	'SHI'=>'�ipkonstruado, navigado',
	'TEA'=>'teatro',
	'TEK'=>'teknikoj',
	'TEKS'=>'teksindustrio, vestoj',
	'TEL'=>'telekomunikoj',
	'TIP'=>'tipografarto, libroj',
	'TRA'=>'trafiko',
	'ZOO'=>'zoologio',
	);

@alfabeto = ('a','b','c',"\346",'d','e','f','g',"\370",'h',"\266",'i','j',
	      "\274",'k','l','m','n','o','p','r','s',"\376",'t','u',"\375",
	     'v','z');
@kapvortoj;

# legu la tutan indeks-dosieron

print "Legi $inxfn...\n";
open INX,$inxfn or die "Ne povis malfermi $inxfn\n";
$inx=join('',<INX>);
close INX;

# traktu cxiujn unuopajn indekserojn

print "Analizi la indekserojn...\n";
$inx =~ s/<art\s+mrk="([^"]*)"\s*>(.*?)<\/art\s*>/ARTIKOLO($1,$2)/sieg;
#"

# kreu la html-dosierojn

# fakindeksoj
while (($fak,$refs) = each %fakoj) 
{
    FAKINX($fak,$refs);
}

# lingvoindeksoj
while (($lng,$refs) = each %tradukoj) 
{
    LINGVINX($lng,$refs);
}

if ($pluraj) {
    # kiuj komencliteroj okazas en @kapvortoj
    @literoj;
    for $lit (@alfabeto) {
	# trovu kapvorton komencigxantan je la litero
	if (TROVU($lit)) { push @literoj,"$lit"; };
    };

    # kapvortoj
    @kapvortoj = sort { LIT($a->[1]) cmp LIT($b->[1]) } @kapvortoj;
    foreach $lit (@literoj) { KAPVORTINX($lit) };

    # kiuj finliteroj okazas en @kapvortoj
    @invliteroj;
    for $lit (@alfabeto) {
	# trovu kapvorton komencigxantan je la litero
	if (INVTROVU($lit)) { push @invliteroj,"$lit"; };
    };

    # inversa indekso
    @kapvortoj = sort { INVLIT($a->[1]) cmp INVLIT($b->[1]) } @kapvortoj;
    foreach $lit (@invliteroj) { INVKAPVORTINX($lit) };
} else {

    # simplajn kapvortlistojn

    # kapvortoj
    @kapvortoj = sort { LIT($a->[1]) cmp LIT($b->[1]) } @kapvortoj;
    SIMPLKAPVORTINX(); 

    # inversa indekso
    @kapvortoj = sort { &INVLIT($a->[1]) cmp &INVLIT($b->[1]) } @kapvortoj;
    SIMPLINVKAPVORTINX();
};


INXLIST();

# analizas la indeks-tekston de artikolo

sub ARTIKOLO {
    my $mrk = lc(shift @_);
    my $tekst = shift @_;

    # trovu la kapvorton
    $tekst =~ s/^\s*<kap\s*>(.*?)<\/kap\s*>//si;
    my $kap = $1; $kap =~ s/\s+/ /sg;
    $kap =~ s/\*//g;
    $kap =~ s/[1-9\/]([aeio])Z?$/\/$1/;
    $kap =~ s/\/$//;
    # aldonu al kapvortlisto
    push @kapvortoj, [$mrk,$kap];

    # se la teksto entenas derivajho(j)n,
    # analizu nur tiujn, alikaze la tutan tekston

    if ($tekst =~/<drv/) {
	$tekst =~ s/<drv\s*(?:mrk="([^\"]*)")?\s*>(.*?)<\/drv\s*>/
	    INDEKSERO($mrk,$1,$2)/siegx;
    } else { INDEKSERO($mrk,$mrk,$tekst) };

    return '';
}

# analizas unuopan indekseron

sub INDEKSERO {
    my $mrk1 = lc(shift @_);
    my $mrk2 = lc(shift @_);
    my $tekst = shift @_;

    my $mrk = ($mrk2 or $mrk1);

    # trovu la kapvorton
    $tekst =~ s/^\s*<kap\s*>(.*?)<\/kap\s*>//si;
    my $kap = $1; $kap =~ s/\s+/ /sg;
    $kap =~ s/\*//g;
    $kap =~ s/[1-9\/]([aeio])Z?$/\/$1/;
    $kap =~ s/\/$//;
    # aldonu al kapvortlisto
#    push @kapvortoj, [$mrk,$kap];
    # analizu la fakojn
    $tekst =~ s/<uzo\s*>(.*?)<\/uzo\s*>/FAKO($1,$mrk,$kap)/sieg;
    # analizu la tradukojn
    $tekst =~ s/<trd\s+lng="([^\"]*)"\s*>(.*?)<\/trd\s*>/
	TRADUKO($2,$1,$mrk,$kap)/siegx;

    return '';
}

# notas unopan fakindikon

sub FAKO {
    my ($fak,$mrk,$kap)=@_;

    $kap =~ s/\///;
    push @{ $fakoj{$fak} }, [$mrk,$kap];

    return '';
};

# notas unuopan tradukon

sub TRADUKO {
    my ($trd,$lng,$mrk,$kap)=@_;

    $kap =~ s/\///;
    push @{ $tradukoj{$lng} }, [$mrk,$kap,$trd];

    return '';
};

# kreas fakindekson por unuopa fako

sub FAKINX {
    my ($fak,$refs) = @_;

    $fak = uc($fak);
    my $fk = lc($fak);
    my $r;
    my $last0, $last1;

    open OUT,">$dir/fx_$fk$html" or die "Ne povis krei $dir/fx_$fk$html\n";

    select STDOUT;
    print "Skribi $dir/fx_$fk$html\n";
    select OUT;

    print "<html><head><title>fakindekso por ".$faknomoj{$fak}."</title>\n";
    print "$inxstl</head>\n";
    print "<body>\n$inxref\n<h1>".$faknomoj{$fak}."</h1>\n";

    foreach $ref (sort { LIT($a->[1]) cmp LIT($b->[1]) } @$refs) {
	if (($last0 ne $ref->[0]) or ($last1 ne $ref->[1])) {
	    $r = REFERENCO($ref->[0]);
	    print "<a href=\"$r\" target=\"precipa\">";
	    print "$ref->[1]</a><br>\n";
	    $last0 = $ref->[0];
	    $last1 = $ref->[1];
	};
    };

    print "$inxref</body></html>\n";
    close OUT;
}

# kreas lingvoindekson por unuopa lingvo

sub LINGVINX {
    my ($lng,$refs) = @_;

    $lng = lc($lng);
    my $r;
    my $ln = substr($lng,0,5);
    open OUT,">$dir/lx_$ln$html" or die "Ne povis krei $dir/lx_$ln$html\n";

    select STDOUT;
    print "Skribi $dir/lx_$ln$html\n";
    select OUT;

    $lng =~ s/[oe]$/a/;
    print "<html><head><title>$lng indekso</title>\n";
    print "$inxstl</head>\n<body>\n";    
    print "$inxref\n<h1>$lng indekso</h1>\n";

    foreach $ref (sort { LIT($a->[2]) cmp LIT($b->[2]) } @$refs) {
	$r=REFERENCO($ref->[0]);    
	print "$ref->[2] = <a href=\"$r\" ";
	print "target=\"precipa\">$ref->[1]</a><br>\n";
    };

    print "$inxref</body></html>\n";
    close OUT;
}

# kreas la indekson de la kapvortoj

sub KAPVORTINX {
    my $lit = $_[0];
    my $lit1 = enmetu_x($lit);
    my $vrt;
    my $r,$a,$n=0;

    open OUT,">$dir/ix_kap$lit1$html" or 
	die "Ne povis krei $dir/ix_kap$lit1$html\n";

    select STDOUT;
    print "Skribi $dir/ix_kap$lit1$html\n";
    select OUT;

    print "<html><head><title>kapvortoindekso sekcio $lit</title>\n";
    print "$inxstl</head><body>\n";
    print "$inxref\n";
    for $a (@literoj) { 
	if ($a ne $lit) {
	    print "<a href=\"ix_kap".enmetu_x($a)."$html\">$a</a>\n"; 
	} else { print "<b>$a</b> "; };
    };
    print "<h1>kapvortoj $lit...</h1>\n";

    foreach $ref (@kapvortoj) {
	my $vrt = lc(LIT($ref->[1]));
	$vrt =~ s/^(.x?).*$/$1/;
	if (($lit1 eq $vrt) and
	    (($last0 ne $ref->[0]) or ($last1 ne $ref->[1]))) {
	    if ($refdir =~ /#$/) { $r="$refdir".uc($ref->[0]); } 
	    else { $r="$refdir$ref->[0]$html";};

	    print "<a href=\"$r\" target=\"precipa\">";
	    print "$ref->[1]</a><br>\n";

	    $last0 = $ref->[0];
	    $last1 = $ref->[1];
	    $n++;
	};
    };

    if ($n > 20) {
	print "<p>$inxref\n";
	for $a (@literoj) { 
	    if ($a ne $lit) {
		print "<a href=\"ix_kap".enmetu_x($a)."$html\">$a</a>\n"; 
	    } else { print "<b>$a</b> "; };
	};
    };

    print "</body></html>\n";
    close OUT;
}

sub SIMPLKAPVORTINX {
    my $ref,$r,$n=0,$last0,$last1;

    open OUT,">$dir/ix_kap$html" or 
	die "Ne povis krei $dir/ix_kap$html\n";

    select STDOUT;
    print "Skribi $dir/ix_kap$html\n";
    select OUT;

    print "<html><head><title>kapvortoindekso</title>\n";
    print "$inxstl</head><body>\n";
    print "$inxref\n";
    print "<h1>kapvortoj</h1>\n";

    foreach $ref (@kapvortoj) {
	if (($last0 ne $ref->[0]) or ($last1 ne $ref->[1])) {
	    if ($refdir =~ /#$/) { $r="$refdir".uc($ref->[0]); } 
	    else { $r="$refdir$ref->[0]$html";};

	    print "<a href=\"$r\" target=\"precipa\">";
	    print "$ref->[1]</a><br>\n";

	    $last0 = $ref->[0];
	    $last1 = $ref->[1];
	    $n++;
	};
    };

    print "<p>$inxref\n";
    print "</body></html>\n";
    close OUT;
}

# kreas la inversan indekson de la kapvortoj

sub INVKAPVORTINX {
    my $lit = $_[0];
    my $lit1 = enmetu_x($lit);
    my $r,$n=0;
    my $last0,$last1;
    open OUT,">$dir/ix_inv$lit1$html" or 
	die "Ne povis krei $dir/ix_inv$lit1$html\n";

    select STDOUT;
    print "Skribi $dir/ix_inv$lit1$html\n";
    select OUT;

    print "<html><head><title>inversa kapvortoindekso sekcio $lit</title>\n";
    print "$inxstl</head><body>\n";
    print "$inxref\n";
    for $a (@invliteroj) { 
	if ($a ne $lit) {
	    print "<a href=\"ix_inv".enmetu_x($a)."$html\">$a</a>\n"; 
	} else { print "<b>$a</b> "; };
    };
    print "<h1>inversa indekso ...$lit</h1>\n";

    foreach $ref (@kapvortoj) {
	my $inv = lc(INVLIT($ref->[1]));
	$inv =~ s/^(.x?).*$/$1/;
	if (($lit1 eq $inv) 
	    and (($last0 ne $ref->[0]) or ($last1 ne $ref->[1]))) {
	    if ($refdir =~ /#$/) { $r="$refdir".uc($ref->[0]); } 
	    else { $r="$refdir$ref->[0]$html";};

	    print "<a href=\"$r\" target=\"precipa\">";
	    print "$ref->[1]</a><br>\n";

	    $last0 = $ref->[0];
	    $last1 = $ref->[1];
	    $n++;
	};
    };

    if ($n > 20) {
	print "<p>$inxref\n";
	for $a (@invliteroj) { 
	    if ($a ne $lit) {
		print "<a href=\"ix_inv".enmetu_x($a)."$html\">$a</a>\n"; 
	    } else { print "<b>$a</b> "; };
	};
    };

    print "</body></html>\n";
    close OUT;
}

sub SIMPLINVKAPVORTINX {
    my $ref,$r,$n=0;
    my $last0,$last1;
 
   open OUT,">$dir/ix_inv.htm" or 
	die "Ne povis krei $dir/ix_inv$html\n";

    select STDOUT;
    print "Skribi $dir/ix_inv$html\n";
    select OUT;

    print "<html><head><title>inversa kapvortoindekso</title>\n";
    print "$inxstl</head><body>\n";
    print "$inxref\n";
    print "<h1>inversa indekso</h1>\n";

    foreach $ref (@kapvortoj) {
	if (($last0 ne $ref->[0]) or ($last1 ne $ref->[1])) {
	    if ($refdir =~ /#$/) { $r="$refdir".uc($ref->[0]); } 
	    else { $r="$refdir$ref->[0]$html";};

	    print "<a href=\"$r\" target=\"precipa\">";
	    print "$ref->[1]</a><br>\n";

	    $last0 = $ref->[0];
	    $last1 = $ref->[1];
	    $n++;
	};
    };


    print "<p>$inxref\n";
    print "</body></html>\n";
    close OUT;
}

# kreas la indekson de la indeksoj

sub INXLIST {
    my $lit,$lit1;
    
    open OUT,">$dir/indeksoj$html" or die "Ne povis krei $dir/indeksoj$html\n";

    select STDOUT;
    print "Skribi $dir/indeksoj$html\n";
    select OUT;

    print "<html><head><title>indekslisto</title>\n";
    print "$inxstl</head><body>\n";
    print "<h2><a href=\"../titolo$html\" target=\"precipa\">";
    print "titolpa�o</a></h2>\n";
    print "<h2><a href=\"../sercxo$html\" target=\"precipa\">ser�o</a></h2>\n";
#    print "<h2>indeksoj</h2>";
    print "<dl>\n";

    if ($pluraj) {
	#kapvortoj
	print "<dt>kapvortindekso\n<dd><b>";
	for $lit (@literoj) {
	    $lit1 = enmetu_x($lit);
	    print "<a href=\"ix_kap$lit1$html\">$lit</a>\n";
	};
	print "</b>\n";

	#inversa indekso
	print "<dt>inversa indekso\n<dd>";
	for $lit (@invliteroj) {
	    $lit1 = enmetu_x($lit);
	    print "<a href=\"ix_inv$lit1$html\">$lit</a>\n";
	};
    } else {
	#kapvortoj
	print "<a href=\"ix_kap$html\">kapvortindekso</a><p>\n";
	#inversa indekso
	print "<a href=\"ix_inv$html\">inversa indekso</a><p>\n";
    };
    
    print "\n";

    #lingvoj
    if (%tradukoj) {
	print "<dt>lingvoindeksoj\n<dd>";
	for $lng (sort keys %tradukoj) 
	{
	    $lng=lc($lng);
	    my $ln=substr($lng,0,5);
	    print "<a href=\"lx_$ln.htm\">";
	    print "$lng</a><br>\n";
	};
    };

    #fakoj
    if (%fakoj) {
	print "<dt>fakindeksoj\n<dd>";
	for $fak (sort keys %fakoj) 
	{
	    print "<a href=\"fx_".lc($fak).".htm\">";
	    print "<img src=\"../smb/".uc($fak).".gif\"";
	    my $fknm=$faknomoj{uc($fak)};
	    print "alt=\"$fknm\" border=0></a>\n";
	};
    };

    print "</dd>\n";

    print "</body></html>\n";
    close OUT;
}

# funkcio por trovi vorton, komencigxantan je litero $lit
sub TROVU {
    my $lit = $_[0];
    my $lit1 = enmetu_x($lit);
    my $vrt, $ref;

    foreach $ref (@kapvortoj) {
	my $vrt = lc(LIT($ref->[1]));
	$vrt =~ s/^(.x?).*$/$1/;
	if ($lit1 eq $vrt) { return $ref->[1] };
    }

    return ''; # neniun trovis
};

# funkcio por trovi vorton, finigxantan je litero $lit
sub INVTROVU {
    my $lit = $_[0];
    my $lit1 = enmetu_x($lit);
    my $vrt, $ref;

    foreach $ref (@kapvortoj) {
	my $vrt = lc(INVLIT($ref->[1]));
	$vrt =~ s/^(.x?).*$/$1/;
	if ($lit1 eq $vrt) { return $ref->[1] };
    }

    return ''; # neniun trovis
};

# funkcio por esperanta ordigado

sub LIT {
    my $vort = lc($_[0]);

    # konverti la e-literojn al cx ... ux
    $vort =~ s/\306/cx/g;
    $vort =~ s/\330/gx/g;
    $vort =~ s/\246/hx/g; 
    $vort =~ s/\254/jx/g;
    $vort =~ s/\336/sx/g;
    $vort =~ s/\335/ux/g;
    $vort =~ s/\346/cx/g;
    $vort =~ s/\370/gx/g;
    $vort =~ s/\266/hx/g;
    $vort =~ s/\274/jx/g;
    $vort =~ s/\376/sx/g; 
    $vort =~ s/\375/ux/g;
    # forigi finajxon
    $vort =~ s/^[\/1-9](?:[aeio]|oj)//;
    # forigi cxiujn ne-literojn
    $vort =~ s/[^a-z]//g;
    return $vort;
}

# funkcio por inversa esperanta ordigado
# kun speciala atento de finajhoj, se ili
# estas apartigitaj per / au cifero kiel en PIV

sub INVLIT {
    my $vort = reverse(lc($_[0]));

    # konverti la e-literojn al cx ... ux
    $vort =~ s/\306/cx/g;
    $vort =~ s/\330/gx/g;
    $vort =~ s/\246/hx/g; 
    $vort =~ s/\254/jx/g;
    $vort =~ s/\336/sx/g;
    $vort =~ s/\335/ux/g;
    $vort =~ s/\346/cx/g;
    $vort =~ s/\370/gx/g;
    $vort =~ s/\266/hx/g;
    $vort =~ s/\274/jx/g;
    $vort =~ s/\376/sx/g; 
    $vort =~ s/\375/ux/g;
    # forigi finajxon
    $vort =~ s/^(?:[aeio]|oj)[\/1-9]//;
    # forigi cxiujn ne-literojn
    $vort =~ s/[^a-z]//g;

    return $vort;
}

sub INVCMP {
    return INVLIT($a->[1]) cmp INVLIT($b->[1]);
};

sub REFERENCO {
    my $ref=$_[0];
    my $rez;

    if ($refdir =~ /#$/) { 
	# chiuj artikoloj estas en unu sola
	# dosiero, tien referencu!
	$rez="$refdir".uc($ref); 
    } 
    else { 
	# chiuj artikoloj estas en unuopaj
	# dosieroj, parto de la referenco
	# povus montri en tian dosieron
	$ref =~ /^([^\.]*)\.(.*)$/;
	my $r1=$1; my $r2=$2;
	$rez="$refdir".lc($r1).".htm";
	if ($r2) { $rez .= "#".uc($r2); };
    };
};

sub enmetu_x {
    my $lit = $_[0];
    $lit =~ s/\346/cx/g;
    $lit =~ s/\370/gx/g;
    $lit =~ s/\266/hx/g;
    $lit =~ s/\274/jx/g;
    $lit =~ s/\376/sx/g; 
    $lit =~ s/\375/ux/g;

    return $lit;
};



