#!/usr/bin/perl

# kreas el dosiero indekso.sgml
# unuopajn indeksojn en HTML-formato
# por la diversaj fakoj, lingvoj ktp.

# voku: indeks.pl -dceldosierujo -r../art/ fontdosierujo/indekso.sgml 
# au:   indeks.pl -dceldosierujo -r../art/vortaro.html\# fontdosiero/indekso.sgml


# konstantoj

$html = '.html'; # dosierfinajho
$tmp_file = "/tmp/$$voko.inx";

$tagoj   = 14;       # shanghindekso indikas shanghitajn en la lastaj n tagoj
$xml_dir = 'xml';    # relative al vortara radidosierujo
$art_dir = '../art'; # relative al inx
$nmax    = 200;      # maksimume tiom da shanghitajn artikolojn indiku
$cvs_log = '/usr/bin/cvs log';

$|=1;

# analizu la argumentojn

while (@ARGV) {
    if ($ARGV[0] eq '-v') {
	$verbose = 1;
	shift @ARGV;
    } elsif ($ARGV[0] =~ /^\-d/) {
	$dir = shift @ARGV;
	$dir =~ s/^\-d//;
    } elsif ($ARGV[0] =~ /^\-r/) {
	$refdir = shift @ARGV;
	$refdir =~ s/^\-r//;
    } else {
	$inxfn=shift @ARGV;
    }
}

$dir ='.' unless $dir;
$refdir = '../art/' unless $refdir;

