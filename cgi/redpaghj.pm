# modulo por generi la paghojn kaj
# por kontroli la rajton de uzanto

# AGENDO: 
# - linifinoj che "ci", 
# - eble rekte skribu xml-dosierojn, ne uzu /tmp
# - pli kompleta trakto de eraroj en la provcedoj
# - aldonu konverton al html
# - kiu posedu/rajtu shanghi la dosierojn?
#   se ne alie funkcius: skribu rezultan dosieron ien,
#   kaj cron-tasko konvertu ghin okaze...
#   alia varianto: sgid por ci, rlog, rxd, ktp.
# - laueble ne uzu "sh" (vd. man perlsec)

package redpaghj;

use CGI qw/:html2 :form :cgi/;

# agordiloj

# indikoj por la redaktopaghoj
$radiko = 'file:/home/wolfram/xml/html';
#$domain = 'www.uni-leipzig.de'; # por kuketo
$domain = 'localhost';
$admin = 'mailto: diestel@rzaix340.rz.uni-leipzig.de';
$passwd = '/home/wolfram/xml/redaktoroj';

# div. indikoj
$debug = 1;
$tmp = "/tmp";
$xmlcheck = "rxp -V ";
$dtd = '/home/wolfram/xml/vokoxml.dtd';
$xml2html = "/home/wolfram/xml/xml2html";
$html_dir = "/home/wolfram/xml/html";

# indikoj por RCS
$rcs_dir = "/kde/voko/revo";
$checkout = "/home/wolfram/xml/bin/co -q -p ";
$lock = "/home/wolfram/xml/bin/rcs -l ";
$checkinfirst = "/home/wolfram/xml/bin/ci -r -i -t-";
$checkin = "/home/wolfram/xml/bin/ci -r -j -m";
$rlog = "/home/wolfram/xml/bin/rlog";

#################### SENCIMIGO ###########################

sub debug_info {
    unless ($debug) { return; }
    else {
	my $info = '';

	# montras parametrojn, kuketon ktp.
	my @names = param;
	foreach $par (@names) {
	    if ($par eq 'teksto' or $par eq 'eraro') {
		$info .= "$par=";
		$info .= substr(param($par),0,20)."..." if (param($par));
		$info .= "<br>\n";
	    } else {
		$info .= "$par=".param($par)."<br>\n";
	    }
	}
	$info .= "path_info: ".path_info()."<br>\n";
	$info .= "cookie:    ".cookie('uzanto')."<br>\n";
	return $info;
    }
}

##################### TESTO DE PARAMETROJ ################

sub test_params {
    my $art = param('art');
    if (length($art) > 20) {
	return "Parametro \"art\" estas tro longa.\n";
    }
    if ($art !~ /^[a-z0-9_]*$/) {
	return "Parametro \"art\" povas enhavi nur minusklojn, ciferojn "
	    ."kaj substrekon.\n";
    }

    if (length($uzanto) > 20) {
	return "Parametro \"uzanto\" estas tro longa.\n";
    }
    if ($uzanto !~ /^[a-z0-9_]*$/) {
	return "Parametro \"uzanto\" povas enhavi nur minusklojn, ciferojn "
	    ."kaj substrekon.\n";
    }

    if (length($shangho) > 200) {
	return "Parametro \"shangho\" estas tro longa.\n";
    }
    if ($shangho !~  /^[A-Za-z0-9_\.,:!\?\- ]*$/) {
	return "Parametro \"shangho\" povas enhavi nur literojn, ciferojn "
	    ."kaj la frazsignojn .,:!?-\n";
    }

    # æio en ordo
    return;
}

##################### RAJTIGO ############################

