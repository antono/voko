#!/usr/bin/perl

# CGI-programeto por redaktado de vortara artikolo
# la artikoloj troviøas en CVS-deponejo

# parametroj:
# mrk - la marko de la artikolo (~ dosiernomo)
# ago - legu, skribu, kreu, forigu (artikolon)
# art - la teksto de la artikolo

# konfigura¼o
$CVSsituo = "/home/wolfram/cvsroot/vort";
$tmp = "/tmp";
$VOKO = "/home/wolfram/work/voko";
$DTD = "$VOKO/dtd/vokosgml.dtd";
$DSL = "$VOKO/dsl/vokoart.dsl";
$jade = "/usr/bin/jade -t sgml -d $DSL ";
$checkout = "/usr/bin/co -q -p ";
$lock = "/usr/bin/rcs -l ";
$checkinfirst = "/usr/bin/ci -r -i -t-";
$checkin = "/usr/bin/ci -r -j -m";
$rlog = "/usr/bin/rlog";

# komenco de la programo

use CGI;
$cgi = new CGI;

#$htmlvortaro = "http://localhost/voko/red";

$mrk = $cgi->param('mrk');
$ago = lc($cgi->param('ago'));
$logmsg = $cgi->param('logmsg');
$kiu = $cgi->param('kiu');

# forigu æiujn ne-literojn el $mrk
$mrk =~ s/[^A-Za-z0-9_]//g;

