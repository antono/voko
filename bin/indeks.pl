#!/usr/bin/perl -w

# kreas el dosiero indekso.sgml
# unuopajn indeksojn en HTML-formato
# por la diversaj fakoj, lingvoj ktp.

# voku ekz: 
#   cd revo
#   indeks.pl -v cfg/vortaro.cfg

##########################################################

BEGIN {
  # en kiu dosierujo mi estas?
  $pado = $0;
  $pado =~ s|\\|/|g; # sub Windows anstatauigu \ per /
  $pado =~ s/indeks.pl$//;

  push @INC, ($pado); #print join(':',@INC);
  require nls;
  "nls"->import();
  nls::read_nls_cfg("$pado/../cfg/nls.cfg");
}         

################### agordejo ##############################

#$debug = 1;

$tmp_file = '/tmp/'.$$.'voko.inx';

$tagoj   = 14;       # shanghindekso indikas shanghitajn en la lastaj n tagoj
$xml_dir = 'xml';    # relative al vortara radidosierujo
$art_dir = '../art'; # relative al inx
$nmax    = 300;      # maksimume tiom da shanghitajn artikolojn indiku
$cvs_log = '/usr/bin/cvs log';
$neliteroj = '0-9\/\s,;\(\)\.\-!:';

$tez_lim1 = 5; # nodoj kun malpli da subnodoj -> grizaj 
$tez_lim2 = 25; # nodoj kun pli da subnodoj -> grasaj

################## precipa programparto ###################

$|=1;

# analizu la argumentojn

while (@ARGV) {
    if ($ARGV[0] eq '-v') {
	$verbose = 1;
	shift @ARGV;
    } else {
	$agord_dosiero=shift @ARGV;
    }
}

# legu la agordo-dosieron
unless ($agord_dosiero) { $agord_dosiero = "cfg/vortaro.cfg" };

%config = read_cfg($agord_dosiero);

$vortaro_pado=$config{"vortaro_pado"} || 
    die "vortaro_pado ne trovighis en la agordodosiero.\n";

$inxfn=$config{"inxtmp_dosiero"} || 
    $config{"indekso_dosiero"} || "$vortaro_pado/sgm/indekso.xml";
$indeksoj=$config{"indeksoj"} || "kapvortoj,lingvoj,fakoj,inversa,shanghitaj";

$dir="$vortaro_pado/inx";
$refdir = '../art/';

# enhavos post analizo la informojn de la indeks-dosiero
%statistiko =();
%kapvortoj = ();        # %kapvortoj{litero}->@[mrk,kap,rad]
%invvortoj = ();        # sama strukturo
%fakoj = ();            # %fakoj{fako}->@[mrk,kap,rad]
%tradukoj = ();         # %tradukoj{lingvo}->%{litero}->@[mrk,kap,trd]
@bildoj = ();           # @bildoj->@[mrk,kap,tekst,rad]


# legu la fakojn
%faknomoj = read_cfg($config{"fakoj"});

# legu la tutan indeks-dosieron

print "Legi kaj analizi $inxfn...\n" if ($verbose);
$/ = '</art';
open INX, $inxfn or die "Ne povis malfermi $inxfn\n";
while (<INX>) {
    artikolo($_);
}
close INX;
$/ = "\n";

# traktu cxiujn unuopajn indekserojn

#print "Analizi la indekserojn...\n" if ($verbose);
#$inx =~ s/<art\s+mrk="([^\"]*)"\s*>(.*?)<\/art\s*>/artikolo($1,$2)/sieg;

# kreu la html-dosierojn

# fakindeksoj
if ($indeksoj=~/fak/) {

    # kiuj fakoj havas tezauran indekson?
    open TEZ,$config{"tezauro_fakoj"} || 
	die "Ne povis legi ".$config{"tezauro_fakoj"}."\n";
    while (<TEZ>) {
	chomp;
	my ($file,$fak) = split(';');
	$strukt_fakoj{$fak} = $file;
    }
    close TEZ;

    # kreu fakindeksojn
    foreach $fak (sort keys %fakoj) { FAKINX($fak,$fakoj{$fak}) }
}

# lingvoindeksoj
if ($indeksoj=~/lng/) {
    # legu la lingvojn
    %lingvoj=read_cfg($config{"lingvoj"});
    # kreu la lingvoindeksojn
    foreach $lng (sort keys %tradukoj) { 
	@literoj = sort { cmp_nls($a,$b,$lng) } keys %{$tradukoj{$lng}};
	$unua_litero{$lng} = letter_asci_nls($literoj[0],$lng);
	foreach $lit (@literoj) {
	    $refs = $tradukoj{$lng}->{$lit};
	    @$refs = sort { cmp_nls($a->[2],$b->[2],$lng) } @$refs;
	    LINGVINX($lng,$lit,\@literoj,$refs);
	}
    }
}