### chu uzanto estas rajtigita?
# uzanto estas rajtigita, se li posedas ghustan
# rajtigilon, t.e. kombinajho el uzantnomo kaj uzantnomo
# kodita per la pasvortkodo:
#    "$uzanto:".crypt($uzanto,$kodo)
# aý se li entajpis uzantnomon kaj pasvorton
# kaj tiuj estas validaj crypt($pasvorto,$kodo) = $kodo
# La pasvortkodo $kodo estas prenita el la dosiero
# kun la redaktoroj.
sub rajtigita {

    my $rajtigilo = cookie('uzanto');
    my $uzanto = param('uzanto');
    my $pasvorto = param('pasvorto');
    my $kodo = '';
    my $cookie = '';

    # kiu estas la uzanto?
    if ($rajtigilo) {
	($uzanto,$pasvorto) = split(':',$rajtigilo);
        param('uzanto',$uzanto);
    } else {
	unless ($uzanto) {
	    print header;
	    return; # mankas kaj uzanto kaj rajtigilo
	}
    }

    # elprenu la koncernan linion en la pasvort-dosiero
    open IN,$passwd or return;
    while (<IN>) {
	chop;
	if (/^$uzanto\:(.*)$/) {
	    $kodo = $1;
	    goto TEST;
	}
    };

    warn "ERROR\n";
    # ne trovighis en la redaktoro-dosiero
    close IN;
    print header;
    return; # nevalida uzantnomo

TEST:
    close IN;
    # testu
    if ($rajtigilo) {
	if (crypt($uzanto,$kodo) eq $pasvorto) {
	    # refreshigu kuketon
	    $cookie = cookie(-name=>'uzanto',
			     -value=>$rajtigilo,
			     -expires=>'+1h',
			     -path=>'/cgi-bin/redakti.pl'#,
#			     -domain=>$domain
			     );
	    print header(-cookie=>$cookie);
	    return ($rajtigilo);
	} else { 
	    print header;
	    return; # malghusta rajtigilo
	}
    } else {
	if (crypt($pasvorto,$kodo) eq $kodo) {
	    # kreu kuketon
	    $rajtigilo=$uzanto.":".crypt($uzanto,$kodo);
	    $cookie = cookie(-name=>'uzanto',
			     -value=>$rajtigilo,
			     -expires=>'+1h',
			     -path=>'/cgi-bin/redakti.pl'#,
#			     -domain=>$domain
			     );
	    print header(-cookie=>$cookie);
	    return ($rajtigilo);
	} else {
	    print header;
	    return; # malghusta pasvorto
	}
    };
}


############################# PAGHOJ #####################

### skribas salut-paghon por rajtigi sin
sub pagho_rajtigo {
    my $art = param('art');
    my $uzanto = param('uzanto');

    print
	start_html("rajtigilo"),
        debug_info,
	h1("rajtigilo");
    print
	"Vi donis maløustan uzantnomon/pasvorton.\n",br if ($uzanto);
    print
	"Entajpu vian uzantonomon kaj pasvorton.\n",p,

	startform('POST',url()),
	"uzanto:", br, 
	textfield('uzanto'),br,
	"pasvorto:", br,
	password_field('pasvorto'),br;
    print 
	hidden('art') if ($art);
    print
	hidden('orig'),
	submit('ago','Konfirmu'),
	endform,

	hr,
	"Se vi ankoraý ne havas uzantnomon kaj pavorton, legu la\n",
	a({-href=>"$radiko/dok/redaktregul.html"},"regularon pri redaktado"),
	" kaj poste sendu retmesaøon al la\n",
	a({-href=>$admin}, "administranto"),
	" de la vortaro. Indiku vian preferatan uzantnomon kaj",
	" pasvorton. Se vi uzas Uniksan sistemon vi prefere æifru",
	" la pasvorton kiel en /etc/passwd. Vi povas æifri øin per",
	" <code>perl -e 'print crypt \"&lt;pasvorto&gt;\" \"&lt;iuj",
	" literoj&gt;\"'</code>.",

	end_html;
}

### eraro-pagho
sub pagho_eraro {
    my $eraro = shift;

    print
	start_html("eraro"),
	debug_info,
	h1("eraro"),
	"Okazis eraro: $eraro",
	p,
	end_html;
}

### redakto-pagho
sub pagho_redakti {

    my $art = param('art');
    unless (param('teksto')) { checkout() };
    unless (param('teksto')) { param(-name=>'teksto',-value=>'ne trovita!') };

    print
	start_html("redakti $art"),
        debug_info,
	h1("redakti \"$art\""),
	p({-align=>"right"}),
	a({-href=>"$radiko/$art.html"},"al la artikolo"),"</p>";

    if (param('eraro')) {
	print 
	    "<pre>",
	    param('eraro'),
	    "</pre>";
    };

    print
	startform('POST',url()),
	hidden('art'),
	hidden('orig'),
	submit('ago','centra redaktopaøo'),br,
	endform(),

	startform('POST',url()."/redakti"),
	submit('ago','Þanøu'),br,
	textarea(-name=>'teksto',
		 -default=>param('teksto'),
		 -rows=>25,
		 -columns=>80),br,
	"priskribo de la þanøo:", br,
	textfield(-name=>'shangho',-size=>80,maxlength=>200), br,
	hidden('art'),
	hidden('orig'),
	submit('ago','Þanøu'),
	endform,

	end_html;    
}


