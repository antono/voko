package sercho;

# serchas en indekso.sgml 
#
# kiel parametroj ghi prenas la indekso-dosieron, en kiu
# serchi, la serchesprimon kaj la strukturo, en kiu serchi
# la strukturo devas esti substrukturo de <drv>, do
# estas eble momente <kap>, <trd> kaj <ref>.
# La trovlokoj estas redonataj kiel
# marko de la artikolo || artikolkapvorto || marko de la derivajho ||
# derivajh-kapvorto || trovita vorto
#
# tiu chi modulo estas intencita por uzo en CGI-programo.

# kreas novan sercho-'klason'

sub nova {
    my $class = shift;
    my %params = @_;
    my $this = {};

    # kopiu la parametrojn
    $this->{'dosiero'} = $params{'dosiero'};  # la indeksdosiero, en kiu serchi
    $this->{'esprimo'} = $params{'esprimo'};  # la serchesprimo
    $this->{'strukturo'} = $params{'strukturo'}; # la strukturo, en kiu serchi
    
    # baptu la novan objekton
    bless $this, $class;
}


# malfermas la dosieron, voku ghin antau 'serchu_sekvan'

sub malfermu {
    my $this = shift;
    
    # malfermu la indeksdoieron
    open INX,$this->{'dosiero'} or die "Ne povis malfermi $this{'dosiero'}.\n";
    $this -> {'dosierreferenco'} = INX;
};

# serchas, ghis ghi trovis artikolon, en kiu
# trovighas la serchata au ghis la fino
# de la dosiero

sub serchu_sekvan {
    my $this = shift;
    my $dos = $this->{'dosierreferenco'};
    my $strukt = $this->{'strukturo'};
    my $esprim = $this->{'esprimo'};
    my @rezulto,@rez1;
    my $amrk,$akap,$rez2,$drv;

    $/='</art';

    # legu la unu artikolon el la dosiero
    while (<$dos>) {

	# trovu la markon de la artikolo
	if (/<art\s+mrk\="([a-zA-Z0-9\.]*)"\s*>/si) { 
	    $amrk = $1; 
	    $amrk =~ s/\s+/ /sg;
	};

	if ($strukt eq 'art') {

	    # anstatuigu e-signojn
	    s/&([cghjs])circ;/$1x/sig;
	    s/&(u)breve;/$1x/sig;

	    # legu la kapvorton
	    if (/<kap[^>]*>(.*?)<\/kap\s*>/si) { 
		$akap = espsignoj1($1); 
		$akap =~ s/<[^<]*>//sg;
		$akap =~ s/\*\s*//;
		$akap =~ s/[0-9]/\//g;
		$akap =~ s/\s+Z?$//;
		$akap =~ s/\s+/ /sg;
		$akap =~ s/^\s+//;
	    };
    	
	    # trovu la radikon kaj anstatauigu la tildojn
	    if (/<rad\s*>(.*?)<\/rad\s*>/si) {
		$drv = $1;
		s/<tld>/$drv/sig;
	    } else {
		s/<tld>/~/sig;
	    };

	    # forigu chiujn strukturilojn el la artikolo
	    s/<\/art$//si;
	    s/[\s]*<[^<]*>[\s]*/ /sg;
	    $rez2 = '';
	    
	    # serchu la esprimon
	    while (/(\w*$esprim\w*)/g) { $rez2 .= "||".espsignoj1($1); };
	    if ($rez2) { @rezulto = (@rezulto,"$amrk||$akap$rez2"); };
	}
	else {

	    # legu la kapvorton
	    if (/<kap[^>]*>(.*?)<\/kap\s*>/si) { 
		$akap = $1; 
		$akap =~ s/\*\s*//;
		$akap =~ s/[0-9]/\//g;
		$akap =~ s/\s+Z?$//;
		$akap =~ s/\s+/ /sg;
		$akap =~ s/^\s+//;
	    };    

	    # analizu la derivajhojn
	    while (/(<drv.*?<\/drv\s*>)/sig) {
		$drv = $1;
		@rez1 = DRV($this,$amrk,$akap,$drv);
		if (@rez1) { @rezulto = (@rezulto,@rez1); };
	    };
	};
	if (@rezulto) { return @rezulto };
    };

    # fino de la dosiero
    close $dos;
    return ();
};

