#!/usr/bin/perl
# kreas la dosierujostrukturon necesan
# por HTML-a vortaro

# uzo: perl kreu_dos.pl -fvokodosierujo celdosierujo
#
# fontdosierujo enhavu dtd-ojn, dsl-ojn, sgml-tekston k.s.

# sistemdependaj komandoj:

$SYSTEM = 'unix';

if ($SYSTEM eq 'unix') {
    $mkdir = 'mkdir';
    $copy  = 'cp';
} elsif ($SYSTEM eq 'windows') {
    $mkdir = 'md';
    $copy = 'copy';
};

# analizu la agumentojn...

if ($ARGV[0] =~ /^\-f/) {
    $vokodos = shift @ARGV;
    $vokodos =~ s/^\-f//;
} else {
    $vokodos = '.';
};

$celdos = shift @ARGV;

# kreu la dosierujojn art,inx,bin,dok,dsl,dtd,inx,rtf,sgm,smb,stl,xml
for $dos ('art','inx','bin','dok','dsl','dtd',
	 'inx','rtf','sgm','smb','stl','xml') {

    if (not -e "$celdos/$dos") {
	`$mkdir $celdos/$dos`;
    };
};

# kopiu la necesajn dosierojn
`$copy $vokodos/dsl/*.* $celdos/dsl/`;
`$copy $vokodos/dsl/catalog $celdos/dsl/`;
`$copy $vokodos/dtd/*.dtd $celdos/dtd/`;
`$copy $vokodos/smb/*.* $celdos/smb/`;
`$copy $vokodos/stl/*.css $celdos/stl/`;
`$copy $vokodos/sgm/catalog $celdos/sgm/`;
`$copy $vokodos/div/*.* $celdos/`;
`$copy $vokodos/dok/*.htm $celdos/dok/`;
`$copy $vokodos/dok/*.txt $celdos/dok/`;
`$copy $vokodos/bin/sercho.pm $celdos/bin/`;
`$copy $vokodos/bin/serchcgi.pl $celdos/bin/`;
`$copy $vokodos/bin/vokosrv.pl $celdos/bin/`;

# En sercxo.htm difinu value=<vortaro>
$celdos =~ /([^\/]*)$/;
$vortaro = $1;
open IN,"$vokodos/div/sercxo.htm";
$in = join('',<IN>);
close IN;
$in =~ s/(<input[^>]*name=\"?vortaro\"?\s+value=)[a-z]*/$1$vortaro/s;
open OUT,">$celdos/sercxo.htm";
print OUT $in;
close OUT;

