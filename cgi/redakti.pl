#!/usr/bin/perl

use CGI qw/:cgi/; 

$CGI::POST_MAX=1024*100; # akceptu maks. 100kB
$CGI::DISABLE_UPLOADS=1; # ne permesu dosier-shargojn
 
# la redaktopaghoj estas generitaj
# de aparta modulo, tie chi estas
# nur la logiko

use redpaghj; 

$|=1;

# kontrolu chu la uzanto estas rajtigita

unless (redpaghj::rajtigita) {

#### la uzanto ne estas rajtigita ####

    redpaghj::pagho_rajtigo;

} else {

#### la uzanto estas rajtigita ####

    if ($eraro = redpaghj::test_params) {

        redpaghj::pagho_eraro($eraro);

    } else {

	# procedu ion, se necese
	$orig   = param('orig'); $orig =~ s|^/||;
	if    ($orig eq 'aldoni')  { redpaghj::aldonu  }
	elsif ($orig eq 'redakti') { redpaghj::shanghu }
	elsif ($orig eq 'forigi')  { redpaghj::forigu  }
	
	# redonu la paghon
	$pagho = path_info(); $pagho =~ s|^/||;
	param(-name=>'orig',-value=> path_info());
	if    ($pagho eq 'redakti' ) { redpaghj::pagho_redakti  }
	elsif ($pagho eq 'historio') { redpaghj::pagho_historio }
	elsif ($pagho eq 'forigi'  ) { redpaghj::pagho_forigi   }
	elsif ($pagho eq 'for_jes' ) { redpaghj::pagho_forigita }
	elsif ($pagho eq 'aldoni'  ) { redpaghj::pagho_aldoni   }
	else                         { redpaghj::pagho_centra   }
    }
}