# kelkaj konstantoj
$pluraj = ($refdir !~ /#$/);
$inxref = "<i><a href=\"indeksoj$html\">".
	   "indeksoj</a></i>";
$inxstl = "<link titel=\"indekso-stilo\" type=\"text/css\" ".
	   "rel=stylesheet href=\"../stl/indeksoj.css\">\n";
$cntdecl = "<meta http-equiv=\"Content-Type\" content=\"text/html; ".
	   "charset=UTF-8\">";


%faknomoj=('2MAN'=>'komunuza senco',
	'AGR'=>'agrikulturo',
	'ANA'=>'anatomio, histologio',
	'ARKE'=>'arkeologio',
	'ARKI'=>'arkitekturo',
	'AST'=>'astronomio',
	'AUT'=>'aŭtomobiloj',
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
	'MAS'=>'maŝinoj, mekaniko',
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
	'REL'=>'religioj',
	'SCI'=>'sciencoj',
	'SPO'=>'sporto, ludoj',
	'STA'=>'statistiko',
	'SHI'=>'ŝipkonstruado, navigado',
	'TEA'=>'teatro',
	'TEK'=>'teknikoj',
	'TEKS'=>'teksindustrio, vestoj',
	'TEL'=>'telekomunikoj',
	'TIP'=>'tipografarto, libroj',
	'TRA'=>'trafiko',
	'ZOO'=>'zoologio',
	);

%lingvoj = (
	    'aa'=>'afara',
	    'ab'=>'abĥaza',
	    'af'=>'afrikansa',
	    'am'=>'amhara',
	    'ar'=>'araba',
	    'as'=>'asama',
	    'ay'=>'ajmara',
	    'az'=>'azerbajĝana',
	    'ba'=>'baŝkira',
	    'be'=>'belorusa',
	    'bg'=>'bulgara',
	    'bh'=>'bihara',
	    'bi'=>'bislamo',
	    'bn'=>'bengala',
	    'bo'=>'tibeta',
	    'br'=>'bretona',
	    'ca'=>'kataluna',
	    'co'=>'korsika',
	    'cs'=>'ĉeĥa',
	    'cy'=>'kimra',
	    'da'=>'dana',
	    'de'=>'germana',
	    'dz'=>'dzonko',
	    'el'=>'greka',
	    'en'=>'angla',
	    'eo'=>'esperanto',
	    'es'=>'hispana',
	    'et'=>'estona',
	    'eu'=>'eŭska',
	    'fa'=>'persa',
	    'fi'=>'finna',
	    'fj'=>'fiĝia',
	    'fo'=>'feroa',
	    'fr'=>'franca',
	    'fy'=>'frisa',
	    'ga'=>'irlanda',
	    'gd'=>'gaela',
	    'gl'=>'galega',
	    'gn'=>'gvarania',
	    'gu'=>'guĝarata',
	    'ha'=>'haŭsa',
	    'he'=>'hebrea',
	    'hi'=>'hinda',
	    'hr'=>'kroata',
	    'hu'=>'hungara',
	    'hy'=>'armena',
	    'ia'=>'interlingvao',
	    'id'=>'indonezia',
	    'ie'=>'okcidentalo',
	    'ik'=>'eskima',
	    'is'=>'islanda',
	    'it'=>'itala',
	    'iu'=>'inuita',
	    'ja'=>'japana',
	    'jw'=>'java',
	    'ka'=>'kartvela',
	    'kk'=>'kazaĥa',
	    'kl'=>'gronlanda',
	    'km'=>'kmera',
	    'kn'=>'kanara',
	    'ko'=>'korea',
	    'ks'=>'kaŝmira',
	    'ku'=>'kurda',
	    'ky'=>'kirgiza',
	    'la'=>'latina',
	    'ln'=>'lingala',
	    'lo'=>'laŭa',
	    'lt'=>'litova',
	    'lv'=>'latva',
	    'mg'=>'malagasa',
	    'mi'=>'maoria',
	    'mk'=>'makedona',
	    'ml'=>'malajalama',
	    'mn'=>'mongola',
	    'mo'=>'moldava',
	    'mr'=>'marata',
	    'ms'=>'malaja',
	    'mt'=>'malta',
	    'my'=>'birma',
	    'na'=>'naura',
	    'ne'=>'nepala',
	    'nl'=>'nederlanda',
	    'no'=>'norvega',
	    'oc'=>'okcitana',
	    'om'=>'oroma',
	    'or'=>'orijo',
	    'pa'=>'panĝaba',
	    'pl'=>'pola',
	    'ps'=>'paŝtua',
	    'pt'=>'portugala',
	    'qu'=>'keĉua',
	    'rm'=>'romanĉa',
	    'rn'=>'burunda',
	    'ro'=>'rumana',
	    'ru'=>'rusa',
	    'rw'=>'ruanda',
	    'sa'=>'sanskrito',
	    'sd'=>'sinda',
	    'sg'=>'sangoa',
	    'sh'=>'serbo-kroata',
	    'si'=>'sinhala',
	    'sk'=>'slovaka',
	    'sl'=>'slovena',
	    'sm'=>'samoa',
	    'sn'=>'ŝona',
	    'so'=>'somala',
	    'sq'=>'albana',
	    'sr'=>'serba',
	    'ss'=>'svazia',
	    'st'=>'sota',
	    'su'=>'sunda',
	    'sv'=>'sveda',
	    'sw'=>'svahila',
	    'ta'=>'tamila',
	    'te'=>'telugua',
	    'tg'=>'taĝika',
	    'th'=>'taja',
	    'ti'=>'tigraja',
	    'tk'=>'turkmena',
	    'tl'=>'filipina',
	    'tn'=>'cvana',
	    'to'=>'tongaa',
	    'tr'=>'turka',
	    'ts'=>'conga',
	    'tt'=>'tatara',
	    'tw'=>'akana',
	    'ug'=>'ujgura',
	    'uk'=>'ukrajna',
	    'ur'=>'urduo',
	    'uz'=>'uzbeka',
	    'vi'=>'vjetnama',
	    'vo'=>'volapuko',
	    'wo'=>'volofa',
	    'xh'=>'ksosa',
	    'yi'=>'jida',
	    'yo'=>'joruba',
	    'za'=>'ĝuanga',
	    'zh'=>'ĉina',
	    'zu'=>'zulua'
);    

@alfabeto = ('a','b','c',"\346",'d','e','f','g',"\370",'h',"\266",'i','j',
	      "\274",'k','l','m','n','o','p','r','s',"\376",'t','u',"\375",
	     'v','z');
@kapvortoj;

# legu la tutan indeks-dosieron

print "Legi $inxfn...\n" if ($verbose);
open INX,$inxfn or die "Ne povis malfermi $inxfn\n";
$inx=join('',<INX>);
close INX;

# traktu cxiujn unuopajn indekserojn

print "Analizi la indekserojn...\n" if ($verbose);
$inx =~ s/<art\s+mrk="([^\"]*)"\s*>(.*?)<\/art\s*>/ARTIKOLO($1,$2)/sieg;

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

# indekso de la shanghitah artikoloj
INXSHANGHITAJ();

INXLIST();

unlink($tmp_file);

#############################################################

# analizas la indeks-tekston de artikolo

sub ARTIKOLO {
    my $mrk = lc(shift @_);
    my $tekst = shift @_;

    # trovu la kapvorton
    $tekst =~ /^\s*<kap\s*>(.*?)<\/kap\s*>/si;
    my $kap = $1; $kap =~ s/\s+/ /sg;
    $kap =~ s/\*//g;
    $kap =~ s/[1-9\/]([aeio])\s*[ZCBYDV]?\s*$/\/$1/s;
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

# komparas novan dosieron kun ekzistanta,
# kaj nur che shanghoj au neekzisto alshovas
# la novan dosieron

sub diff_mv {
    my ($newfile,$oldfile) = @_;

    if ((! -e $oldfile) or (`diff -q $newfile $oldfile`)) {
	print "farite\n" if ($verbose);
	`mv $newfile $oldfile`;
    } else {
	print "(senshanghe)\n" if ($verbose);
	unlink($newfile);
    }
};

# kreas fakindekson por unuopa fako

sub FAKINX {
    my ($fak,$refs) = @_;

    $fak = uc($fak);
    my $fk = lc($fak);
    my $r;
    my $last0, $last1;

#    open OUT,">$dir/fx_$fk$html" or die "Ne povis krei $dir/fx_$fk$html\n";
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";

    select STDOUT;
    print "$dir/fx_$fk$html..." if ($verbose);
    select OUT;

    print "<html><head><title>fakindekso por ".$faknomoj{$fak}."</title>\n";
    print "$inxstl\n$cntdecl</head>\n";
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

    print "<p>$inxref</body></html>\n";
    close OUT;

    select STDOUT;
    diff_mv($tmp_file,"$dir/fx_$fk$html");
}

# kreas lingvoindekson por unuopa lingvo

sub LINGVINX {
    my ($lng,$refs) = @_;

    $lng = lc($lng);
    my $r;
    my $ln = substr($lng,0,5);
    my $lingvo = $lingvoj{$lng};  
 
#    open OUT,">$dir/lx_$ln$html" or die "Ne povis krei $dir/lx_$ln$html\n";
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";

    select STDOUT;
    print "$dir/lx_$ln$html..." if ($verbose);
    select OUT;

    $lingvo =~ s/[oe]$/a/;
    print "<html><head><title>indekso $lingvo</title>\n";
    print "$inxstl\n$cntdecl</head>\n<body>\n";    
    print "$inxref\n<h1>indekso $lingvo</h1>\n";

    foreach $ref (sort { LIT($a->[2]) cmp LIT($b->[2]) } @$refs) {
	$r=REFERENCO($ref->[0]);    
	print "$ref->[2] = <a href=\"$r\" ";
	print "target=\"precipa\">$ref->[1]</a><br>\n";
    };

    print "<p>$inxref</body></html>\n";
    close OUT;

    select STDOUT;
    diff_mv($tmp_file,"$dir/lx_$ln$html");
}

# kreas la indekson de la kapvortoj

sub KAPVORTINX {
    my $lit = $_[0];
    my $lit1 = enmetu_x($lit);
    my $vrt;
    my $r,$a,$n=0;

#    open OUT,">$dir/ix_kap$lit1$html" or 
#	die "Ne povis krei $dir/ix_kap$lit1$html\n";
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";

    select STDOUT;
    print "$dir/ix_kap$lit1$html..." if ($verbose);
    select OUT;

    print "<html><head><title>kapvortoindekso sekcio $lit1</title>\n";
    print "$inxstl\n$cntdecl</head><body>\n";
    print "$inxref\n";
    for $a (@literoj) { 
	if ($a ne $lit) {
	    print "<a href=\"ix_kap".enmetu_x($a)."$html\">"
		.Lat3_UTF8($a)."</a>\n"; 
	} else { print "<b>".Lat3_UTF8($a)."</b> "; };
    };
    print "<h1>kapvortoj ".Lat3_UTF8($lit)."...</h1>\n";

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
		print "<a href=\"ix_kap".enmetu_x($a)."$html\">"
		    .Lat3_UTF8($a)."</a>\n"; 
	    } else { print "<b>".Lat3_UTF8($a)."</b> "; };
	};
    };

    print "</body></html>\n";
    close OUT;

    select STDOUT;
    diff_mv($tmp_file,"$dir/ix_kap$lit1$html");
}

