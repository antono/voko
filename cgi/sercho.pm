package sercho;

# serchas en indekso a� plena teksto iujn artikolojn
#
# kiel parametroj estu donataj ser�dosiero, ser�esprimo kaj 
# strukturilo, kiu estu traser�ata
#
# La trovlokoj estos redonitaj en la formo
# artikolmarko || kapvorto || deriva�marko ||
# deriva�kapvorto || trovita vorto


# kreu novan ser�objekton

sub nova {
    my $class = shift;
    my %params = @_;
    my $this = {};

    # kopiu parametrojn
    $this->{'dosiero'} = $params{'dosiero'};  # la indeksdosiero, en kiu serchi
    $this->{'esprimo'} = $params{'esprimo'};  # la serchesprimo
    $this->{'strukturo'} = $params{'strukturo'}; # la strukturo, en kiu serchi
    
    # baptu la objekton
    bless $this, $class;
}

# malfermu la dosieron

sub malfermu {
    my $this = shift;
    
    # malfermu la indeksdosieron
    open INX,$this->{'dosiero'} 
      or die "Ne povis malfermi $this->{'dosiero'}.\n";
    $this -> {'dosierreferenco'} = INX;
};

# ser�u artikolon

sub serchu_sekvan {
    my $this = shift;
    my $dos = $this->{'dosierreferenco'};
    my $strukt = $this->{'strukturo'};
    my $esprim = x_Lat3($this->{'esprimo'});
    my @rezulto,@rez1;
    my $amrk,$akap,$rez2,$drv;

    $/='</art';

    # legu unu artikolon
    while (<$dos>) {

	# elprenu la markon
	if (/<art\s+mrk\="([a-zA-Z0-9\.]*)"\s*>/si) { 
	    $amrk = $1; 
	    $amrk =~ s/\s+/ /sg;
	};

	# transformu la artikolon al Latin-3
	$_ = Lat3($_);

	# legu la kapvorton
	if (/<kap[^>]*>(.*?)<\/kap\s*>/si) { 
	    $akap = $1;
	    $akap =~ s/<fnt>(.*)<\/fnt>//sg;
	    $akap =~ s/<[^<]*>//sg;
	    $akap =~ s/\s+Z?$//;
	    $akap =~ s/\s+/ /sg;
	    $akap =~ s/^\s+//;
	};

	if ($strukt eq 'art') {

	    # tildojn anstata�igu per la radiko
	    if (/<rad\s*>(.*?)<\/rad\s*>/si) {
		$drv = $1;
		s/<tld\/?>/$drv/sig;
	    } else {
		s/<tld\/?>/~/sig;
	    };

	    # forigu �iujn strukturilojn el la artikolo
	    s/<\/art$//si;
	    s/[\s]*<[^<]*>[\s]*/ /sg;
	    $rez2 = '';
	    
	    # ser�u la esprimon
	    while (/(\w*$esprim\w*)/g) { $rez2 .= "||".$1; };
	    if ($rez2) { @rezulto = (@rezulto,utf8("$amrk||$akap$rez2")); };
	}
	else {

	    # analizu cxion ekster (anta�) deriva�oj
	    if (/<art[^>]*>(.*?)(?:<drv|<\/art)/si) {
		$drv = "<drv mrk=\"$amrk\">$1</drv>";
		@rez1 = DRV($this,$amrk,$akap,$drv);
		if (@rez1) { @rezulto = (@rezulto,@rez1); };
	    };

	    # analizu la deriva�ojn
	    while (/(<drv.*?<\/drv\s*>)/sig) {
		$drv = $1;
		@rez1 = DRV($this,$amrk,$akap,$drv);
		if (@rez1) { @rezulto = (@rezulto,@rez1); };
	    };

	    # fakte restas netrovata cxio, kio estas inter 
	    # deriva�oj kaj malanta� deriva�oj, tio povus okazi
	    # �e artikoloj, kiuj konsistas el subartikoloj.
	    # kiel plej konvene solvi tion?
	};
	if (@rezulto) { return @rezulto };
    };

    # dosierfino
    close $dos;
    return ();
};

