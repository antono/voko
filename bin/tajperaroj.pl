#!/usr/bin/perl

# trovas oftajn erarojn en artikoloj, kiuj
# ne estas sintakseraroj lau la DTD


# aldonindaj testoj:
#
# - duoblaj tip en refgrp/ref
# - duoblaj lng en trdgrp/trd
# - neekzistanta fako en uzo tip=fak
# - ne jam subtenita/neekzistanta lingvo en trgrp/trd
# - neekzistanta stilo en uzo tip=stil

###########################


use XML::Parser;

while (@ARGV) {
    if ($ARGV[0] eq '-v') {
	$verbose = 1;
	shift @ARGV;
    } elsif ($ARGV[0] eq '-H') {
	$html = 1;
	shift @ARGV;
    } elsif ($ARGV[0] eq '-c') {
	shift @ARGV;
	$agord_dosiero = shift @ARGV;
    } else {
	$dos = shift @ARGV;
    };
};

die "Ne ekzistas dosierujo \"$dos\""
  unless -d $dos;

# legu la agordo-dosieron, fakojn kaj stilojn
unless ($agord_dosiero) { $agord_dosiero = "cfg/vortaro.cfg" };
%config = read_cfg($agord_dosiero);
%fakoj = read_cfg($config{"fakoj"});
%stiloj = read_cfg($config{"stiloj"});

# HTML-kapo
if (html) {
    print
	"<html>\n<head>\n<meta http-equiv=\"Content-Type\" ".
	"content=\"text/html; charset=UTF-8\">\n".
	"<title>eraro-raporto</title>\n".
	"<link title=\"indekso-stilo\" type=\"text/css\" ".
	"rel=stylesheet href=\"../stl/indeksoj.css\">\n".
	"</head>\n<body>";
    linkbuttons();
    print "<h1>Eraroraporto</h1>\n<dl>\n";
}

my $parser = new XML::Parser(ParseParamEnt => 1,
			     ErrorContext => 2,
			     Handlers => {
				 Start => \&start_handler,
				 End   => \&end_handler,
				 Char  => \&char_handler}
			     );
opendir DIR,$dos;
$letter = '';
for $file (sort readdir(DIR)) {
    if ((-f "$dos/$file") and ("$dos/$file" =~ /\.xml$/)) {
	# montru progreson...
	if ($verbose and (substr($file,0,1) ne $letter)) {
	    $letter = substr($file,0,1);
	    warn "$letter...\n";
	};
	#warn "$dos/$file\n" if ($verbose);
	eval { $parser->parsefile("$dos/$file") }; warn $@ if ($@);
    }
};
closedir DIR;

if (html) {
    print 
	"</dl>",
#<hr>\n<span class=dato>",
#	`date +\"%Y/%m/%d %H:%M %Z\"`,
#	"</span>";
	"\n</body>\n</html>\n";
}

#################### fino de la programo ####################


################## traktantoj de analiz-eventoj ################

$dosiernomo = ''; 

sub char_handler {
    my ($xp, $text) = @_;

    if ($xp->in_element('rad'))
    {
	$text = $xp->xml_escape($text);
	$radiko .= $text;
    } 
    if ($xp->in_element('uzo'))
    {
	$text = $xp->xml_escape($text);
	$uzo .= $text;
    } 
} 


