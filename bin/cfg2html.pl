#!/usr/bin/perl

BEGIN {
  # en kiu dosierujo mi estas?
  $pado = $0;
  $pado =~ s|\\|/|g; 
  $pado =~ s/[a-z0-9_]+\.pl$//;

  push @INC, ($pado); #print join(':',@INC);
  require vokolib;
  "vokolib"->import();
}       

$file = shift @ARGV;

# legu la dosieron
%entries = read_cfg($file);

# analizu la stirinformojn
if ($entries{'_#!_'}) {
    foreach $entry (split(/\s*;\s*/,$entries{'_#!_'})) {
	$entry =~ s/^\s+//; $entry =~ s/\s+$//;
	($key,$value) = split (/\s*=\s*/,$entry);
	$stir{$key}=$value;
	delete $entries{'_#!_'}
    }
} 

# eligu HTML-dosieron de la bibliografio
index_header($stir{'titolo'});
index_buttons() if ($stir{'butonoj'} eq 'jes');
print "<h1>$stir{'titolo'}</h1>\n";

if ($stir{'listo'} eq 'dl') {
    print "<dl compact>\n";
    foreach $key (sort keys %entries) {
	print "<a name=\"$key\"></a>";
	print "<dt>$key</dt>\n";
	print "<dd>$entries{$key}</dd>\n";
    }
    print "</dl>\n";
} else {
    print "<pre>\n";
    foreach $key (sort keys %entries) {
	print " " x $stir{'x1'};
	print "$key" . " " x ($stir{'x2'} - length($key));
	print "$entries{$key}\n";
    }
    print "</pre>\n";
}

index_footer();
	
