#!/usr/bin/perl -w

# legas lingvoj.cfg, nls.cfg kaj vokosgn.dtd
# por lingvoj kun sekcio en nls.cfg,
# kreas pagxojn pri alfabeto kaj literunuoj

# voku ekz: 
# doklingv.pl -v

# farenda: rekonu simbolajn literunuojn en ENTITY-difinoj
# kiel che malnovgreka en vokosgn.dtd

##########################################################

BEGIN {
  # en kiu dosierujo mi estas?
  $pado = $0;
  $pado =~ s|\\|/|g; # sub Windows anstatauigu \ per /
  $pado =~ s/doklingv.pl$//;

  push @INC, ($pado); #print join(':',@INC);
  require nls;
  "nls"->import();
  $nls_cfg = $ENV{"VOKO"}."/cfg/nls.cfg";
  nls::read_nls_cfg("$nls_cfg");
}         

################### agordejo ##############################

$debug = 0;

$tmp_file = '/tmp/'.$$.'voko.dok';

# kien meti la lingvo-dokumentajn html-dosierojn,
# kaj de kie preni la simbolojn
$smb_ref = "../../smb"; # relative al la dok_dir
$smbtype = "png";
$dok_dir = "/dok/lng"; # pli malsupre antaumetighas vortaro_pado 
$stilo = "../../stl/artikolo.css"; #relative al dok_dir
$bgcol = "bgcolor=\"#EEEECC\""; # fonkoloro de tabeloj

%sufiksoj = (
	     "acute" => "dekstra korno",
	     "breve" => "ronda hoketo",
	     "caron" => "pinta hoketo",
	     "cedil" => "cedilo",
	     "circ" => "ĉapelo",
	     "comma" => "subkomo",
	     "dblac" => "longa tremao",
	     "dot" => "superpunkto",
	     "grave" => "maldekstra korno",
	     "macron" => "superstreko",
	     "nodot" => "sen punkto",
	     "ogonek" => "subhoko",
	     "ring" => "ringo",
	     "slash" => "trastreko",
	     "stroke" => "trastreko",
	     "tilde" => "tildo",
	     "uml" => "tremao");

%prefiksoj = ("c" => "cirila");

%liternomoj = (
	       "c_malmol" => "cirila minuskla malmolsigno",
	       "c_Malmol" => "cirila majuskla malmolsigno",
	       "c_mol" => "cirila minuskla molsigno",
	       "c_Mol" => "cirila majuskla molsigno"
	       
	       );

################## precipa programparto ###################

$|=1; # ne bufru eligon

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

$vortaro_pado=$config{"vortaro_pado"};
$lingvoj=$config{"lingvoj"};
$cfg_dir = "$vortaro_pado/cfg";
$dtd_dir = "$vortaro_pado/dtd";
$smb_dir = "$vortaro_pado/smb";
$out_dir = "$vortaro_pado/$dok_dir"; 

# legu la informojn
%lingvoj=read_cfg("$lingvoj");
%unuoj=read_entities("$dtd_dir/vokosgn.dtd");
read_nls_cfg("$nls_cfg");

# skribu dosieron kun lingvotabelo
@nls_lingvoj =();
my $lng='';
my $target_file = "$out_dir/lingvoj.html";
print "$target_file..." if ($verbose);
open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
select OUT;
lingv_header("Mallongigoj de lingvoj");
print
    "Se la mallongigo estas ligo, klaku sur ĝin por ekscii\n",
    "pri alfabeto kaj literunuoj de tiu lingvo.\n<P>\n",
    "<TABLE BORDER=\"0\">\n<TR>\n",
    " <TH ALIGN=\"LEFT\">Mallongigo</TH>\n",
    " <TH ALIGN=\"LEFT\">Flago</TH>\n",
    " <TH ALIGN=\"LEFT\">Lingvo</TH>\n</TR>\n";

