#!/usr/bin/perl -w

# kreas el dosiero indekso.sgml
# unuopajn indeksojn en HTML-formato
# por la diversaj fakoj, lingvoj ktp.

# voku ekz: 
#   cd revo
#   indeks.pl -v -dinx -r../art/ sgm/indekso.xml 

##########################################################

BEGIN {
  # en kiu dosierujo mi estas?
  $pado = $0;
  $pado =~ s|\\|/|g; # sub Windows anstatauigu \ per /
  $pado =~ s/indeks.pl$//;
  # shargu la funkcio-bibliotekon
#  require $pado."nls_sort.pm";
#  import nls_sort qw(cmp_nls);

  push @INC, ($pado); #print join(':',@INC);
  require nls_sort;
  nls_sort->import();
}         

################### agordejo ##############################

#$debug = 1;

$tmp_file = '/tmp/'.$$.'voko.inx';

$tagoj   = 14;       # shanghindekso indikas shanghitajn en la lastaj n tagoj
$xml_dir = 'xml';    # relative al vortara radidosierujo
$art_dir = '../art'; # relative al inx
$nmax    = 200;      # maksimume tiom da shanghitajn artikolojn indiku
$cvs_log = '/usr/bin/cvs log';
$neliteroj = '0-9\/\s,;\(\)\.\-!:';

%faknomoj=(
	'2MAN'=>'komunuza senco',
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
	    'bi'=>'bislama',
	    'bn'=>'bengala',
	    'bo'=>'tibeta',
	    'br'=>'bretona',
	    'ca'=>'kataluna',
	    'co'=>'korsika',
	    'cs'=>'ĉeĥa',
	    'cy'=>'kimra',
	    'da'=>'dana',
	    'de'=>'germana',
	    'dz'=>'dzonka',
	    'el'=>'greka',
	    'en'=>'angla',
	    'eo'=>'esperanta',
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
	    'ia'=>'interlingvaa',
	    'id'=>'indonezia',
	    'ie'=>'okcidentala',
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
	    'sa'=>'sanskrita',
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
	    'vo'=>'volapuka',
	    'wo'=>'volofa',
	    'xh'=>'ksosa',
	    'yi'=>'jida',
	    'yo'=>'joruba',
	    'za'=>'ĝuanga',
	    'zh'=>'ĉina',
	    'zu'=>'zulua'
);    

################## precipa programparto ###################

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

# enhavos post analizo la informojn de la indeks-dosiero
%kapvortoj = ();        # %kapvortoj{litero}->@[mrk,kap,rad]
%invvortoj = ();     # sama strukturo
%fakoj = ();            # %fakoj{fako}->@[mrk,kap,rad]
%tradukoj = ();         # %tradukoj{lingvo}->%{litero}->@[mrk,kap,trd]

# legu la tutan indeks-dosieron

print "Legi kaj analizi $inxfn...\n" if ($verbose);
$/ = '</art';
open INX, $inxfn or die "Ne povis malfermi $inxfn\n";
while (<INX>) {
    artikolo($_);
}
close INX;

# traktu cxiujn unuopajn indekserojn

#print "Analizi la indekserojn...\n" if ($verbose);
#$inx =~ s/<art\s+mrk="([^\"]*)"\s*>(.*?)<\/art\s*>/artikolo($1,$2)/sieg;

# kreu la html-dosierojn

# fakindeksoj
foreach $fako (sort keys %fakoj) { FAKINX($fako,$fakoj{$fako}) }

# lingvoindeksoj
foreach $lng (sort keys %tradukoj) { 
    @literoj = sort { cmp_nls($a,$b,$lng) } keys %{$tradukoj{$lng}};
    $unua_litero{$lng} = letter_asci_nls($literoj[0],$lng);
    foreach $lit (@literoj) {
	$refs = $tradukoj{$lng}->{$lit};
	@$refs = sort { cmp_nls($a->[2],$b->[2],$lng) } @$refs;
	LINGVINX($lng,$lit,\@literoj,$refs);
    }
}


