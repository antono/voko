#!/usr/bin/perl -w
#
# voku ekz.
#   xml2inx.pl [-v] xml > sgm/indekso.xml
#
################# komenco de la programo ################

use XML::Parser;

while (@ARGV) {
    if ($ARGV[0] eq '-v') {
	$verbose = 1;
	shift @ARGV;
    } else {
	$dos = shift @ARGV;
    };
};

die "Ne ekzistas dosierujo \"$dos\""
  unless -d $dos;

$radiko='';
$fako=0;
$lingvo='';

# indeks-komencon skribu
print '<?xml version="1.0" encoding="UTF-8"?>';
print "\n<vortaro>\n";


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

# indeks-finon skribu
print "\n</vortaro>\n";

#################### fino de la programo ####################


################## traktantoj de analiz-eventoj ################
 

sub char_handler {
    my ($xp, $text) = @_;

    if  (length($text) and 
	 (
	  $xp->in_element('kap') or
	  $xp->in_element('rad') or
	  $xp->in_element('trd') or
	  $xp->in_element('ind') or
	  ($xp->in_element('klr') and $ind) or
	  $xp->in_element('ref') or
	  ($xp->in_element('uzo') and $fako) or
          $xp->in_element('bld')
	  )
	 )
    {
	$text = $xp->xml_escape($text);
	print $text;
	$radiko .= $text if ($xp->in_element('rad'));
    }
} 

sub start_handler {
    my ($xp,$el,@attrs) = @_;
    my $attr;

    if (
	$el eq 'art' or
	$el eq 'kap' or
	$el eq 'drv' or
	$el eq 'ref' or
	$el eq 'ind' 
	)
    {
	$attr = attr_str(@attrs);
	print "<$el$attr>";
    }
    elsif ( $el eq 'tld' and 
	    ($xp->in_element('kap') or
	     $xp->in_element('ref') or
	     $xp->in_element('bld'))
	    ) 
    {
	#$attr = attr_str(@attrs);
	#print "<tld$attr/>";
	my $lit = get_attr('lit',@attrs);
	my $rad = $radiko;
	if ($lit) {
	    my $len = length($lit); # necesa, æar en UTF-8 supersignaj literoj
	                            # estas du-bitokaj
	    $rad =~ s/^.{$len}/$lit/;
	}           
	print $rad;
    }
    elsif ( $el eq 'uzo' and 
	    get_attr('tip',@attrs) eq 'fak')
    {
	$fako = 1;
	print "<uzo>";
    }
    elsif ( $el eq 'bld' )
    {
	print "<bld>";
    }
    elsif ( $el eq 'klr' and
	    get_attr('tip',@attrs) eq 'ind')
    {
	$ind = 1;
	print "<klr>";
    }
    elsif ( $el eq 'trdgrp' )
    {
	$lingvo = get_attr('lng',@attrs); # memoru lingvon
    }
    elsif ( $el eq 'trd' and not $xp->in_element('bld')) 
    {
	if ($xp->in_element('trdgrp')) {
	    $attr = " lng=\"$lingvo\""; # la lingvo venas de trdgrp 
	} else {
	    $attr = attr_str(@attrs);   # la lingvo estas en atributo
	}
	print "<$el$attr>";	
    };

    $radiko = '' if ($el eq 'rad');
}

sub end_handler {
    my ($xp, $el) = @_;

    if (
	$el eq 'art' or
	$el eq 'kap' or
	$el eq 'drv' or
	($el eq 'trd' and not $xp->in_element('bld')) or
	$el eq 'ref' or
	$el eq 'ind' or
        $el eq 'bld'
	)
    {
	print "</$el>\n";
    } 
    elsif ($el eq 'uzo' and $fako)   
    {
	print "</uzo>\n";
	$fako=0;
    }
    elsif ($el eq 'klr' and $ind)
    {
	print "</klr>\n";
	$ind=0;
    }
    elsif ($el eq 'trdgrp') 
    {
	$lingvo = '';
    }

}

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

sub get_attr {
    my($attr_name,@attr_list)=@_;

    while (@attr_list) {
        if (shift @attr_list eq $attr_name) { 
	    return shift @attr_list 
	    };
    };
    return ''; # atributo ne trovita;
};           





















