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

%lingvoj=read_cfg("$lingvoj");
%regpri =read_cfg("$cfg_dir/regpri.cfg");
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

#print join(',',@nls_lingvoj) if $debug;
#dump_nls_info{"cs"} if $debug;

#foreach $lng (@nls_lingvoj) {

%entoj=read_entities("$dtd_dir/vokosgn.dtd");

my $cfg_file = "$nls_cfg";
open CFG, $cfg_file or die "Ne povis malfermi \"$cfg_file\": $!\n";
my $skribis = 0;
$tabelkapo = "<TABLE BORDER=\"0\">\n<TR>\n".
        " <TH ALIGN=\"LEFT\">Interna Kodo</TH>\n".
        " <TH ALIGN=\"LEFT\">Litero</TH>\n".
        " <TH ALIGN=\"LEFT\">Priskribo</TH>\n".
        " <TH ALIGN=\"LEFT\">Literunuo</TH>\n".
        " <TH ALIGN=\"LEFT\">Unikodo</TH>\n</TR>\n";
while ($line=<CFG>) {
    if ($line !~ /^\#|^\s*$/) { # ignoru komentojn kaj malplenajn liniojn
	if ($line =~ /^\[([a-z]{2,3})\]\s*$/) { # nova lingvo-sekcio
      	    $ekslng = $lng;
	    $lng = $1;
	    $min = 1;
	    if ($skribis) { # finigu la antauxan
		if (%{"alicp_$ekslng"}) { # tabeligu restintajn signojn
                    print "</TABLE>\n";
                    print $tabelkapo;
	            foreach $from (keys %{"alicp_$ekslng"}) {
			$litgrp=${"alicp_$ekslng"}{$from}[1];
                        $intkod = length($litgrp)>1 ? "=$litgrp" : "neniu";
			print "<TR>\n <TD ALIGN=\"LEFT\">($intkod)</TD>\n";
			$lit=${"alicp_$ekslng"}{$from}[0];
			print " <TD $bgcol ALIGN=\"LEFT\">$from</TD>\n";
			$nomo=priskribo($lit);
			print " <TD $bgcol ALIGN=\"LEFT\">$nomo</TD>\n";
			$kodo=kodo($lit);
		        $ento='';
		        if (defined $entoj{$kodo}) {
		           $ento = "&amp;".$entoj{$kodo}[0].";";
	 	        }
           		$ento = "&amp;#x$kodo;" if (!$ento and $kodo);
		      	print " <TD $bgcol ALIGN=\"LEFT\">$ento</TD>\n";
		       	print " <TD $bgcol ALIGN=\"LEFT\">$kodo</TD>\n";
			print " </TR>\n";
		    }
		}
                print "</TABLE>\n";
	 	lingv_footer();
		close OUT;
		select STDOUT;
		diff_mv($tmp_file,$target_file);
	    }
	    $target_file = "$out_dir/$lng.html";
	    print "$target_file..." if ($verbose);
            open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
            select OUT;
            lingv_header("Alfabeto kaj literunuoj de la $lingvoj{$lng}");
            print $tabelkapo;
	    $skribis=1;
	}
	    # chu MAJ?
	    elsif ($line =~ /^MAJ\s*$/) {
		$min = 2;
	    }
	    # chu anstatauigo de litergrupo
	    elsif ($line =~ /^\+([^=]+)=(.*)$/) {
		${"aliases_$lng"}{convert_non_ascii($1)}=convert_non_ascii($2);
		${"alicp_$lng"}{convert_non_ascii($1)}=[$1,convert_non_ascii($2)];
	    }
	    # estas liter-priskribo
            elsif ($line =~ /^([a-z]+):\s*(.*)\s*$/) {
		$ascii = $1;
		my $priskribo = $2;
		# chu temas pri intervalo? (aziaj lingvoj)
		if ($priskribo =~ /\[\s*(.*?)\s*,\s*(.*?)\s*\]/) {
		    # eltrovu la intervallimojn
		    my ($from,$to) = ($1,$2);
		    unless ($from =~ /\\u([a-f0-9]{4})/i) {
			die "Sintakseraro: interlimojn indiku per \uffff\n";
		    }
		    $kfrom = $1;
		    unless ($to =~ /\\u([a-f0-9]{4})/i) {
			die "Sintakseraro: interlimojn indiku per \uffff\n";
		    }
		    $kto = $1;
		    print "<TR>\n <TD $bgcol ALIGN=\"LEFT\">$ascii</TD>\n";
                    $lfrom=convert_non_ascii($from);
                    $lto=convert_non_ascii($to);
                    print " <TD $bgcol ALIGN=\"LEFT\">$lfrom - $lto</TD>\n";
		    print " <TD $bgcol ALIGN=\"LEFT\">ne konata</TD>\n";
	            print " <TD $bgcol ALIGN=\"LEFT\">&amp;#x$kfrom; - &amp;#x$kto;</TD>\n";
	            print " <TD $bgcol ALIGN=\"LEFT\">$kfrom - $kto</TD>\n";
		    print "</TR>\n";
		} else {
		    # temas pri unuopaj literoj
		    @literoj = split(',',$priskribo);
		    foreach $litgrp (@literoj) {
			$litgrp =~ s/^\s*//;
			$litgrp =~ s/\s*$//;
			@unuopaj=split /\s+/, $litgrp;
			$minusklo = convert_non_ascii($unuopaj[$min -1]);
			# renversu alinomigon
			while (($from,$to)=each %{"aliases_$lng"}) {
			    $minusklo = replace($minusklo,$to,$from);
			}
			$kiom=$#unuopaj+1;
			print "<TR>\n <TD $bgcol ALIGN=\"LEFT\" ROWSPAN=\"$kiom\">$ascii</TD>\n";
			if ($min==2 && $kiom>1) {
			    $tmp=$unuopaj[1]; $unuopaj[1]=$unuopaj[0]; $unuopaj[0]=$tmp;
			}
			$unua=1;
			while (@unuopaj) {
			    $lit = shift @unuopaj;
			    print " <TR>\n" unless $unua;
			    $l=convert_non_ascii($lit);
			    $ali=0;
			    while (($from,$to)=each %{"aliases_$lng"}) {
				if ($to) {
				    $nov = replace($l,$to,$from);
				    if ($nov ne $l) {
					$ali=1;
					#uzis tiun signon
					delete ${"alicp_$lng"}{$from};
				        $l=$nov;
				    }
			        }
			    }
			    print " <TD $bgcol ALIGN=\"LEFT\">$l</TD>\n";
			    if ($ali) { #supozu litergrupon
				$nomo="litergrupo $l";
			    } elsif ($lit =~ /^[a-z]$/) {
			        $nomo="minuskla $lit";
			    } elsif ($lit =~ /^[A-Z]$/){
				$nomo="majuskla $lit";
			    } else {
				$nomo=priskribo($lit);
			    }
			    print " <TD $bgcol ALIGN=\"LEFT\">$nomo</TD>\n";
			    if (!$ali && $lit !~ /^[a-zA-Z]$/) {
				$kodo=kodo($lit);
				$ento='';
				if (defined $entoj{$kodo}) {
                                    $ento = "&amp;".$entoj{$kodo}[0].";";
				}
				$ento = "&amp;#x$kodo;" if (!$ento and $kodo);
				print " <TD $bgcol ALIGN=\"LEFT\">$ento</TD>\n";
				print " <TD $bgcol ALIGN=\"LEFT\">$kodo</TD>\n";
			    }
			    print " </TR>\n";
			    $unua=0;
			} # while (@unuopaj)
		    } # foreach $litgrp (@literoj)
		} # temas pri unuopaj literoj
	    } # estas liter-priskribo
        } # ignoru komentojn ...
    } #  while ($line=<CFG>)
    print "</TABLE>\n";
    lingv_footer();
    close OUT;
    select STDOUT;
    diff_mv($tmp_file,$target_file);