# kapvortoj
@literoj = sort {cmp_nls($a,$b,'eo')} keys %kapvortoj;
foreach $lit (@literoj) {
    $refs = $kapvortoj{$lit};
    @$refs = sort { cmp_nls($a->[2],$b->[2],'eo') } @$refs;
    KAPVORTINX($lit,\@literoj,$refs);
}

# inversa indekso
@literoj = sort { cmp_nls($a,$b,'eo')} keys %invvortoj;
$unua_litero{'inv'} = letter_asci_nls($literoj[0],'eo');
foreach $lit (@literoj) {
    $refs = $invvortoj{$lit};
    @$refs = sort { cmp_nls($a->[2],$b->[2],'eo') } @$refs;
    INVVORTINX($lit,\@literoj,$refs);
}

# indekso de la shanghitaj artikoloj
INXSHANGHITAJ();

# indekso de la indeksoj
INXLIST();

unlink($tmp_file);

############## funkcioj por analizi la indeks-dosieron ##############

# analizas la indeks-tekston de artikolo

sub artikolo {
    my $tekst = shift;
    my ($mrk,$kap,$rad,$first_lit,$last_lit);

    # elprenu la markon
    $tekst =~ s/^.*?<art\s+mrk="([^\"]*)"\s*>//s;
    $mrk = $1;
    unless ($mrk) {
	# se ne estas vosto de la dosiero, plendu
	if ($tekst =~ /<\/art$/) {
	    warn "marko ne trovighis en $tekst\n";
	}
	return;
    }

    # trovu la kapvorton
    $tekst =~ /^\s*<kap\s*>(.*?)<\/kap\s*>/s;
    $kap = $1;
    unless ($kap) {
	warn "kapvorto ne trovighis en $tekst\n";
    }
    # normigu la kapvorton
    $kap =~ s/\s+/ /sg;
    #$kap =~ s/\*//g;
    #$kap =~ s/[1-9\/]([aeio])\s*[ZCBYDV]?\s*$/\/$1/s;
    $kap =~ s/\s+$//s;
    $kap =~ s/\/$//;
    $kap =~ s/^\s+//;

    # prenu radikon
    $rad = $kap;
    $rad =~ s/\/(?:[aeio]|oj)$//; # forigu finajhon
    $rad =~ s/[$neliteroj]//g;

    # unua kaj lasta litero
    $first_lit = letter_nls(first_utf8char($rad),'eo');
    $last_lit  = letter_nls(last_utf8char($rad),'eo');

    unless ($first_lit) {
	die "$rad ne komencighas je e-a litero\n";
    }

    unless ($last_lit) {
	die "$rad ne finighas je e-a litero\n";
    }

    # aldonu al kapvortlistoj
    push @{ $kapvortoj{$first_lit} }, [$mrk,$kap,$rad];
    push @{ $invvortoj{$last_lit } }, [$mrk,$kap,reverse_utf8($rad)];

    # se la teksto entenas derivajho(j)n,
    # analizu nur tiujn, alikaze la tutan tekston

    if ($tekst =~/<drv/) {
	$tekst =~ s/<drv\s*(?:mrk="([^\"]*)")?\s*>(.*?)<\/drv\s*>/
	    indeksero($mrk,$1,$2)/siegx;
    } else { 
	indeksero($mrk,$mrk,$tekst);
    };

    return '';
}

# analizas unuopan indekseron

sub indeksero {
    my ($mrk1,$mrk2,$tekst) = @_;
    my ($kap,$rad);
    my $mrk = ($mrk2 or $mrk1);

    # trovu la kapvorton
    $tekst =~ s/^\s*<kap\s*>(.*?)<\/kap\s*>//si;
    $kap = $1; 
    $kap =~ s/\s+/ /sg;
    #$kap =~ s/\*//g;
    #$kap =~ s/[1-9\/]([aeio])Z?$/\/$1/;
    $kap =~ s/\s+$//;
    $kap =~ s/\/$//;
    $kap =~ s/^\s+//;

    # prenu radikon
    $rad = $kap;
    $rad =~ s/\/(?:[aeio]|oj)$//; # forigu finajhon
    $rad =~ s/[$neliteroj]//g;

    # aldonu al kapvortlisto
#    push @kapvortoj, [$mrk,$kap];

    # analizu la fakojn
    $tekst =~ s/<uzo\s*>(.*?)<\/uzo\s*>/fako($1,$mrk,$kap,$rad)/sieg;
    # analizu la tradukojn
    $tekst =~ s/<trd\s+lng="([^\"]*)"\s*>(.*?)<\/trd\s*>/
	traduko($2,$1,$mrk,$kap)/siegx;

    return '';
}