# tiu chi funkcio redonas la rezulton nur post
# trasercho de la tuta dosiero, ne estas tre
# tauga, kaj momente ne uzata.

sub serchu {
    my $this = shift;
    my @rezulto;
    my $amrk,$akap;
    
    $/='</art';

    # malfermu la indeksdoieron
    open INX,$this->{'dosiero'} or die "Ne povis malfermi $this{'dosiero'}.\n";

    # legu la unuopajn artikol-indekserojn el indekso
    while (<INX>) {

	# trovu la markon de la artikolo
	if (/<art\s+mrk\="([a-zA-Z0-9\.]*)"\s*>/si) { 
	    $amrk = $1; 
	    $amrk =~ s/\s+/ /sg;
	};
	# legu la kapvorton
	if (/<kap[^>]*>(.*?)<\/kap\s*>/si) { 
	    $akap = $1; 
	    $akap =~ s/\s+/ /sg;
	    $akap =~ s/[0-9]/\//g;
	    $akap =~ s/\*\s*//;
	};    
	# analizu la derivajhojn
	while (/(<drv(.*?)<\/drv\s*>)/sig) {
	    my @rez = DRV($this,$amrk,$akap,$1);
	    if (@rez) { push @rezulto, @rez; };
	};
    };

    return @rezulto;
};

sub DRV {
    my ($this,$amrk,$akap,$tekst) = @_;
    my $mrk,$str,$kap;
    my $strukt = $this->{'strukturo'};
    my $esprim = $this->{'esprimo'};
    my @rez;

    # legu la markon
    if ($tekst =~ /<drv\s+mrk\="([a-zA-Z0-9\.]*)"\s*>/si) { 
	$mrk = $1; 
	$mrk =~ s/\s+/ /sg;
    };

    # legu la kapvorton
    if ($tekst =~ /<kap[^>]*>(.*?)<\/kap\s*>/si) { 
	$kap = $1; 
	$kap =~ s/\s+/ /sg;
	#$kap =~ s/[0-9]/\//g;
	$kap =~ s/\*\s*//;
    };

#    print "$kap\n";

    # chu la serchata estas ene?

    while ($tekst =~ /<$strukt[^>]*>(.*?)<\/$strukt\s*>/ig) {
	$str = $1;
	$str = espsignoj($str);
	if ($str =~ /$esprim/i) {
	    $str =~ s/\s+/ /sg;
	    $str = espsignoj1($str);
	    @rez = (@rez,"$amrk||$akap||$mrk||$kap||$str");
	};
    };

    return @rez;
};

sub espsignoj {
    $vort = $_[0];
    # konverti la e-literojn al cx ... ux
    $vort =~ s/\306/Cx/g;
    $vort =~ s/\330/Gx/g;
    $vort =~ s/\246/Hx/g; 
    $vort =~ s/\254/Jx/g;
    $vort =~ s/\336/Sx/g;
    $vort =~ s/\335/Ux/g;
    $vort =~ s/\346/cx/g;
    $vort =~ s/\370/gx/g;
    $vort =~ s/\266/hx/g;
    $vort =~ s/\274/jx/g;
    $vort =~ s/\376/sx/g; 
    $vort =~ s/\375/ux/g;

    return $vort;
};

sub espsignoj1 {
    $vort = $_[0];
    # konverti la e-literojn de cx ... ux
    $vort =~ s/Cx/\306/g;
    $vort =~ s/Gx/\330/g;
    $vort =~ s/Hx/\246/g; 
    $vort =~ s/Jx/\254/g;
    $vort =~ s/Sx/\336/g;
    $vort =~ s/Ux/\335/g;
    $vort =~ s/cx/\346/g;
    $vort =~ s/gx/\370/g;
    $vort =~ s/hx/\266/g;
    $vort =~ s/jx/\274/g;
    $vort =~ s/sx/\376/g; 
    $vort =~ s/ux/\375/g;

    return $vort;
};


# fino de la pakajho
1;


