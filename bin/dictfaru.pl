#!/usr/bin/perl

# farenda:
#
#   indeksoj de nacilingvoj, chiuj derivajhoj - ne nur kapvortoj
#   por tiu havu liston de la dosiernomoj kaj ekstraktu la
#   referencinformojn per XSL au simile el indekso.xml
#
#   traktu chiujn dosierojn de -ujo ne nur elektitajn
#
#


$verbose = 1;

$xslbin = "/home/revo/xsl/xsl.jav";
$xsl = "/home/revo/xsl/revotxt.xsl";
$tmp = "/home/revo/tmp";
$datfile = "/home/revo/dict/revo.dat";
$inxfile = "/home/revo/dict/revo.inx";

$b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

#########

$pos = 0;
unlink "$datfile";

opendir DIR, shift @ARGV;

while ($file = readdir DIR) {

    if (-f $file and $file =~ /\.xml$/) {

	print "$file: " if ($verbose);
	
	`$xslbin $file $xsl > $tmp/$file.html`;
	`lynx -dump $tmp/$file.html >> $datfile`;
	$len = (-s "$datfile") - $pos;
	
	# elprenu la kapvorton
	open HTML, "$tmp/$file.html" 
	    or die "Ne povis malfermi $tmp/$file.html: $!\n";
	$html = join('',<HTML>);
	close HTML;
	$html =~ /<title>(.*?)<\/title>/si;
	$kapv = $1;
	$kapv =~ s/^\s+//s;
	$kapv =~ s/\s+$//s;
	$kapv =~ s/\s+/ /sg;
	$kapv =~ s/\///g;
	$kapv =~ s/&#(\d+);/int_utf8($1)/eg;

	unlink "$tmp/$file.html";
	
	print "[$kapv\t$pos\t$len]\n" if ($verbose);
	
	$inx{$kapv} = [$pos,$len];
	
   
	
	
	$pos += $len;
    }
}

closedir DIR;

# skribu indekson
open INX, ">$inxfile" or die "Ne povis malfermi $inxfile: $!\n";

foreach $kapv (sort keys %inx) {
    ($pos,$len) = @{$inx{$kapv}};
    print INX "$kapv\t".b64_encode($pos)."\t".b64_encode($len)."\n";
}
close INX;

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
