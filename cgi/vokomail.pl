#!/usr/bin/perl

# CGI-programeto por generi paghon por
# retposhte sendi shanghitan artikolon
# au alian komandon al la retposhta servo
# de ReVo

use CGI qw/:html2 :form :cgi/;
$CGI::POST_MAX=1024*1; # akceptu maks. 1kB
$CGI::DISABLE_UPLOADS=1; # ne permesu dosier-shargojn

# agordiloj

# indikoj por la redaktopaghoj
$revo_dir = '/var/www/web277/html/revo';
$revo_url = 'http://reta-vortaro.de/revo';
$html_dir = "$revo_url/art";
$xml_dir = "$revo_dir/xml";
$dok_dir = "$revo_url/dok";
$revo_mail = 'mailto:revo@steloj.de'; 

if ($eraro = test_params() ) {
    print
	header,
	start_html(	-title=>'eraro',
			-meta=>{'http-equiv'=>'Content-Type',
				'content'=>'text/html; charset=UTF-8'}),
	h1("eraro"),
	$eraro,
	end_html;
} else {
    skribu_paghon();
};

### testo de parametroj
sub test_params {
    my $art = param('art');

    if (length($art) > 20) {
	return "Parametro \"art\" estas tro longa.\n";
    }
    if ($art !~ /^[a-z0-9_]*$/) {
	return "Parametro \"art\" povas enhavi nur minusklojn, ciferojn "
	    ."kaj substrekon.\n";
    }

    # Chio en ordo
    return;
}

### redakto-pagho
sub skribu_paghon {

    my $art = param('art');

    print
	header,
        start_html(     -title=>"redakti artikolon $art",
                        -meta=>{'http-equiv'=>'Content-Type',
                                'content'=>'text/html; charset=UTF-8'}),  
	h1("Sendformularo de Revo-servo"),
	"Tiu &#x0109;i formularo sendas retmesa&#x011d;on al ReVo-servo, respondon\n",
	"vi same ricevos retpo&#x015d;te. ReVo-servo akceptas redaktojn nur\n",
	"de registritaj redaktantoj. Necesas, ke via TTT-legilo indikas\n",
	"kiel sendinto tiun retadreson, per kiu vi ali&#x011d;is al ReVo-servo.\n";
#    print
#	p({-align=>"right"}),
#	a({-href=>"$dok_dir/helpo.txt"},"helpo pri ReVo-servo"), br,
#	a({-href=>"$dok_dir/dosieroj.html"},
#	  "dosieroj haveblaj per ReVo-servo"), "</p>";

    if ($art) {
	# prenu la XML-tekston de la artikolo
	open XML,"$xml_dir/$art.xml";
	param(-name=>'teksto', -value=>join('',<XML>));
	close XML;
	unless (param('teksto')) { 
	    param(-name=>'teksto',-value=>"ne trovita: $!") 
	    };

	print
	    p({-align=>"right"}),
	    a({-href=>"$html_dir/$art.html"},"reen al la artikolo"),"</p>",
	    
	    startform('POST',$revo_mail),
	    hidden('komando','redakto'),
	    "redaktita teksto de \"$art\":", br,
	    textarea(-name=>'teksto',
		     -default=>param('teksto'),
		     -rows=>25,
		     -columns=>80),br,
	    "Priskribo de la farita &#x015d;an&#x011d;o (nepre necesa):", br,
	    textfield(-name=>'shangho',-size=>80,maxlength=>200), br,
	    "Sendas la redaktitan artikolon al Revo-servo:", 
	    submit('ago','Sendu'), p,
	    endform;
    } else {
	print
	    p, "Vi ne indikis, kiun artikolon vi volas redakti.";
    }

    print
	end_html;    
}

