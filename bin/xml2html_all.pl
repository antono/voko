#!/usr/bin/perl -w
#

$debug=0;

while ($ARGV[0] =~ /^-/) {
    if ($ARGV[0] eq '-v') {
	$verbose = shift @ARGV; # skribas la dosiernomon dum la konverto
    } elsif ($ARGV[0] eq '-a') {
	$all = shift @ARGV;     # æiujn, ne nur la pli novajn dosierojn traktu
    } else {
	die "nevalida argumento $ARGV[0]\n";
    }
}

$fromdir = shift @ARGV;
$todir = shift @ARGV;

opendir DIR,$fromdir;
for $file (readdir(DIR)) {

    $infile = "$fromdir/$file";

    if ((-f $infile) and ($infile =~ /\.xml$/)) {
   
	$outfile = "$todir/$file";
	$outfile =~  s/\.xml$/\.html/i;
	
	if (not (-e $outfile) 
	    or ((stat $outfile)[9] < (stat $infile)[9])
	    or $all) {

	    warn "$infile -> $outfile\n" if ($verbose);
	    `xml2html.pl $infile > $outfile`;
	} else {
	    warn "ignoru: $infile\n" if ($debug);
	}
    }
}

  