sub SIMPLKAPVORTINX {
    my $ref,$r,$n=0,$last0,$last1;

#    open OUT,">$dir/ix_kap$html" or 
#	die "Ne povis krei $dir/ix_kap$html\n";
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";

    select STDOUT;
    print "$dir/ix_kap$html..." if ($verbose);
    select OUT;

    print "<html><head><title>kapvortoindekso</title>\n";
    print "$inxstl\n$cntdecl</head><body>\n";
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

    select STDOUT;
    diff_mv($tmp_file,"$dir/ix_kap$html");
}

# kreas la inversan indekson de la kapvortoj

sub INVKAPVORTINX {
    my $lit = $_[0];
    my $lit1 = enmetu_x($lit);
    my $r,$n=0;
    my $last0,$last1;

#    open OUT,">$dir/ix_inv$lit1$html" or 
#	die "Ne povis krei $dir/ix_inv$lit1$html\n";
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";


    select STDOUT;
    print "$dir/ix_inv$lit1$html..." if ($verbose);
    select OUT;

    print "<html><head><title>inversa kapvortoindekso sekcio $lit1</title>\n";
    print "$inxstl\n$cntdecl</head><body>\n";
    print "$inxref\n";
    for $a (@invliteroj) { 
	if ($a ne $lit) {
	    print "<a href=\"ix_inv".enmetu_x($a)."$html\">"
		.Lat3_UTF8($a)."</a>\n"; 
	} else { print "<b>".Lat3_UTF8($a)."</b> "; };
    };
    print "<h1>inversa indekso ...".Lat3_UTF8($lit)."</h1>\n";

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
		print "<a href=\"ix_inv".enmetu_x($a)."$html\">"
		    .Lat3_UTF8($a)."</a>\n"; 
	    } else { print "<b>".Lat3_UTF8($a)."</b> "; };
	};
    };

    print "</body></html>\n";
    close OUT;

    select STDOUT;
    diff_mv($tmp_file,"$dir/ix_inv$lit1$html");
}

