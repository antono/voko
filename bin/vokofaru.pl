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

$vortaro = shift @ARGV;
if ($vortaro =~ /^\-h/) {
    help_screen();
    exit;
};
unless($vortaro) { $vortaro = "sgm/vortaro.sgm" };

# chu splitigi la HTML-tekston en unuopajn
# artikolojn?
#
# Se vi volas æiujn artikolojn en unu dosiero þanøu tion en 
# ankaý en vokohtml.dsl
#
#$unu_dos = $ARGV[0] eq '-u';
#if ($unu_dos) { shift @ARGV };

if ($unu_dos) {
    # transformu la dosieron al HTML; eble tie æi skribu anst. > art/vortaro.htm ?
    print "jade -t sgml -c dsl/catalog -d dsl/vokohtml.dsl $vortaro > titolo.htm\n";
    `jade -E 1000 -t sgml -c dsl/catalog -d dsl/vokohtml.dsl $vortaro > titolo.htm`;

    # kreu HTML-indeksojn
    `indeks.pl -dinx -r../art/vortaro.html\# sgm/indekso.sgm`;

} else {
    # transformu la dosieron al HTML
    print "jade -t sgml -c dsl/catalog -d dsl/vokohtml.dsl $vortaro > titolo.htm\n";
    `jade -E 1000 -t sgml -c dsl/catalog -d dsl/vokohtml.dsl $vortaro > titolo.htm`;

    # kreu HTML-indeksojn
    print "indeks.pl -dinx -r../art/ sgm/indekso.sgm\n";
    open LOG, "indeks.pl -dinx -r../art/ sgm/indekso.sgm|";
    while (<LOG>) { print };
    close LOG;
}

sub help_screen {
print <<EOM
vokofaru.pl (c) VOKO, 1997-1998 - libera softvaro
  
uzo:
   cd /pado/al/mia/vortaro/
   vokofaru.pl [/pado/al/vortaro.sgm] 

   Tio konvertas la vortaron vortaro.sgm al
   unu aý pluraj HTML-artikoloj en art/ diversaj
   indeksoj en inx/ kaj centran titolpaøon titolo.htm
   Krome estiøas dosiero sgm/indekso.sgm kiu necesas
   por krei la indeksojn kaj por la seræado en la 
   vortaro.

   Se ne estas indikita la loko de vortaro.sgm øi preniøas
   el sgm/voratro.sgm, kie øi troviøu ankaý por la posta
   plenteksta seræado.

   Por la konvertado estas uzata la programo 'jade', kiu
   do estu øuste instalita.

EOM
;
}








