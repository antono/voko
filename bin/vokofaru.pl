#!/usr/bin/perl

####################################################
# konvertas sgml-vortaron al HTML-formo kun indeksoj
#
# uzo:
#   cd /pado/al/mia/vortaro/
#   vokofaru.pl [/pado/al/vortaro.sgm] 
#
#   normale vortaro.sgml estu en la subdosierujo sgm
######################################################

# cxu $VOKO estas difinita?
$VOKO = $ENV{'VOKO'} or 
    die "Mediovariablo VOKO ne estas difinita.\n";

# analizu la argumentojn

while (@ARGV) {
    if ($ARGV[0] eq '-h') {
	help_screen();
	exit;
    } elsif ($ARGV[0] eq '-v') {
	$verbose = shift @ARGV;
    } elsif ($ARGV[0] eq '-a') {
	$xml_html = 1;
	shift @ARGV;
    } else {
	$vortaro = shift @ARGV; # momente ne plu uzata parametro
    }
};

unless($vortaro) { $vortaro = "sgm/vortaro.xml" };

# chu splitigi la HTML-tekston en unuopajn
# artikolojn?

# iru al xml, por ke la dtd estu en ../dtd/vokoxml
print "cd cvs\n" if ($verbose);
chdir(cvs);

# transformu la dosierojn al HTML
if ($xml_html) {
    print "xml2html_all.pl $verbose revo ../art\n" if ($verbose);
    `xml2html_all.pl $verbose revo ../art`;
}

# kreu indeksdosieron
print "xml2inx.pl $verbose revo > ../sgm/indekso.xml\n" if ($verbose);
`xml2inx.pl $verbose revo > ../sgm/indekso.xml`;

# cd ..
print "cd ..\n" if ($verbose);
chdir('..');

# kreu HTML-indeksojn
print "indeks.pl $verbose -dinx -r../art/ sgm/indekso.xml\n" if ($verbose);
open LOG, "indeks.pl $verbose -dinx -r../art/ sgm/indekso.xml|";
while (<LOG>) { print };
close LOG;

######## fino ###########

sub help_screen {
print <<EOM
vokofaru.pl (c) VOKO, 1997-1998 - libera softvaro
  
uzo:
   cd /pado/al/mia/vortaro/
   vokofaru.pl [-a] [-v] [-h]

   Tio faras el la artikoloj en la subdosierujo xml 
   la indeksojn en HTML-formo en la subdosierujo inx
   kaj indeksdosieron por la seræado sgm/indekso.xml.
   Kun la opcio -a ankaý la HTML-artikoloj en art.

   Por la konvertado estas necesa Perl kun la modulo XML::Parser 
   
   -a kreu la HTML-artikolojn
   -h montru tiun æi helpon
   -v skribu mesaøojn pri la progreso sur la ekranon

EOM
;
}








