#!/usr/bin/perl

# CGI-programeto por redaktado de vortara artikolo
# la artikoloj troviøas en CVS-deponejo

# parametroj:
# mrk - la marko de la artikolo (~ dosiernomo)
# ago - legu, skribu, kreu, forigu (artikolon)
# art - la teksto de la artikolo

# konfigura¼o
$CVSsituo = "/home/wolfram/cvsroot/vortaroj/pevet";
$tmp = "/tmp";
$VOKO = "/home/wolfram/work/voko";
$DTD = "$VOKO/dtd/vokosgml.dtd";
$DSL = "$VOKO/dsl/vokoart.dsl";
$jade = "/usr/bin/jade -t sgml -d $DSL ";
$checkout = "/usr/bin/co -q -p ";

# komenco de la programo

use CGI;
$cgi = new CGI;

#$htmlvortaro = "http://localhost/voko/red";

$mrk = $cgi->param('mrk');
$ago = lc($cgi->param('ago'));


# kapo de la HTML-dosiero
print "Content-Type: text/html\n\n";
print "<html><head><title>artikolo: $mrk</title></head>\n";
print "<body>\n";

if ($ago eq 'kreu') {

    # æu $mrk estas valida?
    if (not $mrk) {
	FINU("La marko de la artikolo ne estas indikita.\n");
    };

    form("<!doctype vortaro system>\n\n<vortaro>\n<art mrk=\"$mrk\">\n".
	 "<kap>$mrk</kap>\n...\n</art>\n</vortaro>\n");

} elsif ($ago eq 'forigu') {

    # æu $mrk estas valida?
    if (not $mrk) {
	FINU("La marko de la artikolo ne estas indikita.\n");
    };

    # forigu la dosieron kun la artikolo
    #unlink "$vortaro/red/$mrk.sgm";

} elsif ($ago eq 'listigu') {

    # æu $mrk estas valida?
    if (not $mrk) {
	FINU("Vi ne donis komencliterojn.\n");
    };    

    # listigu æiujn artikolojn, kies nomo komenciøas je $mrk
    listigu();

} elsif ($ago eq 'redaktu') {

    # æu $mrk estas valida?
    if (not $mrk) {
	FINU("La marko de la artikolo ne estas indikita.\n");
    };

    # ricevu la SGML-tekston de la artikolo
    $art = malHTMLigu($cgi->param('art'));
    unless ($art) {
	$komencu = 1;
	$art = checkout();
    };

    local @jade_eraroj;
    $html = jade($art);

    if (@jade_eraroj) {
	print "<h2>\"Jade\" redonis erarojn</h2>\n<pre>\n";

	# analizu ilin iomete
	local $err = 0;
	for $eraro (@jade_eraroj) {
#	    print $eraro;
	$eraro =~ /^[^:]*jade:[^:]*:(\d+:\d+):(.*)$/;
	$che = $1;
	$msg = $2;
	print "æe $che - $msg\n";
	$err = $err or ($msg !~ /reference to non\-existent ID/);
	};
	print "</pre>\n";
    };

    if (not $err) {
	if (@jade_eraroj) {
	    print "Temas pri referenceraroj, kiuj rezultiøas el ";
	    print "la unuopa trakto de la artikoloj. Vi povas ";
	    print "ignori ilin.\n";
	};

	unless ($komencu) {
	    # skribu la HTML-tekston al art/
	    checkin($art);

	    print "La þanøoj estas sekurigitaj.<p>";
	};

    } else {
	print "Bonvolu korekti la suprajn erarojn kaj reprovu. ";
	print "La þanøoj ne estas sekurigitaj pro la eraroj.";
    };

    # Montru la tekston de la artikolo
    print "$html<hr>\n";

    # Donu eblecon reredakti la artikolon
    form($art);

} else {

    # Se ne estas indikita ago montru la startpaøon.

print <<EOF
<h1>Vortaroredaktilo por Voko-vortaroj</h1>
<form action="vokored.pl" method=post>
artikolo: <input type=edit name=mrk> (= marko; dosiernomo sen fina¼o)
<p>
<input type=submit name=ago value=redaktu>
<input type=submit name=ago value=kreu>
<input type=submit name=ago value=forigu>
<input type=submit name=ago value=listigu>
</form>
EOF
;
};

print "</body></html>\n";

#--------fino------

sub checkout {
    $dosiero = "$CVSsituo/$mrk.sgm";

    #print "$checkout $dosiero";
    if (not open IN,"$checkout $dosiero|") {
	print "komando $checkout $dosiero\n";
	print "por artikolo $mrk ne sukcesis.\n";
	print "</body></html>";
	exit;
    };
    my $text = join('',<IN>);
    close IN;
    return $text;
}

sub checkin {
}

sub jade {
    my $text = $_[0];

    # indiku, kie estas la DTD
    $text =~ s|<!DOCTYPE[^>]+>|<!DOCTYPE vortaro SYSTEM "$DTD">|i;

    # transdonu la artikolon al "jade"
    open SGM, "|$jade > $tmp/$mrk.$$.htm 2> $tmp/$mrk.$$.jade"
	|| die "Ne povis malfermi dukton al jade.\n";
    print SGM $text;
    close SGM;

    # legu la "jade"-erarojn
    if (not open JADE, "$tmp/$mrk.$$.jade") {
	FINU("Jade ne redonis mesaøojn.\n");
    };
    @jade_eraroj = <JADE>;
    close JADE;
    unlink "$tmp/$mrk.$$.jade";

    # legu la HTML-rezulton
    open IN,"$tmp/$mrk.$$.htm";
    my $html =join('',<IN>);
    close IN;
    unlink "$tmp/$mrk.$$.htm";

    return $html;
}

sub form {
    $text = HTMLigu($_[0]);

print <<EOF
<form action="vokored.pl" method=post>
<input type=hidden name=mrk value=$mrk>
<textarea name=art rows= 20 cols=80>$text</textarea>
<p>
<input type=submit name=ago value=redaktu>
</form>
EOF
;
}

sub listigu {
    
    @dosieroj = glob("$CVSsituo/$mrk*.sgm,v");

    unless (@dosieroj) {
	print "neniuj artikoloj komenciøantaj je \"$mrk\".<p>\n";
	return;
    };

    for $dos (@dosieroj) {
	$dos =~ s/.*\/([^\/]+)\.sgm,v$/$1/;
	print "<a href=\"vokored.pl?ago=redaktu&mrk=$dos\">$dos</a><br>\n";
    };
}

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