### historio-pagho
sub pagho_historio {

    my $art = param('art');

    print
	start_html("historio de $art"),
        debug_info,
	h1("historio de \"$art\""),

	"<pre>",
	`$rlog $rcs_dir/$art.xml,v`,
	"</pre>",

	start_form('POST',url()),
	
	hidden('orig'),
	hidden('art'),
	submit('ago','centra redaktopaøo'),
	end_form(),
	end_html;    

}


### forigkonfirmo-pagho
sub pagho_forigi {

    my $art = param('art');

    print
	start_html("forigo de $art"),
        debug_info,
	h1("forigo de \"$art\""),
	startform('POST',url()."/for_jes"),
	"Æu vere forigi \"$art\"?",br,
	hidden('orig'),
	hidden('art'),
	submit('ago','Jes'),
	endform,

	end_html;    

}


### forigrezulto-pagho
sub pagho_forigita {

    my $art = param('art');

    print
	start_html("forigita: $art"),
        debug_info,
	h1("forigita: \"$art\""),
	"La artikolo $art estas forigita.",br,
	startform('POST',url()),
#	"Reiru al la ",br,
	hidden('orig'),
	hidden('art'),
	submit('ago','centra redaktopaøo'),
	endform,

	end_html;    
}


### aldono-pagho
sub pagho_aldoni {

    print
	start_html("krei novan artikolon"),
        debug_info,
	h1("krei novan artikolon"),
	"Por krei novan artikolon plenigu la malsupran formularon ",
	"kaj poste premu \"Redakti\"",p,

	startform('POST',url()."/redakti"),
	"identigilo de la nova artikolo:",br,
	textfield('art'), "(ekz. \"zigzag\")",br,
	"kapvorto:",br,
	textfield('kapvorto'), "(ekz. \"zigzag/o\")",br,
	"þablono:",br,
	radio_group(-name=>'sxablono',
		    -values=>['simpla','sencoj','deriva¼oj','subartikoloj'],
		    -default=>['simpla'],
		    -linebreak=>'true'),br,
	hidden('orig'),
	submit('ago','Redaktu'),
	endform,

	hr, "La identigilo de artikolo servas: ",
	br, "a) kiel dosiernomo, ekz. \"zigzag.xml\" kaj ",
	br, "b) kiel marko por referencoj, do ",
	"&lt;ref cel=\"zigzag.0o\"&gt; referencas la vorton \"zigzago\", ",
	"&lt;drv mrk=\"zigzag.0o\"&gt; estas la celo de tiu referenco.",

	p, "En la kapvorto dispartigu la radikon de la fina¼o per \"/\", ",
	"se la vorto ne havas fina¼on ne enmetu la strekon. ",

	end_html;        
}


### centra redakto-pagho
sub pagho_centra {

    print
	start_html("centra redaktopaøo"),
        debug_info,
	h1("centra redaktopaøo"),

	"Malsupre skribu la nomon de la dosiero, kiu reprezentas ",
	"la artikolon (= marko de la artikolo) kaj premu la korespondan ",
	"klavon.",p,
	
	startform('POST',url()."/redakti"),
	"redaktu artikolon:", br,
	textfield('art'), submit('ago','Redaktu'),
	hidden('orig'),
	endform,br,

	startform('POST',url()."/historio"),
	"historio de la artikolo:", br,
	textfield('art'), submit('ago','Historio'),
	hidden('orig'),
	endform,br,

	startform('POST',url()."/forigi"),
	"forigu artikolon:", br,
	textfield('art'), submit('ago','Forigu'),
	hidden('orig'),
	endform,br,

	startform('POST',url()."/aldoni"),
        "aldonu artikolon:", br,
	textfield('art'), submit('ago','Aldonu'),
	hidden('orig'),
	endform,br,

	end_html;        
}

######################### PROCEDOJ ###################

### aldonu novan artikolon
sub aldonu {
    my $art = param('art');
    my $kapvorto = param('kapvorto');
    my $sxablono = param('sxablono');

    my $fino='';
    my $_fino='';

    if ($kapvorto =~ /(.*)\/(.*)/) {
	$kapvorto=$1;
	$_fino='/'.$2;
	$fino=$2;
    };

    param(-name=>'teksto',-value=>
	  sprintf($sxablonoj{$sxablono},$art,$kapvorto,$_fino,$fino));

}


### shanghu artikolon
sub shanghu {
    # kontrolu la sintakson

    xmlcheck();

    unless (param('eraro')) {
	checkin();

	# kontrolu, chu okazis eraro dum checkin...

	# transformu al html
	xml_html();
    }
}


### forigu artikolon
sub forigu {

}


