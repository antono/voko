#!/usr/bin/perl

# uzo:
#   dictfaru.pl <xml-dosierujo>
#

# farenda:
#
#   kreu lingvoindeksojn nur de certaj lingvoj
#   ASCII-konverto por lingvoj ru, bg, ktp.


$verbose = 1;
$nur_indeksoj = 0; # por pli facila testado

@lingvoj=('eo','de','en','cs','la','fr','es','tr');

$xslbin = "/home/revo/voko/bin/xslt.sh";
$xsl = "/home/revo/voko/xsl/revotxt.xsl";
$tmp = "/home/revo/tmp";
$datfile = "/home/revo/dict/revo.dat";
$inxpref = "/home/revo/dict/revo";
$indekso = "/home/revo/revo/sgm/indekso.xml";

$b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

######### 1a pasho: chiujn XML-artikolojn skribu en grandan tekstdosieron
#########           kaj skribu la pozicion kaj longon de la artikoloj en
#########           indeksdosieron

$pos = 0;

unless ($nur_indeksoj) {

    unlink "$datfile"; 

    $dir = shift @ARGV;
    opendir DIR, $dir;
    open INX,">$inxpref.inx" or die "Ne eblis malfermi \"$inxpref.inx\" por skribi\n";

    while ($file = readdir DIR) {
	
	if (-f "$dir/$file" and $file =~ /\.xml$/) {
	    
	    print "$file: " if ($verbose);

	    # konvertu XML->TXT kaj alpendigu al datumdosiero
	    `$xslbin $dir/$file $xsl > $tmp/$file.html`;
	    `lynx -dump $tmp/$file.html >> $datfile`;
	    $len = (-s "$datfile") - $pos;
	
	# elprenu la kapvorton
#	open HTML, "$tmp/$file.html" 
#	    or die "Ne povis malfermi $tmp/$file.html: $!\n";
#	$html = join('',<HTML>);
#	close HTML;
#	$html =~ /<title>(.*?)<\/title>/si;
#	$kapv = $1;
#	$kapv =~ s/^\s+//s;
#	$kapv =~ s/\s+$//s;
#	$kapv =~ s/\s+/ /sg;
#	$kapv =~ s/\///g;
#	$kapv =~ s/&#(\d+);/int_utf8($1)/eg;

	    unlink "$tmp/$file.html";
	
	    print "[$pos\t$len]\n" if ($verbose);
	    
	    $file =~ s/\.xml$//;
	    print INX $file,"\t",b64_encode($pos),"\t",b64_encode($len),"\n";
#	$inx{$kapv} = [$pos,$len];
	
	    $pos += $len;
	}
    }
    closedir DIR;

# skribu indekson
#open INX, ">$inxfile" or die "Ne povis malfermi $inxfile: $!\n";

#foreach $kapv (sort keys %inx) {
#    ($pos,$len) = @{$inx{$kapv}};
#    print INX "$kapv\t".b64_encode($pos)."\t".b64_encode($len)."\n";
#}

    close INX;
}


########### 2a pasho: analizu indekso.xml kaj ekstraktu chiujn
###########           informojn por la diverslingvaj indeksoj
###########           kaj fine skribu tiujn

# relegu la pozicio-indekson
open INX,"$inxpref.inx" or die "Ne eblis legi \"$inxpref.inx\"\n";
while (<INX>) {
    chomp;
    @entry=split("\t");
    $positions{$entry[0]}=[$entry[1],$entry[2]];
}
close INX;

# enlegu indekso.xml
$/ = '</art';    
open INX, "$indekso" or die "Ne eblis legi la dosieron \"$indekso\"\n";
print "Analizas $indekso...\n" if ($verbose);
while (<INX>) {
    artikolo($_);
}     
close INX;
$/ = "\n"; 