# analizas artikoleron rilate al unu deriva�o

sub DRV {
    my ($this,$amrk,$akap,$tekst) = @_;
    my $mrk,$str,$kap;
    my $strukt = $this->{'strukturo'};
    my $esprim = $this->{'esprimo'};
    $esprim = x_Lat3($esprim) unless ($strukt eq 'trd');
    my @rez;

    # legu la markon
    if ($tekst =~ /<drv\s+mrk\="([a-zA-Z0-9\.]*)"\s*>/si) { 
	$mrk = $1; 
	$mrk =~ s/\s+/ /sg;
    };

    # legu la kapvorton
    if ($tekst =~ /<kap[^>]*>(.*?)<\/kap\s*>/si) { 
	$kap = $1; 
	$akap =~ s/<fnt>(.*)<\/fnt>//sg;
	$kap =~ s/\s+/ /sg;
    };

    # chu la serchata estas ene?

    while ($tekst =~ /<$strukt[^>]*>(.*?)<\/$strukt\s*>/sig) {
	$str = $1;
	if ($str =~ /$esprim/i) {
	    $str =~ s/\s+/ /sg;
	    @rez = (@rez,utf8("$amrk||$akap||$mrk||$kap||$str"));
	};
    };

    return @rez;
};

# anstata�igo de E-literoj

sub Lat3 {
    my $txt = $_[0];
    
    # povus esti unuoj ene
    $txt =~ s/&Ccirc;/\306/sg;
    $txt =~ s/&Gcirc;/\330/sg;
    $txt =~ s/&Hcirc;/\246/sg;
    $txt =~ s/&Jcirc;/\254/sg;
    $txt =~ s/&Scirc;/\336/sg;
    $txt =~ s/&Ubreve;/\335/sg;
    $txt =~ s/&ccirc;/\346/sg;
    $txt =~ s/&gcirc;/\370/sg;
    $txt =~ s/&hcirc;/\266/sg;
    $txt =~ s/&jcirc;/\274/sg;
    $txt =~ s/&scirc;/\376/sg;
    $txt =~ s/&ubreve;/\375/sg;

    # kaj povus esti UTF-8 ene
    $txt =~ s/\304\210/\306/g;
    $txt =~ s/\304\234/\330/g;
    $txt =~ s/\304\244/\246/g;
    $txt =~ s/\304\264/\254/g;
    $txt =~ s/\305\234/\336/g;
    $txt =~ s/\305\254/\335/g;
    $txt =~ s/\304\211/\346/g;
    $txt =~ s/\304\235/\370/g;
    $txt =~ s/\304\245/\266/g;
    $txt =~ s/\304\265/\274/g;
    $txt =~ s/\305\235/\376/g;
    $txt =~ s/\305\255/\375/g;
    
    return $txt;
}

sub x_Lat3 {
    $vort = $_[0];
    # konverti la e-literojn al cx ... ux
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

sub utf8 {
    $txt = $_[0];

    # kaj povus esti UTF-8 ene
    $txt =~ s/\306/\304\210/g;
    $txt =~ s/\330/\304\234/g;
    $txt =~ s/\246/\304\244/g;
    $txt =~ s/\254/\304\264/g;
    $txt =~ s/\336/\305\234/g;
    $txt =~ s/\335/\305\254/g;
    $txt =~ s/\346/\304\211/g;
    $txt =~ s/\370/\304\235/g;
    $txt =~ s/\266/\304\245/g;
    $txt =~ s/\274/\304\265/g;
    $txt =~ s/\376/\305\235/g;
    $txt =~ s/\375/\305\255/g;

    return $txt;
};

# fino de la paka�o
1;

