# notas unopan fakindikon

sub fako {
    my ($fak,$mrk,$kap,$rad)=@_;

    $kap =~ s/\///;
    push @{ $fakoj{$fak} }, [$mrk,$kap,$rad];

    return '';
};

# notas unuopan tradukon

sub traduko {
    my ($trd,$lng,$mrk,$kap)=@_;
    my $letter;
    $kap =~ s/\///;

    # sub kiu litero aperu la vorto?
    $letter = letter_nls($trd,$lng);

    # enmetu la vorton sub $tradukoj{$lng}->{$letter}
    push @{$tradukoj{$lng}->{$letter}}, [$mrk,$kap,$trd];

    return '';
};

############### funkcioj por krei la indeks-html-ojn ###########


# kreas fakindekson por unuopa fako

sub FAKINX {
    my ($fako,$refs) = @_;
    my ($va, $vb, $r);
    my $last0 = '';
    my $last1 = '';
    my $n = 0;
    my @vortoj;
    my $target_file = "$dir/fx_".lc($fako).".html";

    # ek
    print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;
    index_header($faknomoj{uc($fako)},'','','');
    
    # ordigu la vortliston
    @vortoj = sort { cmp_nls($a->[2],$b->[2],'eo') } @$refs;

    # skribu la liston kiel html sen duoblajhoj
    foreach $ref (@vortoj) {
	if (($last0 ne $ref->[0]) or ($last1 ne $ref->[1])) {
	    $r = referenco($ref->[0]);
	    print "<a href=\"$r\" target=\"precipa\">";
	    print "$ref->[1]</a><br>\n";
	    $last0 = $ref->[0];
	    $last1 = $ref->[1];
	    $n++;
	};
    };

    # malek
    index_footer($n > 20);
    close OUT;
    select STDOUT;
    diff_mv($tmp_file,$target_file);
}

# kreas lingvoindekson por unuopa lingvo

sub LINGVINX {
    my ($lng,$lit,$literoj,$refs) = @_;
    my $r;
    my $n=0;
    my $asci = letter_asci_nls($lit,$lng);
    my $target_file = "$dir/lx_${lng}_$asci.html";
 
    print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;
    index_header($lingvoj{$lng},"lx_${lng}_",$lng,$lit,@$literoj);

    foreach $ref (@$refs) {
	$r=referenco($ref->[0]);    
	print "$ref->[2] = <a href=\"$r\" ";
	print "target=\"precipa\">$ref->[1]</a><br>\n";
	$n++;
    };
    
    index_footer($n > 20 && "lx_${lng}_",$lng,$lit,@$literoj);
    close OUT;
    select STDOUT;
    diff_mv($tmp_file,$target_file);
}

# kreas la indekson de la kapvortoj

sub KAPVORTINX {
    my ($lit,$literoj,$refs) = @_;
    my $l_x = utf8_cx($lit);
    my ($unua,$r,$a);
    my $n = 0;
    my $last0 = '';
    my $last1 = '';

    my $target_file = "$dir/ix_kap$l_x.html";

    print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;
    index_header('kapvortoj ','ix_kap','eo',$lit,@$literoj);

    foreach $ref (@$refs) {
	if (($last0 ne $ref->[0]) or ($last1 ne $ref->[1])) {
	    $r="$refdir$ref->[0].html";

	    print "<a href=\"$r\" target=\"precipa\">";
	    print "$ref->[1]</a><br>\n";
	
	    $last0 = $ref->[0];
	    $last1 = $ref->[1];
	    $n++;
	}
    }

    index_footer($n > 20 && 'ix_kap','eo',$lit,@$literoj);
    close OUT;
    select STDOUT;
    diff_mv($tmp_file,$target_file);
}