### kontrolu la XML-sintakson de artikolo
sub xmlcheck {
    my $art = param('art');
    my $text = param('teksto');

    $text =~  s/(<!DOCTYPE\s+vortaro\s+SYSTEM\s+\")[^"]*(">)/$1$dtd$2/si;

    if (not open OUT,">$tmp/$art.xml") {
	print 
	    "Ne povis krei $tmp/$art.xml\n",
	    end_html;
	exit; #???
    }
    print OUT $text;
    close OUT;

    # kontrolu la sintakson
    `$xmlcheck $tmp/$art.xml 2>$tmp/xml-err.$$`;
    param(-name=>'eraro',-value=>read_n_del_file("$tmp/xml-err.$$"));
}


### transformu al html
sub xml_html{
    my $htmldosiero = "$html_dir/".param('art').".html";
    my $text = param('teksto');

    $text =~  s/(<!DOCTYPE\s+vortaro\s+SYSTEM\s+\")[^"]*(">)/$1$dtd$2/si;
    replace_entities(\$text);

    open X2H, "| $xml2html - $htmldosiero";
    print X2H $text;
    close X2H;

    if ($!) { param(-name=>eraro,-value=>param('eraro')."xml2html:\n $!") };
}


### elprenu artikolon el la ar¶ivo
sub checkout {
    my $art = param('art');
    my $dosiero = "$rcs_dir/$art.xml";

    if (not open IN,"$checkout $dosiero|") {
	print 
	    "komando $checkout $dosiero\n",
	    "por artikolo $art ne sukcesis. $!\n",
	    end_html;
	exit; #???
    };
    my $text = join('',<IN>);
    close IN;

    param(-name=>'teksto',-value=>$text);
}

### enemetu artikolon en la ar¶ivon
sub checkin {
    my $art = param('art');
    my $text = param('teksto');
    my $uzanto = param('uzanto');
    my $shangho = param('shangho');

    # skribu la tekston en provizoran dosieron
    # æar "ci" atendas, ke la dosiernomo estas la sama kiel
    # la jam ekzistanta dosiero (sen ,v) 

### anstataýe ni provas malhelpi tion per "lock"
    # ni devas
    # krei subdosieron, alikaze okazus problemoj
    # se du homoj samtempe aktualigas la saman artikolon

    if (not open OUT,">$tmp/$art.xml") {
	print 
	    "Ne povis krei $tmp/$art.xml\n",
	    end_html;
	exit; #???
    }
    print OUT $text;
    close OUT;

    # æu øi jam ekzistas?
    if (-s "$rcs_dir/$art.xml,v") {

	# metu en la RCS-deponejon
	system "$lock $rcs_dir/$art.xml,v 2> $tmp/ci-err.$$";
	system "$checkin\'$shangho\' -w$uzanto $tmp/$art.xml $rcs_dir/$art.xml,v 2>> $tmp/ci-err.$$";

    } else {
	
	system "$checkinfirst\'$shangho\' -w$uzanto $tmp/$art.xml $rcs_dir/$art.xml,v 2>> $tmp/ci-err.$$";

    };

    unlink "$tmp/$art.xml";
    
    param(-name=>'eraro',-value=>"ci:\n".read_n_del_file("$tmp/ci-err.$$"));
}

### legu kaj forigu dosieron (por provizoraj erarenhavaj dosieroj)
sub read_n_del_file {
    my $file = shift;

    if (open IN,$file) {
	my $str = join('',<IN>);
	close IN;
	unlink $file;

	return $str;
    }
}

sub replace_entities {
    my $text = shift;

    $$text =~ s/&Ccirc;/&#x108;/sg;
    $$text =~ s/&ccirc;/&#x0109;/sg;
    $$text =~ s/&Gcirc;/&#x011c;/sg;
    $$text =~ s/&gcirc;/&#x011d;/sg;
    $$text =~ s/&Hcirc;/&#x0124;/sg;
    $$text =~ s/&hcirc;/&#x0125;/sg;
    $$text =~ s/&Jcirc;/&#x0134;/sg;
    $$text =~ s/&jcirc;/&#x0135;/sg;
    $$text =~ s/&Scirc;/&#x015c;/sg;
    $$text =~ s/&scirc;/&#x015d;/sg;
    $$text =~ s/&Ubreve;/&#x016c;/sg;
    $$text =~ s/&ubreve;/&#x016d;/sg;   
}

########################### SHABLONOJ ######################

### sxablonoj por novaj artikoloj

$xml_decl  = '<?xml version="1.0" encoding="UTF-8"?>';
$doc_type  = '<!DOCTYPE vortaro SYSTEM "../dtd/vokoxml.dtd">';

%sxablonoj = ("simpla" => 
qq|$xml_decl
$doc_type
<vortaro>
<art mrk="%s">
<kap><rad>%s</rad>%s</kap>
<drv>
<kap><tld/>%s</kap>
<snc>
<dif>--- tie &ccirc;i enmetu la difinon ---:
<ekz>--- ekzemplo 1 ---</ekz>;
<ekz>--- ekzemplo 2 ---</ekz>.
</dif>
<trd lng="de">--- germana traduko ---</trd>
<trd lng="en">--- angla traduko ---</trd>
</snc>
</drv>
</art>
</vortaro>
|,

	      "sencoj" =>
qq|$xml_decl
$doc_type
<vortaro>
<art mrk="%s">
<kap><rad>%s</rad>%s</kap>
<drv>
<kap><tld/>%s</kap>
<snc num="1">
<dif>--- tie &ccirc;i enmetu la difinon de la unua senco ---:
<ekz>--- ekzemplo 1 ---</ekz>;
<ekz>--- ekzemplo 2 ---</ekz>.
</dif>
<trd lng="de">--- germana traduko ---</trd>
<trd lng="en">--- angla traduko ---</trd>
</snc>
<snc num="2">
<dif>--- tie &ccirc;i enmetu la difinon de la dua senco ---:
<ekz>--- ekzemplo 1 ---</ekz>;
<ekz>--- ekzemplo 2 ---</ekz>.
</dif>
<trd lng="de">--- germana traduko ---</trd>
<trd lng="en">--- angla traduko ---</trd>
</snc>
<snc num="3">
<dif>--- tie &ccirc;i enmetu la difinon de la tria senco ---:
<ekz>--- ekzemplo 1 ---</ekz>;
<ekz>--- ekzemplo 2 ---</ekz>.
</dif>
<trd lng="de">--- germana traduko ---</trd>
<trd lng="en">--- angla traduko ---</trd>
</snc>
</drv>
</art>
</vortaro>
|,
              "deriva¼oj" =>
qq|$xml_decl
$doc_type
<vortaro>
<art mrk="%s">
<kap><rad>%s</rad>%s</kap>
<drv>
<kap><tld/>%s</kap>
<snc>
<dif>--- tie &ccirc;i enmetu la difinon de la unua deriva&jcirc;o ---:
<ekz>--- ekzemplo 1 ---</ekz>;
<ekz>--- ekzemplo 2 ---</ekz>.
</dif>
<trd lng="de">--- germana traduko ---</trd>
<trd lng="en">--- angla traduko ---</trd>
</snc>
</drv>
<drv>
<kap><tld/>a</kap>
<snc>
<dif>--- tie &ccirc;i enmetu la difinon de la dua deriva&jcirc;o ---:
<ekz>--- ekzemplo 1 ---</ekz>;
<ekz>--- ekzemplo 2 ---</ekz>.
</dif>
<trd lng="de">--- germana traduko ---</trd>
<trd lng="en">--- angla traduko ---</trd>
</snc>
</drv>
<drv>
<kap>mal<tld/>o</kap>
<snc>
<dif>--- tie &ccirc;i enmetu la difinon de la tria deriva&jcirc;o ---:
<ekz>--- ekzemplo 1 ---</ekz>;
<ekz>--- ekzemplo 2 ---</ekz>.
</dif>
<trd lng="de">--- germana traduko ---</trd>
<trd lng="en">--- angla traduko ---</trd>
</snc>
</drv>
</art>
</vortaro>
|,
              "subartikoloj" =>
qq|$xml_decl
$doc_type
<vortaro>
<art mrk="%s">
<kap><rad>%s</rad>%s</kap>
<subart>
<dif>--- tie &ccirc;i enmetu la difinon de la unua subartikolo---:
</dif>
<snc>
<dif>--- tie &ccirc;i enmetu la unuan difinon ---:
<ekz>--- ekzemplo 1 ---</ekz>;
<ekz>--- ekzemplo 2 ---</ekz>.
</dif>
<trd lng="de">--- germana traduko ---</trd>
<trd lng="en">--- angla traduko ---</trd>
</snc>
</subart>
<subart>
<snc>
<dif>--- tie &ccirc;i enmetu la duan difinon ---:
<ekz>--- ekzemplo 1 ---</ekz>;
<ekz>--- ekzemplo 2 ---</ekz>.
</dif>
<trd lng="de">--- germana traduko ---</trd>
<trd lng="en">--- angla traduko ---</trd>
</snc>
</subart>
</art>
</vortaro>
|
);




1;
