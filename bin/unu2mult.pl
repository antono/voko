#!/usr/bin/perl
############################################
# disigas unu html-dosieron konstruitan per
# jade -d vokohtml.dsl al multaj html-dosieroj
# (por chiu artikolo unu)
############################################

# voku ekz. unu2mult.pl -a./pev/art ./tmp/vortaro.html

# konstantoj

$html = '.htm'; #dosierfinajho

$|=1;

# l' argumentojn analizu

$VOKO=$ENV{'VOKO'};
$ARTIK="$VOKO/art";

if ($ARGV[0]=~/^\-a/) {
    $ARTIK=shift @ARGV;
    $ARTIK =~ s /^\-a//;
}

if (@ARGV) {
    $vortaro=shift @ARGV;
} else {
    $vortaro="$ARTIK/vortaro.html";
};


$stilo="<link titel=\"artikolo-stilo\" type=\"text/css\" rel=stylesheet 
href=\"../stl/artikolo.css\">";

open IN,$vortaro;

# ignoru la dokumentkapon
$_=<IN>;
while (not /^><body/) { $_=<IN> };


#trovu la komencon de artikolo
$_ = <IN>;
while ($_) {
    if (/^><hr>/) {
	# traktu la artikolon
	ARTIKOLO();
    } else { $_ = <IN> };
};

sub ARTIKOLO {
    # la unua linio devus esti: name="..." au ><h1
    $_=<IN>;
    if (/<\/h1$/) {
	# temas pri sekcio-titolo, simple ignoru ghin
	while (not /^><hr>/) { $_=<IN> };
	$_=<IN>;
    };
    # nun devus esti name="...", tiuj ... estu la dosiernomo
    #$_=<IN>;
    /name="(.*?)"/;
    if (not $1) { warn "Atendis: name=\"...\", sed trovis: $_\n" }
    else {

	# kreu kaj komencu dosieron
	my $fn="$ARTIK/".lc($1).$html;
	print STDOUT "$fn\n";
	open OUT,">$fn" or die "Ne povis krei $1$html\n";
	select OUT;
	print "<html><head><title>artikolo: $1</title>$stilo</head>\n";
	print "<body>\n"; # tie chi aldonu <font facename=....>
	#if ($tiparnomo) {
	#    print "<font face=\"$tiparnomo\">\n";
	#};
	
	# la sekva linio devus esti ></a
	$_ = <IN>;
	# la sekva linio devus esti >..., la unuan signon ignoru
	$_ = <IN>;

	$_ = substr($_,1);

	#legu nun la liniojn unu post alia, ghis ><hr
	while ($_ and not /^><hr/) {
	    LINIO($_);
	    $_ = <IN>;
	};

	#if ($tiparnomo) { print "</font>\n"; };
	print "</body></html>\n";
	
	close OUT;
    };
}

sub LINIO {
    my $linio=$_[0];

    # anstatauigu eblajn referencojn
    $linio =~ s/name="([^\.]*)\.(.*?)"/"name=\"$2\""/ige;
    
    # anstatauigu eblajn referencojn
    $linio =~ s/href="#([^\.]*)\.(.*?)"/"href=\"".lc($1)."$html#$2\""/ige;
    $linio =~ s/href="#(.*?)"/"href=\"".lc($1)."$html\""/ige;

    # skribu la linion
    print $linio;

}








