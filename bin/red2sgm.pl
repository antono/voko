#!/usr/bin/perl
############################################
# kunigas al unu sgml-dosiero  multajn sgml-dosierojn
# 
############################################

# voku ekz. red2sgm.pl -a./pev/red ./pev/vortaro.sgm

# konstantoj

# l' argumentojn analizu

$VOKO=$ENV{'VOKO'};
$ARTIK="$VOKO/red";
$doctype = '<!DOCTYPE vortaro PUBLIC "-//VoKo//DTD vortaro//EO" >';

if ($ARGV[0]=~/^\-a/) {
    $ARTIK=shift @ARGV;
    $ARTIK =~ s /^\-a//;
}

if (@ARGV) {
    $vortaro=shift @ARGV;
} else {
    $vortaro="$ARTIK/vortaro.sgm";
};

open OUT,">$vortaro";
print OUT "$doctype\n\n";
print OUT "<vortaro>\n";

# legu la kadron de la vortaro
if (open IN,"$ARTIK/_vortaro.sgm") {
    print "_vortaro.sgm\n";
    $kadro = join('',<IN>);
    close IN;
};

# skribu iom al prologon en la vortaron
if ($kadro =~ m/(<prologo\s*>.*?<\/prologo\s*>)/si) {
    print OUT "$1\n";
} else {
    print OUT "<prologo><titolo>Vortaro</titolo></prologo>\n";
};
print OUT "\n<precipa-parto>\n";

#print "malfermas $ARTIK...\n";

opendir DIR, "$ARTIK";

while ($dos = readdir DIR) {

    if ((-f "$ARTIK/$dos") and ($dos !~ /_vortaro\.sgml?/)) {

	print "$dos\n";

	# malfermu la dosieron de la artikolo
	open IN,"$ARTIK/$dos" or die
	    "Ne povis malfermi $ARTIK/$dos";
	$teksto = join('',<IN>);
	
	# elprenu la artikolan strukturon (æion antaýan kaj postan ignoru)
	if ($teksto =~ /(<art[^>]*>.*<\/art\s*>)/si) {
	    #$art = $1;
	
	    # skribu øin en la vortaron
	    print OUT "$1\n\n";
	};

	# fermu
	close IN;
    };
};
closedir DIR;

print OUT "</precipa-parto>\n\n";

# skribu iom da epilogo en la vortaron
if ($kadro =~ m/(<epilogo\s*>.*?<\/epilogo\s*>)/si) {
    print OUT "$1\n";
} else {
    print OUT "<epilogo>generita per red2sgm.pl je ".`date`."</epilogo>\n";
};
print OUT "</vortaro>\n";












