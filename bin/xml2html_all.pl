#!/usr/bin/perl -w
#

$debug=0;
$tmp_file = '/tmp/'.$$.'voko.art';
$|=1;
$xsl = '/home/revo/voko/xsl/revohtml.xsl';
$xslt = '/home/revo/voko/bin/xslt.sh';

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

	    print "$infile -> $outfile..." if ($verbose);
	    `$xslt $infile $xsl > $tmp_file`;
	    if ($all) {
		# aktualigu nur, se shanghite
		diff_mv($tmp_file,$outfile);
	    } else {
		# aktualigu, pro neekzisto au diverseco de la dosierdatoj
		print "farite\n" if ($verbose);
		`mv $tmp_file $outfile`;
	    }
	} else {
	    warn "ignoru: $infile\n" if ($debug);
	}
    }
}
close DIR;
unlink($tmp_file);



  
# komparas novan dosieron kun ekzistanta,
# kaj nur che shanghoj au neekzisto alshovas
# la novan dosieron

sub diff_mv {
    my ($newfile,$oldfile) = @_;

    if ((! -e $oldfile) or (`diff -q $newfile $oldfile`)) {
	print "farite\n" if ($verbose);
	`mv $newfile $oldfile`;
    } else {
	print "(senshanghe)\n" if ($verbose);
	unlink($newfile);
    }
};




