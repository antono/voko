#!/usr/bin/perl

$file="/home/wolfram/voko/art/vortaro.sgml";

$/="</art";

open IN,$file or die "Couldn't open $file\n";

while (<IN>) {
	if ($_ =~ /<kap\s*>(.*?)<\/kap\s*>/si) {
		$x=$1;
		$x=~s/<[^>]*>//sig;
		$x=~s/\s+//sig;
		print "$x\n";
	};
};

close IN;

while (<IN>) {

print "last: $_";
};
