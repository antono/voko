#!/usr/bin/perl

# trovas oftajn erarojn en artikoloj, kiuj
# ne estas sintakseraroj lau la DTD

###########################


use XML::Parser;

while (@ARGV) {
    if ($ARGV[0] eq '-v') {
	$verbose = 1;
	shift @ARGV;
    } else {
	$dos = shift @ARGV;
    };
};

die "Ne ekzistas dosiero \"$dos\""
  unless -d $dos;

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
		    avertu("Dosiero ".$prt[0].".xml (lau $cel) ne trovighis");
		} elsif ($#prt > 0) {
		    my $buf = join('',<IN>);
		    my @mrk;
		    while ($buf =~ /mrk\s*=\s*\"(.*?)\"/g) {
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
}



sub end_handler {
    my ($xp, $el) = @_;



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
    warn "$file (".$xp->current_line.":".
	$xp->current_column.",$el):\n\t$msg\n";
}



















