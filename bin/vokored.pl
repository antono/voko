#!/usr/bin/perl

# elektas artikolon el vortaro

# parametroj:
# mrk - la marko de la artikolo
# ago - legu, skribu, kreu, forigu (artikolon)
# art - la teksto de la artikolo

use CGI;

$cgi = new CGI;

$eblaj_parametroj = 'mrk|ago';
$eblaj_agoj = 'legu|skribu|kreu|forigu';

#foreach $pair (split ('&',$ENV{'QUERY_STRING'})) {
#	if ($pair =~ /(.*)=(.*)/) {
#		($key,$value) = ($1,$2);
#		if ($key =~ /^(?:$eblaj_parametroj)$/) {
#		    $value =~ s/\+/ /g; # anstatauigu '+' per ' '
#		    $value =~ s/%(..)/pack('c',hex($1))/eg;
#		    $params{$key} = $value;
#		};
#	}
#};

$VOKO = $ENV{'VOKO'};
$vortaro = "$VOKO/red";
$tmp = "/tmp";
$htmlvortaro = "http://localhost/voko/red";
$jade= "jade -t sgml -d $vortaro/dsl/vokohtml.dsl ";

$mrk = $cgi->param('mrk');
$ago = lc($cgi->param('ago'));

# kapo de la HTML-dosiero
print "Content-Type: text/html\n\n";
print "<html><head><title>artikolo: $mrk</title></head>\n";
print "<body><h1>artikolo: $mrk</h1>\n";

# chu ago estas valida?
if ($ago !~ /^$eblaj_agoj$/) {
    print "Eraro: nevalida ago: $ago\n";
    print "</body></html>\n";
    exit;
};

if ($ago eq 'kreu') {
    # nova artikolo - malplenan redaktilon sendu
    print "<form action=\"vokored.pl\">\n";
    print "<input type=text name=mrk value=xxxxxxxx size=8 maxlength=8><br>\n";
    print "<textarea name=art rows= 20 cols=60>\n";
    print "</textarea></form>\n";
} elsif ($ago eq 'forigu') {
    # forigu la dosieron kun la artikolo
    unlink "$vortaro/red/$mrk.sgm";
} elsif ($ago eq 'legu') {
    # legu artikolon

    if (not open IN,"$vortaro/red/$mrk.sgm") {
	print "Eraro: dosiero $vortaro/red$mrk.sgm\n";
	print "por artikolo $mrk ne trovita.\n";
	print "</body></html>";
	exit;
    };

    print "<form action=\"vokored.pl\">\n";
    print "<input type=hidden name=mrk value=$mrk>\n";
    print "<textarea name=art rows= 20 cols=60>\n";
    print HTMLigu(join('',<IN>));
    print "</textarea><p>\n";
    print "<input type=submit name=ago value=Skribu></form>\n";
    close IN;
} elsif ($ago eq 'skribu') {
    # chu mrk estas valida?
    if (not $mrk) {
	FINU("La marko de la artikolo ne estas indikita.\n");
    };
    # skribu la dosieron kun la nova artikolteksto
    $art = malHTMLigu($cgi->param('art'));

    # indiku, kie estas la DTD
    $art =~ s|<!DOCTYPE[^>]+>|<!DOCTYPE vortaro SYSTEM "$vortaro/dtd/vokosgml.dtd">|i;

    # transdonu la artikolon al "jade"
    open SGM, "|$jade > $tmp/$mrk.$$.htm 2> $tmp/$mrk.$$.jade"
	|| die "Ne povis malfermi dukton al jade.\n";
    print SGM $art;
    close SGM;

    # legu la "jade"-erarojn
    if (not open JADE, "$tmp/$mrk.$$.jade") {
	FINU("Jade ne redonis mesaøojn.\n");
    };
    @eraroj = <JADE>;
    close JADE;
#    unlink "$tmp/$mrk.$$.jade";

    if (@eraroj) {
	print "<h2>\"Jade\" redonis erarojn</h2>\n<pre>\n";
    };
    # analizu ilin iomete
    for $eraro (@eraroj) {
#	print $eraro;
	$eraro =~ /^jade:[^:]*:(\d+:\d+):(.*)$/;
	$che = $1;
	$msg = $2;
	print "æe $che - $msg\n";
	$err = $err or ($msg !~ /reference to non\-existent ID/);
    };
    print "</pre>\n";

    if (not $err) {
	if (@eraroj) {
	    print "Temas pri referenceraroj, kiuj rezultiøas el ";
	    print "la unuopa trakto de la artikoloj. Vi povas ";
	    print "ignori ilin.\n";
	};

	# provu skribi la artikolon al red/
	if (not open OUT,">$vortaro/red/$mrk.sgm") {
	    FINU("La dosiero $vortaro/red$mrk.sgm ne estas skribebla\n");
	};
	print OUT $art;
	close OUT;

	# skribu la HTML-tekston al art/
	`mv $tmp/$mrk.$$.htm $vortaro/art/$mrk.htm`;
	# faru ligon al øi
	print "La þanøoj estas sekurigitaj.<p>";
	print "<a href=\"$htmlvortaro/art/$mrk.htm\">Jen la nova artikolo</a>. ";
	print "Eble necesas premi la \"Remalfermo\"-butonon antaý kiam ";
	print "vi vidos la þanøojn.";
    } else {
	print "Bonvolu korekti la suprajn erarojn kaj reprovu. ";
	print "Reiru al la antaýa masko per la \"Reen\"-butono ";
	print "de via TTT-legilo.<p>";
	print "La þanøoj ne estas sekurigitaj pro la eraroj.";
    };
	    
	

};

print "</body></html>\n";

#--------fino------

sub HTMLigu {
    $art = $_[0];

    # anstatuigu E-literojn kaj tildojn
    $art =~ s/&([CcGgHhJjSs])circ;/^$1/sg;
    $art =~ s/&([Uu])breve;/^$1/sg;
    $art =~ s/<tld\s*>/~/sg;

    # anstatauigu specialajn HTML-signojn
    $art =~ s/&/&amp;/sg;
    $art =~ s/</&lt;/sg;
    $art =~ s/>/&gt;/sg;

    return $art;
};

sub malHTMLigu {
    $art = $_[0];

    # anstatuigu specialajn HTML-signojn
# tion faris jam TTTlegilo/CGI.pm
#    $art =~ s/</&lt;/sg;
#    $art =~ s/>/&gt;/sg;
#    $art =~ s/&amp;/&/sg;

    # anstatauigu E-literojn kaj tildojn 
    $art =~ s/\^([CcGgHhJjSs])/&$1circ;/sg;
    $art =~ s/\^([Uu])/&$1breve;/sg;
    $art =~ s/~/<tld>/sg;
 
    return $art;
};

sub FINU {
    print "Eraro: ".$_[0];
    print "</body></html>";
    exit;
};