# forigu æiujn ne-literojn el $logmsg
$logmsg =~ s/[^a-zA-Z0-9\.,;!\?\+\-_ "']//g;     
#$logmsg =~ s/\\//g;
$logmsg =~ s/"/'/g;
#$logmsg =~ s/\$/'\$'/eg;

# forigu chiujn ne-literojn el $kiu
$kiu =~ s/[^a-zA-Z\-_ ]//g;
$kiu =~ s/[ \-]/_/g;

# kapo de la HTML-dosiero
print "Content-Type: text/html\n\n";
print "<html><head><meta http-equiv=\"Content-Type\"";
print "content=\"text/html; charset=iso-8859-3\">";
print "<title>artikolo: $mrk</title></head>\n";
print "<body>\n";

# testu la parametrojn
if ($ago) {
  # æu $mrk estas valida?
  if (not $mrk) {
    FINU("La marko de la artikolo ne estas indikita.\n");
  };

  # æu $kiu estas valida?
  if ((not $kiu) or (length($kiu)<3)) {
    FINU("Vi ne indikis taýgan nomon vian.\n");
  };
}

if ($ago eq 'kreu') {

    form("<!doctype vortaro system>\n\n<vortaro>\n<art mrk=\"$mrk\">\n".
	 "<kap>$mrk</kap>\n...\n</art>\n</vortaro>\n");

} elsif ($ago eq 'forigu') {

    # forigu la dosieron kun la artikolo
    #unlink "$vortaro/red/$mrk.sgm";
    print "forigo ankoraý ne funkcias...<p>\n";
    print "<a href=\"vokored.pl?kiu=$kiu\">komencopaøo</a></p>\n";

} elsif ($ago eq 'listigu') {

    # listigu æiujn artikolojn, kies nomo komenciøas je $mrk
    listigu();

} elsif ($ago eq 'redaktu') {

    local $komencu = 0;

    print "<h1>artikolo \"$mrk\"</h1>";
    # versio-informoj
    print "<p align=right><a href=\"vokored.pl?ago=info&mrk=$mrk&kiu=$kiu\">"
         ."versio-informoj</a><br>";
    # Al centra paøo
    print "<a href=\"vokored.pl?kiu=$kiu\">komencopaøo</a></p>\n";

    #print "<hr>";

    # ricevu la SGML-tekston de la artikolo
    $art = malHTMLigu($cgi->param('art'));
    unless ($art) {
	$komencu = 1;
	$art = checkout();
    };

    unless ($art) {
	print "Nova artikolo.<p>\n";
	form("<!doctype vortaro system>\n\n<vortaro>\n<art mrk=\"$mrk\">\n".
	     "<kap>$mrk</kap>\n...\n</art>\n</vortaro>\n");

    } else {
	local @jade_eraroj;
	$html = jade($art);
 
	my $err = 0;
	if (@jade_eraroj) {
	    print "<h2>\"Jade\" redonis erarojn</h2>\n<pre>\n";

	    # analizu ilin iomete
	    for $eraro (@jade_eraroj) {
#	    print $eraro;
		$eraro =~ /^[^:]*jade:[^:]*:(\d+:\d+):(.*)$/;
		$che = $1;
		$msg = $2;
		print "æe $che - $msg\n";
		$err = ($err or ($msg !~ /reference to non\-existent ID/));
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
		@output = checkin($art);
		if (@output) {
		    print "<h2>Sekurigmesaøoj</h2>\n";
		    print join("\n<br>",@output);
		    
		    if ($output[$#output] =~ /^\s*done\s*$/) {
			print "<p>La þanøoj estas sekurigitaj.<p>";
		    };
		};
	    };

	} else {
	    print "Bonvolu korekti la suprajn erarojn kaj reprovu. ";
	    print "La þanøoj ne estas sekurigitaj pro la eraroj.";
	};

	# Montru la tekston de la artikolo
	print "$html<hr>\n";
	
	# Donu eblecon reredakti la artikolon
	form($art);
    };

    # Al centra paøo
    print "<hr><a href=\"vokored.pl?kiu=$kiu\">komencopaøo</a>\n";

} elsif ($ago eq "info") {

  # montru versio-informojn
  print "<pre>\n";
  print `$rlog $CVSsituo/$mrk.sgm,v`;
  print "</pre>\n";  

} else {

# Se ne estas indikita ago montru la startpaøon.

print <<EOF
<h1>Vortaroredaktilo por Voko-vortaroj</h1>
<form action="vokored.pl" method=post>
via nomo: <input type=edit name=kiu value=$kiu> 
 (ekz. "L_L_Zamenhof")
<p>
artikolo: <input type=edit name=mrk value=$mrk> 
 (= marko; dosiernomo sen fina¼o)
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
	print "por artikolo $mrk ne sukcesis. $!\n";
	print "</body></html>";
	exit;
    };
    my $text = join('',<IN>);
    close IN;
    return $text;
}

sub checkin {
    my $text = $_[0];

    # skribu la tekston en provizoran dosieron
    # æar ci atendas, ke la dosiernomo estas la sama kiel
    # la jam ekzistanta dosiero (sen ,v) ni devas
    # krei subdosieron, alikaze okazus problemoj
    # se du homoj samtempe aktualigas la saman artikolon

    `mkdir $tmp/$$`;
    open OUT,">$tmp/$$/$mrk.sgm" or 
	FINU("Ne povis krei $tmp/$$/$mrk.sgm");
    print OUT $text;
    close OUT;

    # æu øi jam ekzistas?
    if (-s "$CVSsituo/$mrk.sgm,v") {

	#print "$checkin\"$logmsg\" $tmp/$mrk.sgm $CVSsituo/$mrk.sgm,v<p>";
	# metu en la CVS-deponejon
	`$lock $CVSsituo/$mrk.sgm,v 2> $tmp/ci-err.$$`;
	`$checkin\"$logmsg\" -w$kiu $tmp/$$/$mrk.sgm $CVSsituo/$mrk.sgm,v 2>> $tmp/ci-err.$$`;

    } else {
	
	`$checkinfirst\"$logmsg\" -w$kiu $tmp/$$/$mrk.sgm $CVSsituo/$mrk.sgm,v 2>> $tmp/ci-err.$$`;

    };

    unlink "$tmp/$$/$mrk.sgm";
    `rmdir $tmp/$$`;
    
    open ERR,"$tmp/ci-err.$$";
    @err = <ERR>;
    close ERR;
    unlink ("$tmp/ci-err.$$");
    
#    print @err;

    return @err;
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

    # elprenu la parton inter <body>...</body>
    $html =~ s/^.*?<body[^>]*>//si;
    $html =~ s/<\/body\s*>.*$//si;

    # anstataýigu la referencojn
    $html =~ s/(<a\s+href=)"\#([a-z]+)([a-z0-9\.]+)?"(\s*>)/
	"$1\"vokored.pl?ago=redaktu&kiu=$kiu&mrk=".lc($2)."#$2$3\"$4"/sieg;

    return $html;
}

sub form {
    $text = HTMLigu($_[0]);

print <<EOF
<form action="vokored.pl" method=post>
<input type=hidden name=mrk value=$mrk>
<input type=hidden name=kiu value=$kiu>
<textarea name=art rows= 20 cols=80>$text</textarea>
<p>
<input type=edit size=40 name=logmsg value="$logmsg">
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
	print "<a href=\"vokored.pl?ago=redaktu&mrk=$dos&kiu=$kiu\">"
              ."$dos</a><br>\n";
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















