#!/usr/bin/perl -w
#
# voku ekz.
#   belarangho.pl [-v] <xml-artikolo> 
#
################# komenco de la programo ################

$maxlen = 80; # maksimuma longeco de linio

while (@ARGV) {
    if ($ARGV[0] eq '-v') {
	$verbose = 1;
	shift @ARGV;
    } else {
	$dos = shift @ARGV;
    };
};

die "Ne ekzistas dosiero \"$dos\""
  unless -f $dos;


open DOS,$dos or die "Ne povis malfermi \"$dos\"\n";

#while ($line = <DOS>) {

#    $line =~ s/\s*<(\/)?(subart|drv|subdrv|snc|subsnc|dif|ekz)\b([^>]*)>\s*/
#	unless ($1) {
#	    "\n".(" " x (2*$level++))."<$2$3>\n"
#	} else {
#	    "\n".(" " x (2*--$level))."<\/$2>\n"
#	}
#    /eg;


#    print $line;
#}

$buffer = join('',<DOS>);

close DOS;

# chiujn strukturilojn metu en propran linion
# se antau kaj poste estas alia strukturilo au
# spaco

#$buffer =~ s/\s+</\n</sg;
#$buffer =~ s/></>\n</sg;
#$buffer =~ s/>\s+/>\n/sg;

# chiuj traktendajn strukturilojn metu sur propran
# linion

$traktendaj = 'art|subart|drv|subdrv|snc|subsnc|dif|ekz|refgrp|trdgrp';

$buffer =~ s¦\r¦¦sg;
$buffer =~ s¦\s*<($traktendaj)\b([^>]*)>\s*¦\r<$1$2>\r¦sg;
$buffer =~ s¦\s*</($traktendaj)>\s*¦\r</$1>\r¦sg;
# forigu troajn spacojn/linifinojn
#$buffer =~ s¦\s+\n+¦\n¦sg;
$buffer =~ s¦\r+¦\n¦sg;
# reenmetu linifinojn kelkloke
#$buffer =~ s¦<vortaro>¦\n$&¦s;


# forigu kelkajn historiajn aferojn
$buffer =~ s¦\bk\b¦kaj¦sg;
$buffer =~ s¦<snc\s+num="[0-9]+"¦<snc¦sg;


# enmetu deshovojn linikomence
$traktendaj = 'subart|drv|subdrv|snc|subsnc|dif|ekz|refgrp|trdgrp|bld';
@linioj = split("\n",$buffer);
$level=0;

foreach (@linioj) {
    s/^\s*//;
    s/\s*$//;

    if (m¦</($traktendaj)>$¦) {
	$level--;
    }

    $line = " " x (2*$level) . $_;

    if (m¦^<($traktendaj)\b¦) {
	$level++;
    }

    if (length($line) >= $maxlen) {
	$line = wrap($line);
    }

    print "$line\n";
}

#print join("\n",@linioj);

sub wrap {
    my $line = shift;

    $line =~ /^\s*/;
    my $level = length($&)/2;
    my $newline = " " x (2*$level);
    my $len = 2*$level;

    while ($line) {

	$line =~ s/^\s*([^\s]*)//;
	my $word = $1;
	
	unless ($word) { last; }

	if ($len + length($word) +1 < $maxlen) {
	    $newline .= "$word ";
	    $len += length($word)+1;
	} else {
	    $newline =~ s/\s*$//;
	    $newline .= "\n" . " " x (2*$level) . $word . " ";
	    $len = 2*$level + length($word) +1;
	}

    }

    $newline =~ s/\s+$//;

    return $newline;
}
