sub start_handler {
    ($xp,$el,@attrs) = @_;
    my $attr;
    my $mrk;

    if ($el eq 'art') 
    {
	$mrk = get_attr('mrk',@attrs);

	# La Id informas pri la fakta dosiernomo
	if ($mrk =~ /^\044Id:\s+([^\.]+)\.xml/) {
	    $dosiernomo = $1;
	} else {
	    $dosiernomo = $mrk; # se CVS ne estas uzata
	}

	# mrk malplena?
	unless ($dosiernomo) {
	    avertu("Mankas atributo mrk");
	}
	# nevalida signo?
	if ($dosiernomo =~ /[^a-z0-9_]/i) {
	    avertu("Dosiernomo enhavu nur literojn, ciferojn "
		   ."kaj substrekon: \"$dosiernomo\"");
	}
    }
    elsif ($mrk = get_attr('mrk',@attrs))
    {
	my @prt = split(/\./,$mrk);
	unless ($#prt > 0) {
	    avertu("Atributo mrk havas nur $#prt partojn: \"$mrk\"");
	}
	unless ($prt[0] eq $dosiernomo) {
	    avertu("Unua parto de atributo mrk ne egalas ".
		   "al dosiernomo: \"$mrk\"");
	}
	unless ($prt[1] =~ /0/) {
	    avertu("Dua parto de atributo mrk ne enhavas \"0\": ".
		   "\"$mrk\"");
	}
    }
    elsif ($el eq 'ref') {
	$cel = get_attr('cel',@attrs);
    
	unless ($cel) {
	    avertu("Atributo cel mankas");
	} else {

	    my @prt = split(/\./,$cel);
	    unless ((not $prt[1]) or ($prt[1] =~ /0/)) {
		avertu("Dua parto de atributo mrk ne enhavas \"0\": ".
		       "\"$cel\"");
	    } else {
		unless (open IN,"$dos/".$prt[0].".xml" ) {
		    avertu("Dosiero ".$prt[0].".xml (laŭ $cel) ne troviĝis");
		} elsif ($#prt > 0) {
		    my $buf = join('',<IN>);
		    my @mrk;
		    while ($buf =~ /mrk\s*=\s*\"([a-z].*?)\"/g) {
			push @mrk, ($1);
		    }
		    unless (map { ($_ eq $cel)? 1 : (); } @mrk) {
			avertu("Marko $cel ne ekzistas en ".$prt[0].".xml:\n\t{".
			   join("\n\t",@mrk)."}");
		    }
		}
	    }
	}
    } 
    elsif ($el eq 'uzo') {
	$uzo_tip = get_attr('tip',@attrs);
	$uzo = '';
    }
}



sub end_handler {
    my ($xp, $el) = @_;

    if ($el eq 'uzo') {
	if ($uzo_tip eq 'fak') {
	    unless ($fakoj{$uzo}) {
		avertu("Fako \"$uzo\" ne ekzistas");
		}
	} elsif ($uzo_tip eq 'stl') {
	    unless ($stiloj{$uzo}) {
		avertu("Stilo \"$uzo\" ne ekzistas");
	    }
	}
    }
}

# faras signovicojn el atributolisto
sub attr_str {
    my $result='';

    while (@_) {
	my $attr_name = shift @_;
	my $attr_val  = shift @_;
	if (($attr_name eq 'mrk') and ($attr_val =~/^\$Id/)) {
	    $attr_val =~ s/^\044Id:\s+([^,\.]+)\.xml,v.*\044$/$1/;
	}
	$result .= " $attr_name=\"$attr_val\"";
    }

    return $result;
}

# prenas unuopan atributon el la atributolisto
sub get_attr {
    my($attr_name,@attr_list)=@_;

    while (@attr_list) {
        if (shift @attr_list eq $attr_name) { 
	    return shift @attr_list 
	    };
    };
    return ''; # atributo ne trovita;
};           


sub avertu {
    $msg = shift;
    my $fn = $file;
    $fn =~ s/\.xml$//;

    if (html) {
	$msg =~ s/\n/<br>/g;
	print 
	    "<dt><a href=\"../art/$fn.html\" target=\"precipa\">",
	    "<b>$fn</b></a>\n",
	    "<span class=dato>(".$xp->current_line.":",
	    $xp->current_column.",$el)</span>\n",
	    "<dd>$msg\n";
    } else {
	warn "$file (".$xp->current_line.":".
	    $xp->current_column.",$el):\n\t$msg\n";
    }
}

# skribas tabelon kun ligoj al precipaj indekspaghoj
sub linkbuttons {
    my $bgcolor = 'bgcolor="#AACCAA"';

    print 
	"<script src=\"../smb/butonoj.js\"></script>\n",

	 "<a href=\"_eo.html\" onMouseOver=\"highlight(0)\" ".
	 "onMouseOut=\"normalize(0)\">".
	 "<img src=\"../smb/nav_eo1.png\" alt=\"[Esperanto]\" border=0></a>\n",

	 "<a href=\"_lng.html\" onMouseOver=\"highlight(1)\" ".
	 "onMouseOut=\"normalize(1)\">".
	 "<img src=\"../smb/nav_lng1.png\" alt=\"[Lingvoj]\" border=0></a>\n",

	 "<a href=\"_fak.html\" onMouseOver=\"highlight(2)\" ".
	 "onMouseOut=\"normalize(2)\">".
	 "<img src=\"../smb/nav_fak1.png\" alt=\"[Fakoj]\" border=0></a>\n",

	 "<a href=\"_ktp.html\" onMouseOver=\"highlight(3)\" ".
	 "onMouseOut=\"normalize(3)\">".
	 "<img src=\"../smb/nav_ktp1.png\" alt=\"[ktp.]\" border=0></a>\n",

	"<br>";
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












