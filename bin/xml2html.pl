#!/usr/bin/perl
############################################################
# Konvertas la dokumenton grimpado.xml al HTML-versio kun
# indeksoj
############################################################

# shargu la helpfunkciojn

push (@INC,'pwd');
use  xmlpack;

# la konvertenda dokumento kaj la celpado

$dokumento = '../vortaro/grimpad.xml';
$celpado = '../html/';
$celdosiero = 'grimpado.html';

# indikoj por la HTML-dokumento

$titolo = "Terminareto pri Grimpado kaj Montmigrado";
$kopirajto = '<address>Wolfram Diestel '
	.'&lt;diestel@rzaix340.rz.uni-leipzig.de&gt;</address>';
$stiloj1 = "<style type=\"text/css\">"
	."H1 {color:#008080;font-family:sans-serif}"
	."H2 {color:#007000;text-indent:-5;font-family:sans-serif}</style>\n";
$stiloj2 = "<style type=\"text/css\">"
	."H1 {color:#008080;font-family:sans-serif}"
	."H2 {color:#007000;font-family:sans-serif}</style>\n";

# parametroj por la konverto-objekto

%parametroj = (
   'dosiernomo' => $dokumento,
   'simbolpado' => '../simboloj/',
   'bildopado'  => '../bildoj/');

################### komenco de la programeto #####################

# malfermu la celdokumenton

open (VORTARO,">$celpado$celdosiero"); select VORTARO;
print "<html><head><title>$titolo</title>$stiloj1</head>\n";
print "<body><h1>$titolo</h1>\n\n";

# malfermu la XML-vortaron

$artikolaro = nova xmlpack(%parametroj);
$artikolaro -> malfermu;

# prilaboru ghin

while ($artikolaro -> legu_artikolon) {
  print ($artikolaro -> transformu_artikolon_al_HTML);
  print "<hr>\n\n";
  %kapvortoj  = (%kapvortoj,$artikolaro->kion_indeksi('<kapvorto[^>]*>(.*?)</kapvorto>'));
  %esperanta = (%esperanta,$artikolaro -> kion_indeksi('<kapo[^>]*>(.*?)</kapo>'));
  %angla     = (%angla,$artikolaro -> kion_indeksi('<traduko[^>]*lingvo=.angla.[^>]*>(.*?)</traduko>'));
  %franca    = (%franca,$artikolaro -> kion_indeksi('<traduko[^>]*lingvo=.franca.[^>]*>(.*?)</traduko>'));
  %germana   = (%germana,$artikolaro -> kion_indeksi('<traduko[^>]*lingvo=.germana.[^>]*>(.*?)</traduko>'));
  %hispana   = (%hispana,$artikolaro -> kion_indeksi('<traduko[^>]*lingvo=.hispana.[^>]*>(.*?)</traduko>'));
}

# fermu la vortaron

print "$kopirajto</body></html>";
select STDIN; close VORTARO;

# kreu la indeksojn

kreu_indekson('kapvortoj.html','Indekso de la Kapvortoj',%kapvortoj);
kreu_indekson('esperanta.html','Esperanta Indekso',%esperanta);
kreu_indekson('angla.html','Angla Indekso',%angla);
kreu_indekson('franca.html','Franca Indekso',%franca);
kreu_indekson('germana.html','Germana Indekso',%germana);
kreu_indekson('hispana.html','Hispana Indekso',%hispana);

sub kreu_indekson {
  my ($dosiero,$indekso,%vortoj) = @_;

  open (INDEKSO,">$celpado$dosiero"); select INDEKSO;
  print "<html></head><title>$titolo - $indekso</title>$stiloj2</head>\n";
  print "<body><h1>$titolo</h1><h2>$indekso</h2>\n\n";

  # skribu chiujn vortojn ordigite

  foreach $vorto (sort(keys %vortoj)) {
    $marko = $vortoj{$vorto};

    print "<a href=\"$celdosiero#$marko\">";
    print "$vorto</a><br>\n";
  };

  print "<hr>$kopirajto</body></html>\n";
  select STDOUT; close INDEKSO;
}
