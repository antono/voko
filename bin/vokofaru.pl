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
	$xml_html_cxiujn = shift @ARGV;
    } else {
	$agord_dosiero = shift @ARGV; 
    }
};

$|=1;

# legu la agordo-dosieron
unless ($agord_dosiero) { $agord_dosiero = "voko.cfg" };

open CFG, $agord_dosiero 
    || die "Ne povis malfermi agordodosieron \"$agord_dosiero\".\n";

while ($line = <CFG>) {
    if ($line !~ /^#|^\s*$/) {
	$line =~ /^([^=]+)=(.*)$/;
	$config{$1} = $2;
    }
}
close CFG;

$vortaro_pado=$config{"vortaro_pado"} || 
    die "vortaro_pado ne trovighis en la agordodosiero.\n";

# iru al dtd, por ke la dtd estu je ../dtd/vokoxml.dtd
print "cd $vortaro_pado/dtd\n" if ($verbose);
chdir("$vortaro_pado/dtd");

# transformu la dosierojn al HTML
$xml_pado="$vortaro_pado/xml";
$art_pado="$vortaro_pado/art";

print $command = "xml2html_all.pl $verbose $xml_html_cxiujn $xml_pado $art_pado", "\n" if ($verbose);
open LOG, "$command |" || die "Ne povis dukti\n";
while (<LOG>) { print };
close LOG;

# kreu indeksdosieron
$indekso = $config{"indeks_dosiero"} || "$vortaro_pado/sgm/indekso.xml";

print $command = "xml2inx.pl $verbose $xml_pado > $indekso", "\n" if ($verbose);
`$command`;

# cd ..
print "cd $vortaro_pado\n" if ($verbose);
chdir("$vortaro_pado");

# kreu HTML-indeksojn
print $command="indeks.pl $verbose $agord_dosiero", "\n" if ($verbose);
open LOG, "$command|";
while (<LOG>) { print };
close LOG;

# se pasis manpleno da tagoj, shovu la indeks-dosieron, por
# ke ghi atingu la TTT-servilon (sed ja ne tro ofte)
$tempdif = (stat "$indekso")[9] - (stat 'sgm/indekso.xml')[9];
if ($tempdif > 7*24*60*60)  {  # 7 tagoj
    print "pli ol 7 tagoj pasis: mv $indekso sgm/indekso.xml\n";
    `mv $indekso sgm/indekso.xml`;
}

######## fino ###########

sub help_screen {
print <<EOM
vokofaru.pl (c) VOKO, 1997-1998 - libera softvaro
  
uzo:
   cd /pado/al/mia/vortaro/
   vokofaru.pl ([-a] [-v] | [-h]) [<agord-dosiero>]

   Tio faras el la artikoloj en la subdosierujo xml 
   la indeksojn en HTML-formo en la subdosierujo inx
   kaj indeksdosieron por la seræado sgm/indekso.xml.
   Kun la opcio -a ankaý la HTML-artikoloj en art.

   Por la konvertado estas necesa Perl kun la modulo XML::Parser 
   
   -a kreu æiujn HTML-artikolojn, ne nur de þanøitaj artikoloj
   -h montru tiun æi helpon
   -v skribu mesaøojn pri la progreso sur la ekranon

EOM
;
}








