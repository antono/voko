#!/usr/bin/perl

# konvertas sgml-vortaron al HTML-formo kun indeksoj
# ktp.

# voku sgm2html.pl -s -dcel_dosierujo vortaro.sgml 


# cxu $VOKO estas difinita?
$VOKO = $ENV{'VOKO'} || die "Mediovariablo VOKO ne estas difinita.\n";

# analizu la argumentojn

# chu splitigi la HTML-tekston en unuopajn
# artikolojn?
$pluraj = $ARGV[0] eq '-s';
if ($pluraj) { shift @ARGV };

# kien meti la HTML-vortaron?
if ($ARGV[0] =~ /^\-d/) {
    $dosierujo = shift @ARGV;
    $dosierujo =~ s/^\-d//;
};

# la fontdosiero
$sgmldos = shift @ARGV;

# ek!

# unue kreu la dosierujstrukturon kaj
# enmetu diversajn dosierojn
print "kreu_dos.pl -f$VOKO $dosierujo\n";
`kreu_dos.pl -f$VOKO $dosierujo`;

if ($pluraj) { 

    # transformu la dosieron al HTML
    print "jade -t sgml -d $dosierujo/dsl/vokohtml.dsl $sgmldos > $dosierujo/sgm/vortaro.html\n";
    `jade -E 1000 -t sgml -d $dosierujo/dsl/vokohtml.dsl $sgmldos > $dosierujo/sgm/vortaro.html`;

    # kreu indekson
    print "jade -t sgml -d $dosierujo/dsl/vokoinx.dsl $sgmldos > $dosierujo/sgm/indekso.sgml\n";
    `jade -E 1000 -t sgml -d $dosierujo/dsl/vokoinx.dsl $sgmldos > $dosierujo/sgm/indekso.sgml`;

   # splitigu la artikolojn
    print "unu2mult.pl -a$dosierujo/art $dosierujo/sgm/vortaro.html\n"; 
    open LOG,"unu2mult.pl -a$dosierujo/art $dosierujo/sgm/vortaro.html|";
    while (<LOG>) { print };
    close LOG;
#    `rm $dosierujo/sgm/vortaro.html`;

    # kreu HTML-indeksojn
    print "indeks.pl -d$dosierujo/inx -r../art/ $dosierujo/sgm/indekso.sgml\n";
    open LOG, "indeks.pl -d$dosierujo/inx -r../art/ $dosierujo/sgm/indekso.sgml|";
    while (<LOG>) { print };
    close LOG;

} else {

    # transformu la dosieron al HTML
    `jade -t sgml -d $dosierujo/dsl/vokohtml.dsl $sgmldos > $dosierujo/art/vortaro.html`;

    # kreu indekson
    `jade -t sgml -d $dosierujo/dsl/vokoinx.dsl $sgmldos > $dosierujo/sgm/indekso.sgml`;

    # kreu HTML-indeksojn
    `indeks.pl -d$dosierujo/inx -r../art/vortaro.html\# $dosierujo/sgm/indekso.sgml`;

};


