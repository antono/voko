#!/usr/bin/perl
##################################################
# konvertas la plurajn dosieroj uzante jade      #
##################################################


$VOKO = $ENV{'VOKO'};
if ($ARGV[0]=~/^\-i/) {
    $index=shift @ARGV;
    $index=~s/^\-i//;

    open INDEX, ">$index" or die ">>Ne krebla: $index";
    
    print INDEX "<html><title>indekso de vortaraj dosieroj</title>\n";
    print INDEX "<body><font face=\"Times SudEuro\">\n";
    print INDEX "<h1>vortaro - indekso</h1>\n";
    print INDEX "<h2>sekcioj</h2>\n";
};

$dir = @ARGV[0];
$dsss_file = "$VOKO/vortaro/vokohtml.dsl";
$dsss_tmp = "$VOKO/vortaro/~tmp~.dsl";
$vortaro = "$dir/vortaro.sgml";

# esperantaj literoj lau Latin-3

%elit = ( 
    'C' => chr(198),
    'G' => chr(216),
    'H' => chr(166),
    'J' => chr(172),
    'S' => chr(222),
    'U' => chr(221)
	 );

#foreach $file (@ARGV) {
#  $file =~ /(.*)\.[^\.]*/;
#  $outfile = $1.'.html';
#  $latinx = $1.'.latinx.html';
#  $shortname = $outfile;
#  $shortname =~ s/.*\///;

#  print "jade: $file -> $outfile\n";
#  `jade -t sgml -d $VOKO/vortaro/vokohtml.dsl $file > $outfile`;

KOMPAKTA_HTML($vortaro);
#    SEKCIOJN($vortaro);
#    LATINA($vortaro);
# FAKO($vortaro,'BOT');

  if ($index) {
      $outfile =~ /(?:^|\/)([a-z]x?)\.html$/;
      $litero = uc($1);
      $litero =~s/([cghjsu])x/$elit{$1}/ei;
      print INDEX "<a href=\"$shortname\">$litero</a> ";
  }
#};

if ($index) {
    print INDEX "</font></body></html>\n";
    close INDEX;
};

# la tuta dosiero kiel unu html-dosiero

sub KOMPAKTA_HTML {
    my $infile=$_[0];
    my $outfile="$dir/vortaro.html";

    %shanghoj=('modo',"\"KOLORA\"",'sekcio','#f');
    MODIFY_DSSS($dsss_file,$dsss_tmp,%shanghoj);
    print "jade: $file -> $outfile\n";
    `jade -t sgml -E 1000 -d $dsss_tmp  $infile > $outfile`;
}

# fakindekso

sub FAKO {
    my ($infile,$fako) = @_;
    my %shanghoj = ('modo','"FAKINDEKSO"','fako',"\"$fako\"");
    
    MODIFY_DSSS($dsss_file,$dsss_tmp,%shanghoj);
    $fn = "$dir/".lc($fako).".html";
    `jade -t sgml -E 1000 -d $dsss_tmp $infile > $fn`;    
};

# latina indekso

sub LATINA {
    my $infile = $_[0];
    my %shanghoj = ('modo','"LINGVOINDEKSO"','lingvo','"latina"');
    
    MODIFY_DSSS($dsss_file,$dsss_tmp,%shanghoj);
    $fn = "$dir/latina.html";
    `jade -t sgml -E 1000 -d $dsss_tmp $infile > $fn`;    
};


# transformu la unuopaj sekcojn A...Z al HTML

sub SEKCIOJN {
    my $infile = $_[0];
    my %shanghoj;

    # a...z
    for ($lit='A';not $lit eq 'AA';$lit++) {

	if (not $lit =~ /[QXYW]/) {

	    print "$lit\n";

	    %shanghoj=('sekcio',"\"$lit\"");
	    MODIFY_DSSS($dsss_file,$dsss_tmp,%shanghoj);
	    $fn = "$dir/".lc($lit).'.html';
	    `jade -t sgml -E 1000 -d $dsss_tmp $infile > $fn`;

	    if ($lit =~ /[CHGJS]/) {

		print "$lit"."x\n";

		%shanghoj=('sekcio',"\"\&$lit"."circ;\"");
		MODIFY_DSSS($dsss_file,$dsss_tmp,%shanghoj);
	        $fn = "$dir/".lc($lit).'x.html';
	        `jade -t sgml -E 1000 -d $dsss_tmp $infile > $fn`;

	    } elsif ($lit eq 'U') {

		print "$lit"."x\n";
		
		%shanghoj = ('sekcio',"\"Ubreve;\"");
		MODIFY_DSSS($dsss_file,$dsss_tmp,%shanghoj);
		$fn = "$dir/".'ux.html';
		`jade -t sgml -E 1000 -d $dsss_tmp $infile > $fn`;
	    };
	};
    };
};

# modifas la difinojn en $from tiel, ke
# (define *key* x) en $to estas (define *key* value)

sub MODIFY_DSSS {
    my ($from,$to,%shanghoj) = @_;

    open FROM,"$from" or die "Ne povis malfermi $from\n";
    open TO,">$to" or die "Ne povis krei $to\n";

    my $dsss = join('',<FROM>);
    while (($key,$value) = each(%shanghoj)) { 
	$dsss =~ s/\(define\s+\*$key\*\s+[^\)]*\)/\(define *$key* $value\)/s;
    };
    
    print TO $dsss;
    close FROM; close TO;
    return '';
}