foreach $lng (sort keys %lingvoj) {
    print "<TR>\n <TD ALIGN=\"RIGHT\">";
    if (defined_nls($lng)) {
	push @nls_lingvoj, ($lng);
        print "<A HREF=\"$lng.html\">";
    }
    print "$lng";
    if (defined_nls($lng)) {
        print "</a>";
    }
    print "</TD>\n";
    print " <TD ALIGN=\"LEFT\">";
    if (-f "$smb_dir/$lng.$smbtype") {
	print "<img src=\"$smb_ref/$lng.$smbtype\" width=\"24\" height=\"16\" alt=\"$lng\">";
    } elsif (-f "$smb_dir/$lng.png") {
	print "<img src=\"$smb_ref/$lng.$smbtype\" width=\"24\" height=\"16\" alt=\"$lng\">";
    }
    print "</TD>\n";
    print " <TD ALIGN=\"LEFT\">$lingvoj{$lng}</TD>\n</TR>\n";
}
print "</TABLE>\n";
lingv_footer();
close OUT;
select STDOUT;
diff_mv($tmp_file,$target_file);




foreach $lng (@nls_lingvoj) {
    
    %letters = defined_nls($lng);

    $target_file = "$out_dir/$lng.html";
    print "$target_file..." if ($verbose);
    
    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
    select OUT;
    
    lingv_header("Alfabeto kaj literunuoj de la $lingvoj{$lng}");
    print "<TABLE BORDER=\"0\">\n<TR>\n".
	" <TH ALIGN=\"LEFT\">Grupo</TH>\n".
  	    " <TH ALIGN=\"LEFT\">Litero</TH>\n".
		" <TH ALIGN=\"LEFT\">Priskribo</TH>\n".
		    " <TH ALIGN=\"LEFT\">XML-nomo</TH>\n".
			" <TH ALIGN=\"LEFT\">Unikodo</TH>\n</TR>\n";
    
    # kalkulu por chiu litergrupo, kiom da eroj ghi havas
    my %cnts;
    foreach $desc (values %letters) { $cnts{$desc->[0]}++ }

    my ($c,$rowcnt1) = (0,0);
    foreach $lit (sort {cmp_nls($a,$b,$lng)} (keys %letters)) {
	
	$desc = $letters{$lit};
	
	my $kodo = kodo($lit);
	
	my $unuo='';
	if (defined $unuoj{$kodo}) {
	    $unuo = "&amp;".$unuoj{$kodo}[0].";";
	}
	$unuo = "&amp;#x$kodo;" if ($kodo and !$unuo);
	
	my $nomo;
	if (first_utf8char($lit) ne $lit) { #supozu litergrupon
	    $nomo="litergrupo $lit";
	} elsif ($lit =~ /^[a-z]$/) {
	    $nomo="minuskla $lit";
	} elsif ($lit =~ /^[A-Z]$/){
	    $nomo="majuskla $lit";
	} else {
	    $nomo=priskribo($lit);
	}

	# kiom da linioj en unue kolumno?
	if ($c != $desc->[0]) {
	    $rowcnt = "ROWSPAN = \"$cnts{$desc->[0]}\"";
	    $c = $desc->[0];
	} else {
	    $rowcnt = '';
	}

	my $grupo = $desc->[2];
	unless ($desc->[2] eq $desc->[3]) {
	    $grupo .= " ($desc->[3])";
	}
	
	if ($rowcnt =~ /"1"$/) {
	    print "<TR $bgcol><TD $bgcol ALIGN=\"LEFT\">$grupo</TD>";
	} elsif ($rowcnt) {
	    print "<TR $bgcol><TD $bgcol $rowcnt ALIGN=\"LEFT\">$grupo</TD>";
	} else {
	    print "<TR $bgcol>";
	}

	print "<TD>$lit</TD><TD>$nomo</TD>".
	    "<TD>$unuo</TD><TD>$kodo</TD></TR>\n";

    }
    print "</TABLE>\n";
    
    lingv_footer();
    close OUT;
    select STDOUT;
    
    diff_mv($tmp_file,$target_file);
}


unlink($tmp_file);


############### funkcioj ###########

sub read_cfg {
    $cfgfile = shift;
    my %hash = ();

    open CFG, $cfgfile 
	|| die "Ne povis malfermi dosieron \"$cfgfile\": $!\n";

    while ($line = <CFG>) {
	if ($line !~ /^\#|^\s*$/) {
	    $line =~ /^([^=]+)=(.*)$/;
	    $hash{$1} = $2;
	}
    }
    close CFG;
    return %hash;
}