# kapvortoj
if ($config{"inx_eo"}=~/kapvortoj/) {
    @literoj = sort {cmp_nls($a,$b,'eo')} keys %kapvortoj;
    foreach $lit (@literoj) {
	$refs = $kapvortoj{$lit};
	@$refs = sort { cmp_nls($a->[2],$b->[2],'eo') } @$refs;
	KAPVORTINX($lit,\@literoj,$refs);
    }
}

# inversa indekso
if ($config{"inx_ktp"}=~/inversa/) {
    @invliteroj = sort { cmp_nls($a,$b,'eo')} keys %invvortoj;
    $unua_litero{'inv'} = letter_asci_nls($invliteroj[0],'eo');
    foreach $lit (@invliteroj) {
	$refs = $invvortoj{$lit};
	@$refs = sort { cmp_nls($a->[2],$b->[2],'eo') } @$refs;
	INVVORTINX($lit,\@invliteroj,$refs);
    }
}

# bildindekso
if ($config{"inx_ktp"}=~/bildoj/) { INXBILDOJ(\@bildoj); }

# statistiko
if ($config{"inx_ktp"}=~/statistiko/) { INXSTATISTIKO(); }

# indekso de la shanghitaj artikoloj
if ($config{"inx_ktp"}=~/shanghitaj/) { INXSHANGHITAJ(); }


# indekso de la indeksoj
if ($indeksoj=~/eo/)  { INX_EO();  }
if ($indeksoj=~/lng/) { INX_LNG(); }
if ($indeksoj=~/fak/) { INX_FAK(); }
if ($indeksoj=~/ktp/) { INX_KTP(); }
if ($indeksoj=~/plena/) { INX_PLENA(); }
unlink($tmp_file);

############## funkcioj por analizi la indeks-dosieron ##############

# analizas la indeks-tekston de artikolo

sub artikolo {
    my $tekst = shift;
    my ($mrk,$kap,$rad,$first_lit,$last_lit);

    # statistikaj informoj
    $statistiko{'art'}++;
    while ($tekst =~ m/<drv\b/g) { $statistiko{'drv'}++ };
    while ($tekst =~ m/<bld\b/g) { $statistiko{'bld'}++ };
    while ($tekst =~ m/lng="([a-z]{2})"/g) { $statistiko{"lng_$1"}++ };
    while ($tekst =~ m/<uzo>([A-Z]+)<\/uzo>/g) { $statistiko{"fak_$1"}++ unless ($1 eq 'KOMUNE')};

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

    print "kap: $kap\n" if ($debug);

    # normigu la kapvorton
    $kap =~ s/\s+/ /sg;
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

    print "1a: $first_lit; l-a: $last_lit\n" if ($debug);

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

    # unue analizu de bildoj kaj ekzemploj
    $tekst =~ s/<ekz\s*>(.*?)<\/ekz\s*>/ekzemplo($mrk,$kap,$1,$rad)/sieg;
    $tekst =~ s/<bld\s*>(.*?)<\/bld>/bildo($mrk,$kap,$1,$rad)/sieg;

    # analizu la fakojn
    $tekst =~ s/<uzo\s*>(.*?)<\/uzo\s*>/fako($1,$mrk,$kap,$rad)/sieg;
    # analizu la tradukojn
    $tekst =~ s/<trd\s+lng="([^\"]*)"\s*>(.*?)<\/trd\s*>/
	traduko($2,$1,$mrk,$kap)/siegx;

    return '';
}

