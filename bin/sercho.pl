#!/usr/bin/perl

# serchas en indekso.sgml 
#
# kiel parametroj ghi prenas la indekso-dosieron, en kiu
# serchi, la serchesprimon kaj la strukturo, en kiu serchi
# la strukturo devas esti substrukturo de <drv>, do
# estas eble momente <kap>, <trd> kaj <ref>.
# La trovlokoj estas redonataj kiel
# marko de la artikolo || artikolkapvorto || marko de la derivajho ||
# derivajh-kapvorto || trovita vorto
#
# tiu chi programeto estas intencita por uzo en CGI-programo.

#$VOKO = $ENV{'VOKO'};
#$inxfn = "$VOKO/art/indekso.sgml";
#$esprim = 'voko';
#$strukt = 'kap';

$strukt = shift @ARGV;
$esprim = shift @ARGV;
$inxfn = shift @ARGV;

$/='</art';

# legu la unuopajn artikol-indekserojn el indekso

print "sercho.pl\n";

open INX,$inxfn or die "Ne povis malfermi $inxfn.\n";
while (<INX>) {
    my $amrk,$akap;
    # trovu la markon de la artikolo
    if (/<art\s+mrk\="([a-zA-Z0-9\.]*)"\s*>/si) { 
	$amrk = $1; 
	$amrk =~ s/\s+/ /sg;
    };
    # legu la kapvorton
    if (/<kap[^>]*>(.*?)<\/kap\s*>/si) { 
	$akap = $1; 
	$akap =~ s/\s+/ /sg;
	$akap =~ s/[0-9]/\//g;
	$akap =~ s/\*\s*//;
    };    
    # analizu la derivajhojn
    s/(<drv(.*?)<\/drv\s*>)/DRV($amrk,$akap,$1)/sieg;
};

sub DRV {
    my ($amrk,$akap,$tekst) = @_;
    my $mrk,$str,$kap;

    # legu la markon
    if ($tekst =~ /<drv\s+mrk\="([a-zA-Z0-9\.]*)"\s*>/si) { 
	$mrk = $1; 
	$mrk =~ s/\s+/ /sg;
    };

    # legu la kapvorton
    if ($tekst =~ /<kap[^>]*>(.*?)<\/kap\s*>/si) { 
	$kap = $1; 
	$kap =~ s/\s+/ /sg;
	#$kap =~ s/[0-9]/\//g;
	$kap =~ s/\*\s*//;
    };

#    print "$kap\n";

    # chu la serchata estas ene?

    while ($tekst =~ /<$strukt[^>]*>(.*?)<\/$strukt\s*>/ig) {
	$str = $1;
	if ($str =~ /$esprim/) {
	    $str =~ s/\s+/ /sg;
	    print "$amrk||$akap||$mrk||$kap||$str\n";
	};
    };
};




