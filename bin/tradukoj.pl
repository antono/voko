#!/usr/bin/perl -w

# esploras la kvanton de tradukoj kaj
# listigas la netradukitajn sencojn
#
# momente tio okazas ankorau en xml2inx.pl
# sed tie chi aldonighis ignorado de EVI/ARK-sencoj
# kaj memorado de tradukiteco de sencoj por povi
# krei listojn de mankantaj tradukoj
#############################################

use XML::Parser;
use lib "$ENV{'VOKO'}/bin";
use vokolib;

use bytes;
use integer;

$debug = 0;

while (@ARGV) {
    if ($ARGV[0] eq '-v') {
	$verbose = 1;
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

# legu la agordo-dosieron
unless ($agord_dosiero) { $agord_dosiero = "cfg/vortaro.cfg" };
#%config = read_cfg($agord_dosiero);

$lngcnt=0;
$uzo = '';
$ignoru_snc = 0;
$ignoru_drv = 0;

my $parser = new XML::Parser(ParseParamEnt => 1,
			     ErrorContext => 2,
                             NoLWP => 1,
			     Handlers => {
				 Start => \&start_handler,
				 End   => \&end_handler,
				 Char => \&char_handler}
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

	if ($debug) {

	    if ((scalar(keys %sencoj) - $oldsnccnt) < 
		($lingvoj{'de'}->[0] - $olddecnt)) {
		
		print "ERARO en 'de'-kalkulo en dosiero $file\n";
	    }

	    $oldsnccnt = scalar(keys %sencoj);
	    $olddecnt = $lingvoj{'de'}->[0];

	}
    }
};
closedir DIR;

# lingvoj enhavas nun por chiu lingvo la nombron
# de tradukitaj lingvoj kaj la numeron (biton) de la lingvo

# sencoj enhavas por chiu lingvo bitaron el kiu oni
# vidas, kiuj sencoj estas tradukitaj


# debugging
print "sumo=".scalar(keys %sencoj)."\n";
#print "lingvoj: ".join(',',keys %lingvoj)."\n";
foreach $l (sort keys %lingvoj) {
    print "$l=".$lingvoj{$l}->[0]."\n";
}

# if ($debug) {
#foreach $k (sort keys %sencoj) {
#    print "$k: ".join(',',@{$sencoj{$k}})."\n";
#}
#}

$mankantaj_tradukoj = 500; # se mankas nur tiom da tradukoj
                           # ili listighas por pli facila aldono
$maks_mankantaj = 3; # nur tiom da mankantaj aperu en la listo
                      # por ne tro longigu ghin

#exit if ($debug);

# kiuj lingvoj havas nur tiom da mankoj au malpli
my @mankantaj;
foreach $lng (keys %lingvoj) {
    my $d = scalar(keys %sencoj) - $lingvoj{$lng}->[0]; 
    if (($d <= $mankantaj_tradukoj) and ($d > 0)) {
#	add(\@mankantaj,$l);
	print "[$lng]\n";

	my $cnt=0;
	my $field = $lingvoj{$lng}->[1]/32;
	my $power = $lingvoj{$lng}->[1]%32;

#	print $field, " ", $power, "\n";

	while (($mrk,$trdj) = each %sencoj) {
	    unless ($trdj->[$field] and 
		    ($trdj->[$field] & (1 << $power))) {
		print ++$cnt,": $mrk\n";
		last if ($cnt>=$maks_mankantaj);
	    }
	}
    }
}



#################### fino de la programo ####################


################## traktantoj de analiz-eventoj ################

sub start_handler {
    my ($xp,$el,@attrs) = @_;
    my $attr;
    my $mrk;

    if ($el eq 'drv') {
	if (not $ignoru_drv) {
	    $drvmrk = get_attr('mrk',@attrs);
	    warn "Mankas mrk en drv ($file)\n" unless ($drvmrk); 
	    @drvsnc = ();
	    $snccnt = 0;
	}
    }
    elsif ($el eq 'snc') {
	if (not $ignoru_snc and not $ignoru_drv) {
	    $snccnt++; $sncsum++;
	    $sncmrk = get_attr('mrk',@attrs) || "$drvmrk.$snccnt";
	    push @drvsnc, ($sncmrk);
	    $sencoj{$sncmrk} = [];
	} else {
	    # tamen altigi snccnt tie chi, por ke la 
	    # sencoj estu adreseblaj
	    $snccnt++;
	}
    }
    elsif (($el eq 'trd' or $el eq 'trdgrp') 
	   and $lng = get_attr('lng',@attrs)) {
	       
	       if (not ($ignoru_snc or $ignoru_drv)) {

		   #$lingvoj{$lng}=1;
		   if ($xp->in_element('snc') or $xp->in_element('dif')) {
		       add($sencoj{$sncmrk}, $lng);
		   } elsif ($xp->in_element('drv')) {
		       foreach $s (@drvsnc) {
			   add($sencoj{$s}, $lng);
		       }
		   }
	       } else {
		   print "ignoras tradukon ".get_attr('lng',@attrs)."\n" if ($debug); 
	       }
	   }
}

sub end_handler {
    my ($xp,$el) = @_;

    if ($el eq 'uzo') {
	if ($uzo eq 'EVI' or $uzo eq 'ARK') {
	    if ($xp->in_element('snc')) {
		$ignoru_snc=1;
		print "ignoru sencon...\n" if ($debug);
	    } elsif ($xp->in_element('drv')) {
		$ignoru_drv=1;
		print "ignoru derivajhon...\n" if ($debug);
	    }
	}
	$uzo = '';
    } elsif ($el eq 'snc') {
	print "ignoris sencon\n" if ($ignoru_snc and $debug);
	$ignoru_snc=0;
    } elsif ($el eq 'drv') {
	print "ignoris derivajhon\n" if ($ignoru_drv and $debug);
	$ignoru_drv=0;
    }
}

sub char_handler {
    my ($xp, $text) = @_;

    # transprenu la tekston ene de uzo
    if  (length($text) and 
         (
          $xp->in_element('uzo')
         ))
    {
        $text = $xp->xml_escape($text);
        $uzo .= $text;
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

sub add {
    my ($list,$lng)=@_;

    # por chiu lingvo ekzistas du indikoj: [senconombro,lingvonumero]
    # la lingvonumero adresas biton en entjeraro, kiu rapidigas
    # la operaciojn de komparo kaj diferenco poste
    unless ($lingvoj{$lng}) {
	$lingvoj{$lng} = [0,$lngcnt];
	$lngcnt++;
    }

    # kalkulu la adreson el entjero kaj bito el la lingvonumero
    my $field = $lingvoj{$lng}->[1]/32;
    my $power = $lingvoj{$lng}->[1]%32;
    $list->[$field] = 0 unless ($list->[$field]);

    # se la lingvobito ne jam estas metita, metu ghin kaj altigu
    # la senconombron je unu (tio evitas, ke senco estas
    # plurfoje kalkulata, se aperas pluraj tradukoj, ekz en snc kaj drv)
    unless ($list->[$field] & (1 << $power)) {
	$list->[$field] = $list->[$field] | (1 << $power);
	($lingvoj{$lng}->[0])++;
    }
}