sub ekzemplo {
    my ($mrk,$kap,$tekst,$rad)=@_;
    my $ind;

    # tio, kio estas tradukita
    if ($tekst =~ s/<ind\s*>(.*?)<\/ind\s*>//si) {
	$ind = $1;

	# mallongigita?
	if ($ind =~ s/<mll([^>]*)>(.*?)<\/mll\s*>//si) {
	    $ind = $2;
	    my $attr = $1;
	    if ($attr =~ /\"kom\"/) { $ind .= '...'; }
	    elsif ($attr =~ /\"fin\"/) { $ind = '...'.$ind; }
	    elsif ($attr =~ /\"mez\"/) { $ind = '...'.$ind.'...'; }
	}

    } else {
	$ind = $kap; # referencu al kapvorto, se mankas <ind>...</ind>
    }

    # analizu la fakojn
    $tekst =~ s/<uzo\s*>(.*?)<\/uzo\s*>/fako($1,$mrk,$ind,$rad)/sieg;
    # analizu la tradukojn
    $tekst =~ s/<trd\s+lng="([^\"]*)"\s*>(.*?)<\/trd\s*>/
	traduko($2,$1,$mrk,$ind)/siegx;

    return '';
}


# notas unopan fakindikon

sub fako {
   my ($fak,$mrk,$kap,$rad)=@_;

   unless ($faknomoj{uc($fak)}) {
        warn "Fako \"$fak\" ne difinita ($mrk)\n";
    }            

    $kap =~ s/\///;
    push @{ $fakoj{$fak} }, [$mrk,$kap,$rad];

    return '';
};

# notas unuopan bildon

sub bildo {
    my ($mrk,$kap,$tekst,$rad)=@_;
    my $ind;

    $kap =~ s/\///;
    my $bldpriskr = $tekst;
    $bldpriskr =~ s/<trd.*?<\/trd\s*>//sg;
    $bldpriskr =~ s/<uzo.*?<\/uzo\s*>//sg;

    push @bildoj, [$mrk,$kap,$bldpriskr,$rad];

    # tio, kio estas tradukita
    if ($tekst =~ s/<ind\s*>(.*?)<\/ind\s*>//si) { 
	$ind = $1; 
    } else { 
	$ind = $kap; # referencu al kapvorto, se mankas <ind>...</ind>
    }

    # analizu la fakojn
    $tekst =~ s/<uzo\s*>(.*?)<\/uzo\s*>/fako($1,$mrk,$ind,$rad)/sieg;
    # analizu la tradukojn
    $tekst =~ s/<trd\s+lng="([^\"]*)"\s*>(.*?)<\/trd\s*>/
	traduko($2,$1,$mrk,$ind)/siegx;

    
    return '';
};
    

# notas unuopan tradukon

sub traduko {
    my ($trd,$lng,$mrk,$kap)=@_;
    my ($letter,$ind);
    $kap =~ s/\///;

    # mallongigita?
    if ($trd =~ s/<mll([^>]*)>(.*?)<\/mll\s*>//si) {
	$trd = $2;
	my $attr = $1;
	if ($attr =~ /\"kom\"/) { $trd .= '...'; }
	elsif ($attr =~ /\"fin\"/) { $trd = '...'.$trd; }
	elsif ($attr =~ /\"mez\"/) { $trd = '...'.$trd.'...'; }
    }

    if ($trd =~ /<ind>(.*?)<\/ind>/s) {
	$ind = $1;
    } else {
	$ind = $trd;
	# klarigojn ne konsideru che ordigado
	$ind =~  s/<klr>(.*?)<\/klr>//sg;
    }

    # komencaj spacoj ghenus ordigadon
    $ind=~s/^\s*//s;

    # sub kiu litero aperu la vorto?
    $letter = letter_nls($ind,$lng);

    print "trd: $trd ($letter)\n" if ($debug);

    # enmetu la vorton sub $tradukoj{$lng}->{$letter}
    push @{$tradukoj{$lng}->{$letter}}, [$mrk,$kap,$ind,$trd];

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
    my $faknomo;
    my $target_file = "$dir/fx_".lc($fako).".html";

    # ek
    #print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;
    unless ($faknomo=$faknomoj{uc($fako)}) {
	warn "Fako \"$fako\" ne difinita\n";
	$faknomo='';
    }

    index_header("fakindekso: $faknomo");
    linkbuttons();
    if ($strukt_fakoj{$fako}) {
	$strukt_file = $strukt_fakoj{$fako};
	$strukt_file =~ s/\.html$//;
	index_letters($faknomo,'','alfabete',
		     ['alfabete','strukture'],
		     ['fx_'.lc($fako),$strukt_file]);
    } else {
	index_letters($faknomo,'','');
    }

#    print "<h1>$faknomo alfabete...</h1>\n";
    
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
    index_footer();
    close OUT;
    select STDOUT;
    diff_mv($tmp_file,$target_file);
}

# kreas lingvoindekson por unuopa lingvo

sub LINGVINX {
    my ($lng,$lit,$literoj,$refs) = @_;
    my $r;
    my $n=0;
    my $last1 = '';
    my $last2 = '';
    my $trd;
    my $asci = letter_asci_nls($lit,$lng);
    my $target_file = "$dir/lx_${lng}_$asci.html";
 
    #print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;
    index_header("lingvoindekso: $lingvoj{$lng}");
    linkbuttons();
    index_letters($lingvoj{$lng},"lx_${lng}_",$lit,$literoj,
		 [map {letter_asci_nls($_,$lng)} @$literoj]);
#    print "<h1>$lingvoj{$lng} $lit...</h1>\n";

    foreach $ref (@$refs) {
	if (($last1 ne $ref->[1]) or ($last2 ne $ref->[3])) {
	    $r=referenco($ref->[0]);    

	    $trd = $ref->[3];
	    $trd =~ s/(<\/?)ind>/$1u>/sg;

	    print "$trd = <a href=\"$r\" ";
	    print "target=\"precipa\">$ref->[1]</a><br>\n";
	    $last1 = $ref->[1];
	    $last2 = $ref->[3];
	    $n++;
	}
    };
    
    index_footer();
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

    my $target_file = "$dir/kap_$l_x.html";

    #print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;
    index_header("kapvortindekso");
    linkbuttons();
    index_letters('kapvortoj ','kap_',$lit,$literoj,
		 [map {letter_asci_nls($_,'eo')} @$literoj]);
#    print "<h1>kapvortoj $lit...</h1>\n";

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

    index_footer();
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
    
    my $target_file = "$dir/inv_$l_x.html";
    
    #print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;
    index_header("inversa indekso");
    linkbuttons();
    index_letters('inversa','inv_',$lit,$literoj,
		[map {letter_asci_nls($_,'eo')} @$literoj] );
#    print "<h1>inversa $lit...</h1>\n";

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

    index_footer();
    close OUT;
    select STDOUT;
    diff_mv($tmp_file,$target_file);
}

# kreas indekson de la laste shanghitaj artikoloj

sub INXSHANGHITAJ {
    my $now = time();
    my $time;
    my $n = 0;
    my @files = ();

    my @novaj = ();
    my %shangh = ();

    # prenu tempon kaj dosiernomon de la xml-dosieroj
    opendir DIR, $xml_dir or die "Ne povis malfermi $xml_dir: $!\n";
    for $dos (readdir DIR) {

	$time = (stat("$xml_dir/$dos"))[9];
	if ( (-f "$xml_dir/$dos") and
	     ($now - $time < $tagoj * 24 * 60 * 60)) {
	    # metu tempon kaj informon en liston
	    push @files, [$time, $dos];
	}
    }
    closedir DIR;

    # traktu la lastajn (lau tempo) nmax dosierojn
    # kaj ordigu lau redaktantoj, novaj venu krome en apartan liston

    for $entry (sort { $b->[0] <=> $a->[0] } @files) {
	my ($autoro, $priskribo) = cvs_log($entry->[1]);
	push @{$shangh{$autoro}}, ($priskribo);
	if ($priskribo =~ /<dd>\s*nova\s+artikolo\s*$/) {
	    $priskribo =~ s/<dd>.*$/<dd>de $autoro\n/s;
	    push @novaj, ($priskribo);
        }

	if (++$n >= $nmax) { last; }
    }

    # dosiero "novaj artikoloj"
    my $target_file = "$dir/novaj.html";

    #print "$target_file..." if ($verbose);
    open OUT, ">$tmp_file" or die "Ne povis malfermi $tmp_file: $!\n";
    select OUT;
    index_header("Revo - novaj artikoloj");
    linkbuttons();
    print "<h1>novaj artikoloj</h1>\n";

    # skribu la liston
    if (@novaj) {
	print "<dl>\n";
	for $entry (@novaj) { print $entry; }
	print "</dl>\n";
    } else {
	print "neniuj novaj artikoloj en la lastaj $nmax redaktoj";
    }

    index_footer();
    close OUT;
    select STDOUT;
    diff_mv($tmp_file,$target_file);

    # dosiero "shanghitaj artikoloj"
    $target_file = "$dir/shanghitaj.html";

    #print "$target_file..." if ($verbose);
    open OUT, ">$tmp_file" or die "Ne povis malfermi $tmp_file: $!\n";
    select OUT;
    index_header("laste ŝanĝitaj");
    linkbuttons();
    print "<h1>laste ŝanĝitaj</h1>\n";

    # skribu la liston de redaktintoj
    print "<ul>\n";
    for $aut (sort keys %shangh) {
	$aut_ = $aut; $aut_ =~ s/\s+/_/g;
	print "<li><a href=\"#$aut_\">$aut</a>\n";
    }
    print "</ul>\n\n";
    
    # skribu la listojn de redaktoj lau autoro
    for $aut (sort keys %shangh) {
	$aut_ = $aut; $aut_ =~ s/\s+/_/g;
	print "<hr><a name=\"$aut_\"></a>\n<h2>$aut</h2>\n";

	print "<dl>\n";
	for $entry ( @{$shangh{$aut}} ) { print $entry; }
	print "</dl>\n";
    }

    index_footer();
    close OUT;
    select STDOUT;
    diff_mv($tmp_file,$target_file);

}

# kreas indekson de la bildoj

sub INXBILDOJ {
    my ($refs) = @_;
    my $r;
    #my $last0 = '';
    #my $last1 = '';
    my $n = 0;
    my @vortoj;
    my $target_file = "$dir/bildoj.html";

    # ek
    #print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;
    index_header('bildoj');
    linkbuttons();
    print "<h1>bildoj</h1>\n<dl>\n";
    
    # ordigu la vortliston
    @vortoj = sort { cmp_nls($a->[3],$b->[3],'eo') } @$refs;

    # skribu la liston kiel html 
    foreach $ref (@vortoj) {
#	if (($last0 ne $ref->[0]) or ($last1 ne $ref->[1])) {
	    $r = referenco($ref->[0]);
	    print "<dt><a href=\"$r\" target=\"precipa\">";
	    print "$ref->[1]</a>\n<dd>$ref->[2]\n";
	    #$last0 = $ref->[0];
	    #$last1 = $ref->[1];
	    $n++;
#	};
    };
    print "</dl>\n";

    # malek
    index_footer();
    close OUT;
    select STDOUT;
    diff_mv($tmp_file,$target_file);
}

# kreas indekson de la bildoj

sub INXSTATISTIKO {
    my $n = 0;
    my $target_file = "$dir/statistiko.html";
    my (@trdj, @fakj);

    # ek
    #print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;
    index_header('statistiko');
    linkbuttons();
    print "<h1>statistiko</h1>\n";
    
    # ordigu la vortliston
#    @vortoj = sort { cmp_nls($a->[3],$b->[3],'eo') } @$refs;

    print "<h2>kapvortoj</h2>\n";
    print "artikoloj: ".$statistiko{'art'}."<br>\n";
    print "derivaĵoj: ".$statistiko{'drv'}."<br>\n";
    print "bildoj: ".$statistiko{'bld'}."<br>\n";
    $n=3;

    print "<h2>tradukoj</h2>\n";
    foreach $s (grep(/^lng_/,keys %statistiko)) {
	push @trdj, [substr($s,4),$statistiko{$s}];
    }
    foreach $s (sort {$b->[1] <=> $a->[1]} @trdj) {
	$lng = $s->[0];
	if (-f "$vortaro_pado/smb/$lng.jpg") {
		print "<img src=\"../smb/$lng.jpg\" alt=\"\">&nbsp;";
	    } else {
		print "<img src=\"../smb/xx.jpg\" alt = \"\">&nbsp;";
	    }
	print "$lingvoj{$lng}j: ".$s->[1];
	printf(" (%.02f%%)",100*$s->[1]/$statistiko{'drv'});
	print "<br>\n";
	$n++;
    };

    print "<h2>fakoj</h2>\n";
    foreach $s (grep(/^fak_/,keys %statistiko)) {
	push @fakj, [substr($s,4),$statistiko{$s}];
    }
    foreach $s (sort {$b->[1] <=> $a->[1]} @fakj) {
	$fak = $s->[0];
	print "<img src=\"../smb/$fak.gif\" alt=\"\">&nbsp;";
	print "$faknomoj{$fak}: ".$s->[1]."<br>\n";
	$n++;
    };

    # malek
    index_footer();
    close OUT;
    select STDOUT;
    diff_mv($tmp_file,$target_file);
}

# kreas la precipajn indeksojn

sub INX_EO {
    my ($lit,$lit1);
    my $target_file = "$dir/_eo.html";

    #print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;

    index_header("Revo-indekso: Esperanto");
    linkbuttons("eo");

    #kapvortoj
    if ($config{"inx_eo"}=~/kapvortoj/) {
	print "<h1>kapvortindekso</h1>\n<font size=+1><b>";
	for $lit (@literoj) {
	    $lit1 = utf8_cx($lit);
	    print "<a href=\"kap_$lit1.html\">$lit</a>\n";
	};
	print "</b></font>\n";
    }

    #tezauroradikoj
    if ($config{"inx_eo"}=~/tezauro/) {
	print "<h1>tezaŭroradikoj</h1>\n";
	open TEZ, $config{"tezauro_radikoj"};
	while (<TEZ>) {
	    chomp;
	    s/\s+$//;
	    my ($file,$kap,$cnt) = split(';'); $cnt = 0 unless ($cnt);

	    if ($cnt > $tez_lim1) { 
		if ($cnt >= $tez_lim2) { print "<b>"; }
		print "<a href=\"$file\">$kap</a>";
		if ($cnt >= $tez_lim2) { print "</b>"; }
		print "<br>\n";
	    }
	}
    }

    index_footer();
    close OUT;

    select STDOUT;
    diff_mv($tmp_file,$target_file);
}

sub INX_LNG {
    my $target_file = "$dir/_lng.html";

    #print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;

    index_header("Revo-indekso: Lingvoj");
    linkbuttons("lng");

    #lingvoj
    print "<h1>nacilingvaj indeksoj</h1>\n";
    for $lng (sort keys %tradukoj) 
    {
	unless ($lng eq 'la') {
	    if (-f "$vortaro_pado/smb/$lng.jpg") {
		print "<img src=\"../smb/$lng.jpg\" alt=\"[$lng]\">&nbsp;";
	    } else {
		print "<img src=\"../smb/xx.jpg\" alt = \"[$lng]\">&nbsp;";
	    }
	    print "<a href=\"lx_${lng}_$unua_litero{$lng}.html\">";
	    print "$lingvoj{$lng}</a><br>\n";
	}
    };

    if (exists $tradukoj{'la'}) {
	print "<p>\n";
	$lng = 'la';
	if (-f "$vortaro_pado/smb/$lng.jpg") {
	    print "<img src=\"../smb/$lng.jpg\" alt=\"[$lng]\">&nbsp;";
	} else {
	    print "<img src=\"../smb/xx.jpg\" alt = \"[$lng]\">&nbsp;";
	}
	print "<a href=\"lx_${lng}_$unua_litero{$lng}.html\">";
	print "$lingvoj{$lng}</a><br>\n";
    }

    index_footer();
    close OUT;

    select STDOUT;
    diff_mv($tmp_file,$target_file);

}

sub INX_FAK {
    my $target_file = "$dir/_fak.html";

    #print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;

    index_header("Revo-indekso: Fakoj");
    linkbuttons("fak");

    #fakoj
    if ($config{"inx_fak"}=~/alfabetaj/ && %fakoj) {
	print "<h1>alfabetaj fakindeksoj</h1>\n";
	
	    for $fak (sort keys %fakoj) 
	    {
		my $faknomo=$faknomoj{uc($fak)};
		unless ($faknomo) {
		    warn "Faknomo \"$fak\" ne difinita!\n";
		    $faknomo = 'nekonata';
		}
		print 
		    "<img src=\"../smb/$fak.gif\" alt=\"$fak\" border=0 ",
		    "align=middle>&nbsp<a href=\"fx_", 
		    lc($fak), ".html\">$faknomo</a><br>\n";
	    }
    }
	
    if ($config{"inx_fak"}=~/tezauro/) {
	print "<h1>tezaŭraj fakindeksoj</h1>\n";
	
	for $fak (sort keys %strukt_fakoj) 
	{
	    my $faknomo=$faknomoj{uc($fak)};
	    unless ($faknomo) {
		warn "Faknomo \"$fak\" ne difinita!\n";
		$faknomo = '';
	    }
	    print 
		"<img src=\"../smb/$fak.gif\" alt=\"$fak\" border=0 ",
		"align=middle>&nbsp<a href=\"",
		$strukt_fakoj{$fak},
		"\">$faknomo</a><br>\n";
	}
    }


    index_footer();
    close OUT;

    select STDOUT;
    diff_mv($tmp_file,$target_file);
}

sub INX_KTP {
    my $target_file = "$dir/_ktp.html";

    #print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;

    index_header("Revo-indekso: ktp.");
    linkbuttons("ktp");

    # gravaj paghoj
    my @paghoj = split(';',$config{"inx_ktp_paghoj"});
    if (@paghoj) {
	print "<h1>gravaj paĝoj</h1>\n";

	while (@paghoj) {
	    my $href=shift @paghoj;
	    my $title=shift @paghoj;
	    print 
		"<a href=\"$href\" target=\"",
		($href=~/^http:/)? "_new" : "precipa",
		"\">$title</a><br>\n";
	}
    }

    # diversaj indeksoj 
    my $inx = $config{"inx_ktp"};
    if ($inx=~/(inversa|shanghitaj|bildoj|statistiko)/) {
	print "<h1>diversaj indeksoj</h1>\n";
	if ($inx=~/bildoj/) {
	    print "<a href=\"bildoj.html\">";
	    print "bildoj</a><br>\n";
	}
	if ($inx=~/inversa/) {
	    print "<a href=\"inv_$unua_litero{'inv'}.html\">";
	    print "inversa indekso</a><br>\n";
	}
	if ($inx=~/novaj/) {
	    print "<a href=\"novaj.html\">novaj ",
	    "artikoloj</a><br>\n";
	}
	if ($inx=~/shanghitaj/) {
	    print "<a href=\"shanghitaj.html\">ŝanĝitaj ",
	    "artikoloj</a><br>\n";
	}
	if ($inx=~/eraroj/) {
	    print "<a href=\"eraroj.html\">eraro-raporto</a><br>\n";
	}
	if ($inx=~/statistiko/) {
	    print "<a href=\"statistiko.html\">statistiko</a><br>\n";
	}
    }

    # listoj
    @paghoj = split(';',$config{"inx_ktp_listoj"});
    if (@paghoj) {

	while (@paghoj) {
	    my $href=shift @paghoj;
	    my $title=shift @paghoj;
	    print 
		"<a href=\"$href\" target=\"",
		($href=~/^http:/)? "_new" : "precipa",
		"\">$title</a><br>\n";
	}
    }
    
    # redakto
    @paghoj = split(';',$config{"inx_ktp_redakto"});
    if (@paghoj) {
	print "<h1>redaktado</h1>\n";

	while (@paghoj) {
	    my $href=shift @paghoj;
	    my $title=shift @paghoj;
	    print 
		"<a href=\"$href\" target=\"",
		($href=~/^http:/)? "_new" : "precipa",
		"\">$title</a><br>\n";
	}
    }

    index_footer();
    close OUT;

    select STDOUT;
    diff_mv($tmp_file,$target_file);
}

sub INX_PLENA {
    my ($lit,$lit1);
    my $target_file = "$dir/_plena.html";

    #print "$target_file..." if ($verbose);
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;

    index_header("Revo - Plena indekso");
    linkbuttons();

    #kapvortoj
    if ($config{"inx_eo"}=~/kapvortoj/) {
	print "KAPVORTOJ:\n";
	for $lit (@literoj) {
	    $lit1 = utf8_cx($lit);
	    print "<a href=\"kap_$lit1.html\">$lit</a>\n";
	};
	print "<p>\n";
    }


    #lingvoj
    print "LINGVOJ:\n";
    for $lng (sort keys %tradukoj) 
    {
	print "<a href=\"lx_${lng}_$unua_litero{$lng}.html\">";
	if (-f "$vortaro_pado/smb/$lng.jpg") {
	    print "<img src=\"../smb/$lng.jpg\" alt=\"$lng\"> ";
	} else {
	    print "<img src=\"../smb/xx.jpg\" alt = \"$lng\"> ";
	}
	print "</a>\n";
    };
    print "<p>\n";
    
    #fakoj
    if ($config{"inx_fak"}=~/alfabetaj/ && %fakoj) {
	print "FAKOJ (alfabete):\n";
	
	    for $fak (sort keys %fakoj) 
	    {
		my $faknomo=$faknomoj{uc($fak)};
		unless ($faknomo) {
		    warn "Faknomo \"$fak\" ne difinita!\n";
		    $faknomo = '';
		}
		print "<a href=\"fx_", lc($fak), ".html\">", 
		"<img src=\"../smb/$fak.gif\" alt=\"$fak\" border=0></a>\n";
	    }
    }
    print "<p>\n";
	
    if ($config{"inx_fak"}=~/tezauro/) {
	print "FAKOJ (strukture):\n";
	
	for $fak (@strukt_fakoj) 
	{
	    my $faknomo=$faknomoj{uc($fak)};
	    unless ($faknomo) {
		warn "Faknomo \"$fak\" ne difinita!\n";
		$faknomo = '';
	    }
	    print "<a href=\"fxs_", lc($fak), ".html\">",
	    "<img src=\"../smb/$fak.gif\" alt=\"$fak\" border=0></a>\n";
	}
    }
    print "<p>\n";

    # gravaj paghoj
    my @paghoj = split(';',$config{"inx_ktp_paghoj"});
    if (@paghoj) {
	print "GRAVAJ PAĜOJ:\n";

	while (@paghoj) {
	    my $href=shift @paghoj;
	    my $title=shift @paghoj;
	    print 
		"<a href=\"$href\" target=\"",
		($href=~/^http:/)? "_new" : "precipa",
		"\">$title</a>\n";
	}
    }
    print "<p>\n";

    # diversaj indeksoj 
    my $inx = $config{"inx_ktp"};
    if ($inx=~/(inversa|shanghitaj|bildoj|statistiko)/) {
	print "DIVERSAJ INDEKSOJ:\n";
	if ($inx=~/bildoj/) {
	    print "<a href=\"bildoj.html\">";
	    print "bildoj</a>\n";
	};
	if ($inx=~/inversa/) {
	    print "<a href=\"inv_$unua_litero{'inv'}.html\">";
	    print "inversa indekso</a>\n";
	};
	if ($inx=~/shanghitaj/) {
	    print "<a href=\"novaj.html\">ŝanĝitaj ",
	    "artikoloj</a>\n";
	}
	if ($inx=~/statistiko/) {
	    print "<a href=\"statistiko.html\">statistiko</a>\n";
	}
    }

    # listoj
    @paghoj = split(';',$config{"inx_ktp_listoj"});
    if (@paghoj) {

	while (@paghoj) {
	    my $href=shift @paghoj;
	    my $title=shift @paghoj;
	    print 
		"<a href=\"$href\" target=\"",
		($href=~/^http:/)? "_new" : "precipa",
		"\">$title</a>\n";
	}
    }
    print "<p>\n";
    
    # redakto
    @paghoj = split(';',$config{"inx_ktp_redakto"});
    if (@paghoj) {
	print "REDAKTADO:\n";

	while (@paghoj) {
	    my $href=shift @paghoj;
	    my $title=shift @paghoj;
	    print 
		"<a href=\"$href\" target=\"",
		($href=~/^http:/)? "_new" : "precipa",
		"\">$title</a>\n";
	}
    }
    print "<p>\n";


    #tezauroradikoj
    if ($config{"inx_eo"}=~/tezauro/) {
	print "TEZAŬRO:\n";
	open TEZ, $config{"tezauro_radikoj"};
	while (<TEZ>) {
	    my ($file,$kap,$cnt) = split(';');
	    print "<a href=\"$file\">$kap</a>\n";
	}
    }
    print "<p>\n";

    index_footer();
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
	my $r1=$1; my $r2="$1.$2";
	$rez="$refdir".lc($r1).".html#".$r2;
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

# skribas tabelon kun ligoj al precipaj indekspaghoj
sub linkbuttons {
    my $self = shift || "";
    my $bgcolor = 'bgcolor="#AACCAA"';

    print 
	"<script src=\"../smb/butonoj.js\"></script>\n",

        (($self eq 'eo')? 
	 "<img src=\"../smb/nav_eo0.png\" alt=\"[Esperanto]\" border=0>\n":
	 "<a href=\"_eo.html\" onMouseOver=\"highlight(0)\" ".
	 "onMouseOut=\"normalize(0)\">".
	 "<img src=\"../smb/nav_eo1.png\" alt=\"[Esperanto]\" border=0></a>\n"),

	(($self eq 'lng')?
	 "<img src=\"../smb/nav_lng0.png\" alt=\"[Lingvoj]\" border=0>\n":
	 "<a href=\"_lng.html\" onMouseOver=\"highlight(1)\" ".
	 "onMouseOut=\"normalize(1)\">".
	 "<img src=\"../smb/nav_lng1.png\" alt=\"[Lingvoj]\" border=0></a>\n"),

        (($self eq 'fak')?
	 "<img src=\"../smb/nav_fak0.png\" alt=\"[Fakoj]\" border=0>\n":
	 "<a href=\"_fak.html\" onMouseOver=\"highlight(2)\" ".
	 "onMouseOut=\"normalize(2)\">".
	 "<img src=\"../smb/nav_fak1.png\" alt=\"[Fakoj]\" border=0></a>\n"),

        (($self eq 'ktp')?
	 "<img src=\"../smb/nav_ktp0.png\" alt=\"[ktp.]\" border=0>\n":
	 "<a href=\"_ktp.html\" onMouseOver=\"highlight(3)\" ".
	 "onMouseOut=\"normalize(3)\">".
	 "<img src=\"../smb/nav_ktp1.png\" alt=\"[ktp.]\" border=0></a>\n"),

	"<br>";
}

# skribas la supran parton de html-ajho
sub index_header {
    my $title = shift;
    print 
	"<html>\n<head>\n<meta http-equiv=\"Content-Type\" ",
	"content=\"text/html; charset=UTF-8\">\n",
	"<title>$title</title>\n",
	"<link title=\"indekso-stilo\" type=\"text/css\" ",
	"rel=stylesheet href=\"../stl/indeksoj.css\">\n",
	"</head>\n<body>\n";
}

sub index_letters {
    my ($title_base,$file_base,$letter,$letters,$files) = @_;
    my ($l_utf8, $l_x, $file);

    for $l (@$letters) {
#	$l_x    = letter_asci_nls($l,$lng);
	$file = shift @$files;

	if ($l ne $letter) {
	    print "<a href=\"$file_base$file.html\">$l</a>\n"; 
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
    print "\n</body>\n</html>\n";
}


# komparas novan dosieron kun ekzistanta,
# kaj nur che shanghoj au neekzisto alshovas
# la novan dosieron

sub diff_mv {
    my ($newfile,$oldfile) = @_;

    if ((! -e $oldfile) or (`diff -q $newfile $oldfile`)) {
	print "$oldfile\n" if ($verbose);
	`mv $newfile $oldfile`;
    } else {
	#print "(senshanghe)\n" if ($verbose);
	unlink($newfile);
    }
};


# elprenas informojn el "cvs log"
sub cvs_log {
    my $dos = shift;
    my ($art,$log,$rev,$info,$dato,$aut);
    my $result;

    #print "nova: $dos\n" if ($verbose);

    # skribu vorton kaj referencon al la artikolo
    $art = $dos;
    $art =~ s/\.xml$//; 

    $result = "<dt><a href=\"$art_dir/$art.html\" ".
	"target=precipa><b>$art</b></a>";

    # eltiru informojn pri aktuala versio el "cvs log"
    $log = `$cvs_log -r $xml_dir/$dos`;

    if ($log) {
	$log =~ /-{28}\nrevision ([0-9\.]+)\n(.*?)={28}/s;
	$rev = $1; # ne uzata nun
	$info = $2;

	unless ($info) {
	    warn "$dos: Ne povis elpreni versioinformon el $log\n";
	    return;
	}

	$info =~ s/date: ([0-9\/]+)[^\n]*\n//;
	$dato = $1;

	# forigu la retadreson
	$info =~ s/\s*<[^>]+\@[^>]+>\s*//s;

	# elprenu la autoron
	if ($info =~ s/^([a-z \.]+)://si) { $aut = $1; }
	else {$aut = "revo"; }

	# skribu la informojn
	$info =~ s/\s*$//s;
	$info =~ s/&/&amp;/g;
	$info =~ s/</&lt;/g;
	$info =~ s/>/&gt;/g;
	$result .= " <span class=dato>$dato</span>\n<dd>$info\n";
    } else {
	$result .= "\n<dd>(mankas informo)\n";
    }

    return ($aut,$result);
}

sub read_cfg {
    $cfgfile = shift;
    my %hash = ();

    open CFG, $cfgfile 
	or die "Ne povis malfermi dosieron \"$cfgfile\": $!\n";

    while ($line = <CFG>) {
	if ($line !~ /^#|^\s*$/) {
	    $line =~ /^([^=]+)=(.*)$/;
	    $hash{$1} = $2;
	}
    }
    close CFG;
    return %hash;
}

#################################################################