sub SIMPLINVKAPVORTINX {
    my $ref,$r,$n=0;
    my $last0,$last1;
 
#   open OUT,">$dir/ix_inv$html" or 
#	die "Ne povis krei $dir/ix_inv$html\n";
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";

    select STDOUT;
    print "$dir/ix_inv$html..." if ($verbose);
    select OUT;

    print "<html><head><title>inversa kapvortoindekso</title>\n";
    print "$inxstl\n$cntdecl</head><body>\n";
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

    select STDOUT;
    diff_mv($tmp_file,"$dir/ix_inv$html");
}

# kreas indekson de la laste shaghitaj artikoloj

sub INXSHANGHITAJ {
    my $now = time();
    my $n = 0;

    print "$dir/ix_novaj$html..." if ($verbose);

    # malfermu kaj komencu indeks-dosieron
    open INX, ">$tmp_file" or die "Ne povis malfermi $tmp_file: $!\n";
    print INX <<EOH;
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <link titel="indekso-stilo" type="text/css" 
    rel=stylesheet href="../stl/indeksoj.css">
    <title>indekso ne artikoloj ŝanĝitaj en la lastaj $tagoj tagoj</title>
</head>
<body>
<i><a href="indeksoj.html">indeksoj</a></i><p>
<h1>ŝanĝitaj dum la lastaj $tagoj tagoj</h1>

EOH

    # malfermu kaj trakribru xml-dosierujon
    opendir DIR, $xml_dir or die "Ne povis malfermi $xml_dir: $!\n";
    for $dos (readdir DIR) {

	if ( (-f "$xml_dir/$dos") and
	     ($now - (stat("$xml_dir/$dos"))[9] < $tagoj * 24 * 60 * 60)
	     ) {
	    print INX cvs_log($dos);
	    if (++$n >= $nmax) { last; }
	}
	
    }
    closedir DIR;
    
    if ($n > 20) {
	print INX "<p><i><a href=\"indeksoj.html\">indeksoj</a></i>\n";
    }
    print INX "<body>\n</html>\n";
    close INX;

    diff_mv($tmp_file,"$dir/ix_novaj$html");
}

sub cvs_log {
    my $dos = shift;
    my ($art,$log,$head,$info,$dato);
    my $result;

    print "nova: $dos\n" if ($debug);

    # skribu vorton kaj referencon al la artikolo
    $art = $dos;
    $art =~ s/\.xml$//; 
    $result = "<a href=\"$art_dir/$art.html\" target=precipa>$art</a>";

    # eltiru informojn pri aktuala versio el "cvs log"
    $log = `$cvs_log $xml_dir/$dos`;

    $log =~ /head: ([0-9\.]+)/s;
    $head = $1;
    $head =~ s/\./\\./g;

    if ($head) {
	$log =~ /-{28}\nrevision $head\n(.*?)-{28}/s;
	$info = $1;

	$info =~ s/date: ([0-9\/]+)[^\n]*\n//;
	$dato = $1;

	# forigu la retadreson
	$info =~ s/\s*<[^>]+\@[^>]+>\s*//s;
	
	# skribu la informojn
	$info =~ s/\s*$//s;
	$head =~ s/\\//g;
	$result .= " (versio: $head $dato; $info)<p>\n";
    }

    return $result;
}

