#!/usr/bin/perl -w
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
for $file (readdir(DIR)) {
    if (-f "$dos/$file") {
	warn "$dos/$file\n" if ($verbose);
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
	  $xp->in_element('ref') or
	  ($xp->in_element('uzo') and $fako)
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
	$el eq 'trd' or
	$el eq 'ref' 
	)
    {
	$attr = attr_str(@attrs);
	print "<$el$attr>";
    } 
    elsif ( $el eq 'tld' and 
	    ($xp->in_element('kap') or
	     $xp->in_element('ref'))
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
    };

    $radiko = '' if ($el eq 'rad');
}

sub end_handler {
    my ($xp, $el) = @_;

    if (
	$el eq 'art' or
	$el eq 'kap' or
	$el eq 'drv' or
	$el eq 'trd' or
	$el eq 'ref'
	)
    {
	print "</$el>\n";
    } 
    elsif ($el eq 'uzo' and $fako)   
    {
	print "</uzo>\n";
	$fako=0;
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