#if ($debug) {
#    foreach $kodo (keys %entoj) {
#	$e=$entoj{$kodo}[0];
#	print "$kodo:&$e; ";
#    }
#print "\n";
#}

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

    if ($lit =~ /^[\200-\377]$/) {
	$kodo=sprintf("%04x",ord($lit));
    } elsif ($lit =~ /\\u([a-f0-9]{4})/) {
	$kodo=$1;
    } else {
	$kodo='';
    }
    return lc($kodo);
}

#liveras priskriban nomon de litero
sub priskribo {
    my ($lit)=@_;
    my $kodo='';
    my $pri='';

    $kodo=kodo($lit);
    if ($kodo and $entoj{$kodo}) {

	if ($debug) { warn ">>> $kodo ".join(', ',@{$entoj{$kodo}})."\n"; };

        $pri=$entoj{$kodo}[1]; #neregula priskribo
        # prenu regulan priskribon
        if (! $pri) {
	    my $l=substr($entoj{$kodo}[0],0,1);
 	    my $kromsigno = substr($entoj{$kodo}[0],1,length($entoj{$kodo}[0])-1);
	    if (defined $regpri{$kromsigno}) {
  	        $pri = ( ($l =~ /^[a-z]$/)?"min":"maj")."uskla $l $regpri{$kromsigno}";
	    } else {
	        $pri ='ne konata';
	    }
	}
    } else {
        $pri ='ne konata';
    }

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