# kreas la inversan indekson de la kapvortoj

sub INVVORTINX {
    my ($lit,$literoj,$refs) = @_;
    my $l_x = utf8_cx($lit);
    my $r;
    my $last0 = '';
    my $last1 = '';
    my $n=0;
    
    my $target_file = "$dir/ix_inv$l_x.html";
    
    print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;
    index_header('inversa','ix_inv','eo',$lit,@$literoj);

    foreach $ref (@$refs) {
	if (($last0 ne $ref->[0]) or ($last1 ne $ref->[1])) {
	    $r="$refdir$ref->[0].html";

	    print "<a href=\"$r\" target=\"precipa\">";
	    print "$ref->[1]</a><br>\n";

	    $last0 = $ref->[0];
	    $last1 = $ref->[1];
	    $n++;
	};
    };

    index_footer($n > 20 && 'ix_inv','eo',$lit,@$literoj);
    close OUT;
    select STDOUT;
    diff_mv($tmp_file,$target_file);
}

# kreas indekson de la laste shaghitaj artikoloj

sub INXSHANGHITAJ {
    my $now = time();
    my $time;
    my $n = 0;
    my @files = ();

    my $target_file = "$dir/ix_novaj.html";

    print "$target_file..." if ($verbose);
    open OUT, ">$tmp_file" or die "Ne povis malfermi $tmp_file: $!\n";
    select OUT;
    index_header("laste ŝanĝitaj",'','','');

    # malfermu kaj trakribru xml-dosierujon
    opendir DIR, $xml_dir or die "Ne povis malfermi $xml_dir: $!\n";
    for $dos (readdir DIR) {

	$time = (stat("$xml_dir/$dos"))[9];
	if ( (-f "$xml_dir/$dos") and
	     ($now - $time < $tagoj * 24 * 60 * 60)) {
	    # metu tempon kaj informon en liston
	    push @files, [$time, cvs_log($dos)];

	    if (++$n >= $nmax) { last; }
	}
	
    }
    closedir DIR;

    # skribu la liston
    for $entry (sort { $b->[0] <=> $a->[0] } @files) {
	print $entry->[1];
    }

    index_footer($n>20);
    close OUT;
    select STDOUT;
    diff_mv($tmp_file,$target_file);
}


# kreas la indekson de la indeksoj

sub INXLIST {
    my ($lit,$lit1);
    my $target_file = "$dir/indeksoj.html";

    print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;

    print 
	"<html>\n<head>\n<title>indekslisto</title>\n",
	"<link titel=\"indekso-stilo\" type=\"text/css\" ",
	"rel=stylesheet href=\"../stl/indeksoj.css\">\n",
	"<meta http-equiv=\"Content-Type\" ",
	"content=\"text/html; charset=UTF-8\">\n",
	"</head>\n<body>\n",
	"<h2><a href=\"../titolo.html\" target=\"precipa\">",
	"titolpa\304\235o</a></h2>\n",
	"<h2><a href=\"../sercxo.html\" target=\"precipa\">",
	"ser\304\211o</a></h2>\n<dl>\n";


    #kapvortoj
    print "<dt>kapvortindekso\n<dd><b>";
    for $lit (@literoj) {
	$lit1 = utf8_cx($lit);
	print "<a href=\"ix_kap$lit1.html\">$lit</a>\n";
    };
    print "</b>\n";

    #lingvoj
    if (%tradukoj) {
	print "<dt>lingvoindeksoj\n<dd>";
	for $lng (sort keys %tradukoj) 
	{
	    if (-f "$dir/../smb/$lng.jpg") {
		print "<img src=\"../smb/$lng.jpg\" alt=\"$lng\"> ";
	    } else {
		print "<img src=\"../smb/xx.jpg\" alt = \"$lng\"> ";
	    }
	    print "<a href=\"lx_${lng}_$unua_litero{$lng}.html\">";
	    print "$lingvoj{$lng}</a><br>\n";
	};
    };

    #fakoj
    if (%fakoj) {
	print "<dt>fakindeksoj\n<dd>";
	for $fak (sort keys %fakoj) 
	{
	    print 
		"<a href=\"fx_", lc($fak), ".html\">",
		"<img src=\"../smb/", uc($fak), ".gif\"",
		"alt=\"", $faknomoj{uc($fak)}, "\" border=0></a>\n";
	};
    };

    # aliaj 
    print "<dt>aliaj indeksoj\n<dd>";
    print "<a href=\"ix_inv$unua_litero{'inv'}.html\">";
    print "inversa indekso</a><br>\n";
    print "<a href=\"ix_novaj.html\">ŝanĝitaj artikoloj</a>\n";

    print "</dl>\n";

    print "</body></html>\n";
    close OUT;

    select STDOUT;
    diff_mv($tmp_file,$target_file);
}