# legas vokosgn.dtd kaj elprenas la
# kodoj kaj liternomojn (unuojn)
sub read_entities {
    $dtdfile=shift;
    my %hash=();
    my $ento='';
    my $kodo='';
    my $nomo='';

    open DTD, $dtdfile
	|| die "Ne povis malfermi dosieron \"$dtdfile\": $!\n";

    while ($line = <DTD>) {
	if ($line =~ /^<!ENTITY\s+(\w+)\s+\"(\S+)\">(.*)$/ ) {
	    $ento=$1;
	    print "&$ento;" if $debug;
	    $kodo=$2;

	    # por unuopaj literoj e-a nomo povas aperi
	    # kiel komento
	    $nomo=$3;
	    if ($nomo =~ /^\s*<!--(.+)-->\s*$/ ){
		$nomo=$1;
                #anstatauxigu e-literojn
		$nomo=~s/&jcirc;/ĵ/g;
	    } else {
		$nomo='';
	    }

	    # unuopa deksesuma kodo
	    if ($kodo =~ /^&\#x([\da-f]+);$/i ) { 
		$kodo = $1;

	    # kombinita litero?
	    } elsif ($kodo =~ /^(\w|&\#x[\da-f]+;)(\w|&\#x[\da-f]+;)$/i ) {
	        @kodo=($1,$2);
		for $i (0..1) {
		    $kodo[$i] =~ s/^&\#x([\da-f]+);$/$1/i;
		}
		$kodo=join('',@kodo);
	    } else {
		print "Ne komprenis en DTD:\n$line";
		next;
	    }
	    $hash{$kodo}=[$ento,$nomo];  

	    #print ">>>$kodo:$ento\n" if ($debug);
	} #if ($line
    } # while
    close DTD;
    return %hash;
}

#liveras kodon de litero
sub kodo {
    my ($lit)=@_;
    my $kodo='';

    if ($lit =~ /^[\000-\200]$/) {
	$kodo='';
    } else {
	$kodo = utf8_hex($lit);
	$kodo =~ s/^0x//;
    }
    return lc($kodo);
}

#liveras priskriban nomon de litero
sub priskribo {
    my ($lit)=@_;
    my $pri='';

    my $kodo=kodo($lit);
    my $unuo=$unuoj{$kodo};

    if ($kodo and $unuo) {

	# eksplicita priskribo?
        $pri=$unuo->[1] || $liternomoj{$unuo->[0]}; 

        # nomo kunmetita el litero plus kromsigno?
        if (! $pri) {
	    
	    # lau model Ccirc?
	    my $l=substr($unuo->[0],0,1);
 	    my $kromsigno = substr($unuo->[0],1,length($unuo->[0])-1);
	    if (defined $sufiksoj{$kromsigno}) {
  	        $pri = ( ($l =~ /^[a-z]$/)?"min":"maj")
		    ."uskla $l $sufiksoj{$kromsigno}";
	    } else {

		# lau model c_ja
		($pref,$l) = split('_',$unuo->[0]);
		
		if (defined $prefiksoj{$pref}) {
		    $pri = $prefiksoj{$pref}.( ($l =~ /^[a-z]$/)?" min":" maj" )
			."uskla $l";
		}
	    }
	} 
    }

    $pri = 'ne konata' unless ($pri);

    return $pri;
}

# skribas la supran parton de html-ajho
sub lingv_header {
    my ($title) = @_;

    print 
	"<html>\n<head>\n<meta http-equiv=\"Content-Type\" ",
	"content=\"text/html; charset=UTF-8\">\n",
	"<link title=\"artikolo-stilo\" type=\"text/css\" ",
	"rel=\"stylesheet\"\n href=\"$stilo\">\n",
	"<title>$title</title>\n",
	"</head>\n<body>\n",
	"<h1>$title</h1>\n<P>\n";
}

# skribas la suban parton de html-ajho
sub lingv_footer {
    print "\n</body>\n</html>\n";
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