# skribu lingvoindeksojn
foreach $lng (@lingvoj) {
    my $last0, $last1;

    print "$lng...\n" if ($verbose);
    $refs = $tradukoj{$lng};

    open INX, ">$inxpref.$lng.inx";
    $refs = $tradukoj{$lng};
#    @$refs = sort { $a->[0] cmp $b->[0] } @$refs;
    for $entry (sort { compare($a->[0],$b->[0]) } @$refs) {
	if (($pos = $positions{$entry->[1]})
	    and (($last0 ne $entry->[0]) or ($last1 ne $entry->[1]))) { 
	    print INX $entry->[0], "\t", $pos->[0], "\t", $pos->[1], "\n";
	    $last0 = $entry->[0];
	    $last1 = $entry->[1];
	}
    }
    close INX;
}      


########### helpfunkcioj
###########
###########


sub b64_encode {
    my $val = shift;
    my $res = '';
    
    $res .= substr($b64, ($val & 0xc0000000) >> 30, 1);
    $res .= substr($b64, ($val & 0x3f000000) >> 24, 1);
    $res .= substr($b64, ($val & 0x00fc0000) >> 18, 1);
    $res .= substr($b64, ($val & 0x0003f000) >> 12, 1);
    $res .= substr($b64, ($val & 0x00000fc0) >>  6, 1);
    $res .= substr($b64, ($val & 0x0000003f), 1);
 
    # forigu komencajn nulojn
    $res =~s/^A+//;
    unless ($res) { $res = 'A' };

    return $res;
}       

 # transformas entjeran valoron de unikoda signo al UTF-8
# (tre simile al to_utf8, ne uzata momente)
sub hex_utf8 { 
    my $c = hex($_[0]);
    return $c < 0x80 ? chr($c) : 
        $c < 0x800 ? chr($c >>6&0x3F|0xC0) . chr($c & 0x3F | 0x80) :
            chr($c >>12&0x0F|0xE0).chr($c >>6&0x3F|0x80).chr($c &0x3F|0x80);
} 

sub int_utf8 { 
    my $c = $_[0];
    return $c < 0x80 ? chr($c) : 
        $c < 0x800 ? chr($c >>6&0x3F|0xC0) . chr($c & 0x3F | 0x80) :
            chr($c >>12&0x0F|0xE0).chr($c >>6&0x3F|0x80).chr($c &0x3F|0x80);
} 

# kompari konsiderante nur [A-Za-z0-9 ]
sub compare {
    $x = shift;
    $y = shift;
 
    $x =~ s/[^a-zA-Z0-9 ]//g;
    $y =~ s/[^a-zA-Z0-9 ]//g;
 
    $x = lc($x);
    $y = lc($y);
 
    return $x cmp $y;
}               

# analizas la indeks-tekston de artikolo
 
sub artikolo {
    my $tekst = shift;
    my ($mrk,$kap,$rad,$first_lit,$last_lit);
 
    # elprenu la markon
    $tekst =~ s/^.*?<art\s+mrk="([^\"]*)"\s*>//s;
    $mrk = $1;
    unless ($mrk) {
        # se tio ne estas la vosto de la dosiero, plendu
        if ($tekst =~ /<\/art$/) {
            warn "marko ne trovighis en $tekst\n";
        }
        return;
    }

    # trovu chiujn kapvortojn (inkl. de derivajhoj)
    $tekst =~ s/<kap\s*>(.*?)<\/kap\s*>/
	traduko($1,'eo',$mrk)/segx;

    # trovu chiujn tradukojn
    $tekst =~ s/<trd\s+lng="([^\"]*)"\s*>(.*?)<\/trd\s*>/
	traduko($2,$1,$mrk)/segx; 

    return '';
}

# notas unuopan tradukon

sub traduko {
    my ($trd,$lng,$mrk)=@_;
    my $ind;

    # forigu eblajn klr-ojn kaj aliajn ghenajn signojn
    $trd =~ s/<klr[^>]>.*?<\/klr>//sg;
    $trd =~ s/\///sg;

    # kio estas la indeksenda vorto?
    if ($trd =~ /<ind>(.*?)<\/ind>/s) {
        $ind = $1;
    } else {
        $ind = $trd;
    }
 
    # forigu komencajn/finajn spacojn
    $ind=~s/\s*$//s;
    $ind=~s/^\s*//s;
 
    # metu la vorton en la indekson
    push @{$tradukoj{$lng}}, [$ind,$mrk];
 
    return '';
};          