# kreas la indekson de la indeksoj

sub INXLIST {
    my $lit,$lit1;
    
#    open OUT,">$dir/indeksoj$html" or die "Ne povis krei $dir/indeksoj$html\n";
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";

    select STDOUT;
    print "$dir/indeksoj$html..." if ($verbose);
    select OUT;

    print "<html><head><title>indekslisto</title>\n";
    print "$inxstl\n$cntdecl</head><body>\n";
    print "<h2><a href=\"../titolo$html\" target=\"precipa\">";
    print "titolpa\304\235o</a></h2>\n";
    print "<h2><a href=\"../sercxo$html\" target=\"precipa\">ser\304\211o</a></h2>\n";
    print "<dl>\n";

    if ($pluraj) {
	#kapvortoj
	print "<dt>kapvortindekso\n<dd><b>";
	for $lit (@literoj) {
	    $lit1 = enmetu_x($lit);
	    print "<a href=\"ix_kap$lit1$html\">".Lat3_UTF8($lit)."</a>\n";
	};
	print "</b>\n";

	#inversa indekso
#	print "<p><a href=\"ix_inva$html\">inversa indekso</a><p>\n";

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
	    print "<a href=\"lx_$ln$html\">";
	    print "$lingvoj{$lng}</a><br>\n";
	};
    };

    #fakoj
    if (%fakoj) {
	print "<dt>fakindeksoj\n<dd>";
	for $fak (sort keys %fakoj) 
	{
	    print "<a href=\"fx_".lc($fak)."$html\">";
	    print "<img src=\"../smb/".uc($fak).".gif\"";
	    my $fknm=$faknomoj{uc($fak)};
	    print "alt=\"$fknm\" border=0></a>\n";
	};
    };

    # aliaj 
    print "<dt>aliaj indeksoj\n<dd>";
    print "<a href=\"ix_inva$html\">inversa indekso</a><br>\n";
    print "<a href=\"ix_novaj$html\">ŝanĝitaj artikoloj</a>\n";

    print "</dl>\n";

    print "</body></html>\n";
    close OUT;

    select STDOUT;
    diff_mv($tmp_file,"$dir/indeksoj$html");
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

    # konverti la e-literojn de UTF-8 al cx ... ux
    $vort =~ s/\304[\210\211]/cx/g;
    $vort =~ s/\304[\234\235]/gx/g;
    $vort =~ s/\304[\244\245]/hx/g;
    $vort =~ s/\304[\264\265]/jx/g;
    $vort =~ s/\305[\234\235]/sx/g;
    $vort =~ s/\305[\254\255]/ux/g;

    # forigi finajxon
    $vort =~ s/[\/1-9](?:[aeio]|oj)$//;
    # forigi cxiujn ne-literojn
    $vort =~ s/[^a-z]//g;
    return $vort;
}

# funkcio por inversa esperanta ordigado
# kun speciala atento de finajhoj, se ili
# estas apartigitaj per / au cifero kiel en PIV

sub INVLIT {
    my $vort = reverse(lc($_[0]));

    # konverti la e-literojn de UTF-8 al cx ... ux
    $vort =~ s/[\210\211]\304/cx/g;
    $vort =~ s/[\234\235]\304/gx/g;
    $vort =~ s/[\244\245]\304/hx/g;
    $vort =~ s/[\264\265]\304/jx/g;
    $vort =~ s/[\234\235]\305/sx/g;
    $vort =~ s/[\254\255]\305/ux/g;

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
	if ($ref =~ /^([^\.]*)\.(.*)$/) {
	    my $r1=$1; my $r2=$2;
	    $rez="$refdir".lc($r1)."$html#".uc($r2);
	} else {
	    $rez="$refdir".lc($ref)."$html";
	};
    };
    return $rez;
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

sub Lat3_UTF8 {
    my $vort = $_[0];
    $vort =~ s/\346/\304\211/g;
    $vort =~ s/\370/\304\235/g;
    $vort =~ s/\266/\304\245/g;
    $vort =~ s/\274/\304\265/g;
    $vort =~ s/\376/\305\235/g;
    $vort =~ s/\375/\305\255/g;
    return $vort;
}







