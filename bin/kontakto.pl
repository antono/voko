#!/usr/bin/perl
$inxfile="/home/wolfram/voko/art/vortaro.inx"; 

   #legu la indekson
    open INX,$inxfile or die "Ne trovis $inxfile\n";
    while ($vorto = <INX>) {
	chop($vorto);
	if ($vorto =~ /^[konta]*$/) {print "$vorto\n"};
    };

close INX;