##################### helpfunkcioj por la html-oj ###########

# kunmetas html-referencon el Revo-XML-marko
sub referenco {
    my $ref=$_[0];
    my $rez;

    if ($ref =~ /^([^\.]*)\.(.*)$/) {
	my $r1=$1; my $r2=$2;
	$rez="$refdir".lc($r1).".html#".uc($r2);
    } else {
	$rez="$refdir".lc($ref).".html";
    };

    return $rez;
};

sub utf8_cx {
    $vort = shift;
    $vort =~ s/\304\210/Cx/g;
    $vort =~ s/\304\234/Gx/g;
    $vort =~ s/\304\244/Hx/g;
    $vort =~ s/\304\264/Jx/g;
    $vort =~ s/\305\234/Sx/g;
    $vort =~ s/\305\254/Ux/g;
    $vort =~ s/\304\211/cx/g;
    $vort =~ s/\304\235/gx/g;
    $vort =~ s/\304\245/hx/g;
    $vort =~ s/\304\265/jx/g;
    $vort =~ s/\305\235/sx/g;
    $vort =~ s/\305\255/ux/g;      
    return $vort;
}

# skribas la supran parton de html-ajho
sub index_header {
    my ($title_base,$file_base,$lng,$letter,@letters) = @_;
    my ($l_utf8, $l_x);

    print 
	"<html>\n<head>\n<title>$title_base $letter</title>\n",
	"<link titel=\"indekso-stilo\" type=\"text/css\" ",
	"rel=stylesheet href=\"../stl/indeksoj.css\">\n",
	"<meta http-equiv=\"Content-Type\" ",
	"content=\"text/html; charset=UTF-8\">\n",
	"</head>\n<body>\n",
	"<i><a href=\"indeksoj.html\">indeksoj</a></i>\n";

    for $l (@letters) {
	$l_x    = letter_asci_nls($l,$lng);

	if ($l ne $letter) {
	    print "<a href=\"$file_base$l_x.html\">$l</a>\n"; 
	} else { 
	    print "<b>$l</b>\n"; 
	};
    };
    print "<h1>$title_base";
    print " $letter..." if ($letter);
    print "</h1>\n";
}

# skribas la suban parton de html-ajho
sub index_footer {
    my ($file_base,$lng,$letter,@letters) = @_;
    my $l_x;

    if ($file_base) {
	print "<p><i><a href=\"indeksoj.html\">indeksoj</a></i>\n";
	for $l (@letters) { 

	    $l_x    = letter_asci_nls($l,$lng);

	    if ($l ne $letter) {
		print "<a href=\"$file_base$l_x.html\">$l</a>\n"; 
	    } else { 
		print "<b>$l</b>\n"; 
	    };
	};
    };

    print "</body>\n</html>\n";
}


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


# elprenas informojn el "cvs log"
sub cvs_log {
    my $dos = shift;
    my ($art,$log,$head,$info,$dato);
    my $result;

    #print "nova: $dos\n" if ($verbose);

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
	$log =~ /-{28}\nrevision $head\n(.*?)(?:-{28}|={28})/s;
	$info = $1;

	unless ($info) {
	    warn "$dos: Ne povis elpreni versioinformon el $log\n";
	    return;
	}

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

#################################################################










