#!/usr/bin/perl 
#
# voku 
#   vokorefs2.pl [-v] [<config-file>]
#
# ekz. 
#   vokorefs2.pl -v vortaro.cfg
#
################# komenco de la programo ################

use XML::Parser;

$debug = 0;
$show_progress = 0;
$| = 1;

$tez_lim = 10;
@romiaj = ('0','I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII');

# analizi la argumentojn

while (@ARGV) {
    if ($ARGV[0] eq '-v') {
	$verbose = 1;
	shift @ARGV;
    } else {
	$cfg_file = shift @ARGV;
    };
};

# legu la agordo-dosieron
unless ($cfg_file) { $cfg_file = "cfg/vortaro.cfg" };

%config = read_cfg($cfg_file);
%fakoj = read_cfg($config{'fakoj'});
delete $fakoj{'KOMUNE'}; # ne estas vera fako

$revo_baz=$config{"vortaro_pado"};
$fx_prefix = "$revo_baz/tez/fxs_";
$tz_prefix = "$revo_baz/tez/tz_";
$smb_dos = '../smb';
$tmp_file = '/tmp/'.$$.'voko.inx';
$ref_pref='../art';

$tezfak=$config{"tezauro_fakoj"};
$tezrad=$config{"tezauro_radikoj"};
$dos=$config{"rilato_dosiero"};

%smb = ('vid' => '&#x2192;',
	'sin' => '&#x21d2;',
	'ant' => '&#x21cf;',
	'sub' => '&#x2199;', #'&#x2283;',
	'super' => '&#x2197;', #'&#x2282;',
	'prt' => '&#x2199;', #'&#x220b;',
	'malprt' => '&#x2197;', #'&#2208;',
	'dif' => '=');

%img = ('vid' => 'vid.gif',
	'sin' => 'sin.gif',
	'ant' => 'ant.gif',
	'sub' => 'sub.gif', 
	'super' => 'super.gif',
	'prt' => 'sub.gif',
	'malprt' => 'super.gif',
	'dif' => 'dif.gif');

die "Ne ekzistas dosierujo \"$dos\""
  unless -f $dos;

# XML-analizo
print "Analizas \"$dos\"...\n" if ($verbose);

my $parser = new XML::Parser(ParseParamEnt => 1,
			     ErrorContext => 2,
			     Handlers => {
				 Start => \&start_handler,
				 End   => \&end_handler,
				 Char  => \&char_handler}
			     );

eval { $parser->parsefile("$dos") }; warn $@ if ($@);
print "\n";

# kompletigi la referencojn ambaudirekte

complete_refs();

# elkalkuli altecojn kaj ero-nombrojn

cnt_and_depth();
#dump_cnt_dep();

# faru la fakindeksojn kaj noddosierojn

create_tz();
create_fx();


if ($debug) {
    print "\n";
    start_loop();
}

################## traktantoj de XML-analiz-eventoj ################
 
sub char_handler {
    my ($xp, $text) = @_;

    if  ($text = $xp->xml_escape($text)) {
	$kap .= $text if ($xp->in_element('kap'));
	$uzo .= $text if ($xp->in_element('uzo'));
    }
} 

sub start_handler {
    my ($xp,$el,@attrs) = @_;
    my $attr;

    if ($el eq 'art') 
    {

	print '.' if ($show_progress);
	print "\n" if ($show_progress and ($art_no++ % 80 == 0));

	$art_mrk = get_attr('mrk',@attrs);
	$art_kap = ();
	@art_uzo = ();
	@art_dif = ();
	@art_sin = ();
	@art_ant = ();
	@art_vid = ();
	@art_super = ();
	@art_sub = ();
	@art_prt = ();
	@art_malprt = ();
	$art_subart = 0;
    }
    elsif ($el eq 'subart')
    {
	++$art_subart;
	$subart_snc = 0;
    }
    elsif ($el eq 'drv') 
    {
	$drv_mrk = get_attr('mrk',@attrs);
	$drv_kap = ();
	@drv_uzo = ();
	@drv_dif = ();
	@drv_sin = ();
	@drv_ant = ();
	@drv_vid = ();
	@drv_super = ();
	@drv_sub = ();
	@drv_prt = ();
	@drv_malprt = ();
	$drv_snc = 0;
    }
    elsif ($el eq 'snc') 
    {
	if ($xp->in_element('drv')) {
	    ++$drv_snc;
	    unless ($snc_mrk = get_attr('mrk',@attrs)) {
		$snc_mrk = $drv_mrk.".".$drv_snc;
	    };
	    $snc_kap = $drv_kap." ".$drv_snc;
	} elsif ($xp->in_element('subart')) {
	    ++$subart_snc;
	    unless ($snc_mrk = get_attr('mrk',@attrs)) {
		$snc_mrk = $art_mrk.".".$romiaj[$art_subart].".".$subart_snc;
	    }
	    $snc_kap = $art_kap." ".$romiaj[$art_subart]." ".$subart_snc;
	} else {
	    warn "KOREKTU PROGRAMON: Senco nek ene de drv nek ene de subart".
		"($art_kap)!\n";
	}
	@snc_uzo = ();
	@snc_dif = ();
	@snc_sin = ();
	@snc_ant = ();
	@snc_vid = ();
	@snc_super = ();
	@snc_sub = ();
	@snc_prt = ();
	@snc_malprt = ();
	$snc_subsnc = 0;
    }
    elsif ($el eq 'subsnc') 
    {
	$snc_subsnc++;
	unless ($subsnc_mrk = get_attr('mrk',@attrs)) {
	    $subsnc_mrk = $snc_mrk.".".chr(ord('a')+$snc_subsnc-1);
	};
	$subsnc_kap = $drv_kap." ".$drv_snc.chr(ord('a')+$snc_subsnc-1);
	@subsnc_uzo = ();
	@subsnc_dif = ();
	@subsnc_sin = ();
	@subsnc_ant = ();
	@subsnc_vid = ();
	@subsnc_super = ();
	@subsnc_sub = ();
	@subsnc_prt = ();
	@subsnc_malprt = ();
    }
    elsif ($el eq 'ref')
    {
	my $tip = get_attr('tip',@attrs);
	$tip = 'vid' unless
	    (($tip eq 'dif') or ($tip eq 'sin') or ($tip eq 'ant') or
	    ($tip eq 'sub') or ($tip eq 'super') or
	    ($tip eq 'prt') or ($tip eq 'malprt'));
	push @{$xp->current_element()."_".$tip}, (get_attr('cel',@attrs));

#	    print $xp->current_element()."_".$tip, ": ",
#	          @{$xp->current_element()."_".$tip}, "\n" if ($debug);

	
    }
    elsif ($el eq 'uzo') 
    {
	$uzo = '';
    }
    elsif ($el eq 'kap') 
    {
	$kap = '';
    }
}

sub end_handler {
    my ($xp, $el) = @_;

    if ($el eq 'kap') {
	$kap =~ s/^\s+//; $kap =~ s/\s+$//; 
	${$xp->current_element()."_kap"} = $kap;
    }
    elsif ($el eq 'uzo') {
	push @{$xp->current_element()."_uzo"}, ($uzo);
    }
    elsif (($el eq 'subsnc') or ($el eq 'snc') or
	   ($el eq 'drv') or ($el eq 'art'))
    {
	add_entry($el);
    }

    # se temas pri nur unu snc, metu ties informojn en drv
    if (($el eq 'drv') and ($drv_snc == 1)) {
	append_entry('drv','snc');
	delete_entry('snc');
    }
}

sub attr_str {
    my $result='';

    while (@_) {
	my $attr_name = shift @_;
	my $attr_val  = shift @_;
	if (($attr_name eq 'mrk') and ($attr_val =~/^\$Id/)) {
	    $attr_val =~ s/^\044Id:\s+([^,\.]+)\.xml,v.*\044$/$1/;
	}
	$result .= " $attr_name=\"$attr_val\"";
    }

    return $result;
}

sub get_attr {
    my($attr_name,@attr_list)=@_;

    while (@attr_list) {
        if (shift @attr_list eq $attr_name) { 
	    return shift @attr_list 
	    };
    };
    return ''; # atributo ne trovita;
};           

sub add_entry {
    my $el = shift;

    my %entry = ();

    # kopiu chion el {$el}_mrk, {$el}_kap ktp. al %entry
    $entry{'mrk'} = ${$el.'_mrk'};
    $entry{'kap'} = ${$el.'_kap'};

    foreach $a ('uzo','dif','sin','ant','vid','super','sub','prt','malprt') {
      my @array = @{$el.'_'.$a};
      $entry{$a} = \@array;
    }

    # aldonu %entry al vortlisto
    $wordlist{${$el.'_mrk'}} = \%entry;
}

sub append_entry {
    my $to = shift;
    my $from = shift;

    my $entry = $wordlist{${$to.'_mrk'}};

    foreach $a ('uzo','dif','sin','ant','vid','super','sub','prt','malprt') {
	push @{$entry->{$a}}, @{$from.'_'.$a};
    }
}

sub delete_entry {
    my $el = shift;

    delete $wordlist{${$el.'_mrk'}};
}

#################### plektado de la vortreto ##################


sub complete_refs {

    my $mrk;
    my $entry;

    # trakuras $wordlist kaj faras chiujn referencojn duflanke
    # krome shanghas la referencojn de signovicoj al memormontriloj
    # pro pli granda rapideco

    while (($mrk,$entry) = each %wordlist) {
	print '+' if ($show_progress);
	print "\n" if ($show_progress and ($art_no++ % 80 == 0));

	print "$mrk\n" if ($debug);

	cmpl_refs_aux($entry,'sin',$entry->{'dif'}); # 'dif' alidirekte estu 'sin'!
	cmpl_refs_aux($entry,'sin',$entry->{'sin'});
	cmpl_refs_aux($entry,'ant',$entry->{'ant'});
	cmpl_refs_aux($entry,'vid',$entry->{'vid'}); 
	cmpl_refs_aux($entry,'sub',$entry->{'super'});
	cmpl_refs_aux($entry,'super',$entry->{'sub'});
	cmpl_refs_aux($entry,'prt',$entry->{'malprt'});
	cmpl_refs_aux($entry,'malprt',$entry->{'prt'});
    }
    print "\n" if ($show_progress);
}

sub cmpl_refs_aux {
    my $near = shift;
    my $reftype = shift;
    my $refs = shift;

    for ($i = 0; $i < scalar @$refs; $i++) { 

	$word = @$refs->[$i];

	unless (ref($word) eq "HASH") {
	    
	    # la referencita vorto
	    my $distant=$wordlist{$word};
	    unless ($distant) {
		warn "\nAVERTO: \"$word\" ne ekzistas (".$near->{'mrk'}.").\n";
		splice @$refs, $i, 1; $i--;
		next;
	    }
	    
#	    unless ($reftype eq 'vid') {
		# se la vorto "word" ankorau ne trovighas
		# en la listo de la referencita vorto, enmetu
		# la retroreferencon
		unless (map { 
		    (ref($_) eq "HASH" ? $near == $_ : $near->{'mrk'} eq $_)?
		      1:() 
		      }
			@{$distant->{$reftype}}) 
		{
		    push @{$distant->{$reftype}}, ($near);
		}
#	    }

	    # anstatauigu la signovicon "word" per montrilo al ghi
	    @$refs->[$i] = $distant;
	}
    }
}

# indikas che chiu nodo la nombron de eroj kaj la
# altecon (maksimuma distanco al folia nodo)
# por tio la algoritmo eltrovas por chiu nodo
# la patrajn nodojn kaj donas al ili poenton (por si mem)
# krome ghi indikas che chiu gepatro la distancon al si
# mem, se tiu estas pli granda ol la ghisnuna maksimuma
# tiea distanco

sub cnt_and_depth {

    while (($mrk,$entry) = each %wordlist) {
       
	# notu chiujn patrojn kune kun distanco de tie chi
	# se iu okazas plurfoje notu la pli grandan distancon
	# cirklo perfidighas, se mi mem aperas kiel supernocio

	my $dist = 1;
	my @p1 = (@{$entry->{'super'}},@{$entry->{'malprt'}});
	my %all_parents = ();

	while (@p1) {

	    my @p2 = ();
	    for $v (@p1) {
		# ekskludu cirklojn
		if ($v == $entry) {
		    warn "FIIII! Estas cirklo inter \"$mrk\" kaj "
			.$v->{'mrk'}."\"\n";
		    next;
		}
                # se ne jam en la listo, traktu ankau ties patrojn
		#if (not exist $all_parents{$v}) {
		push @p2,(@{$v->{'super'}},@{$v->{'malprt'}});
		#}
		# difinu/plialtigu distancon
		$all_parents{$v->{'mrk'}} = $dist;

	    }

	    # sekva shtupo
	    $dist++;
	    @p1 = @p2;
	}

	# nun ni havas chiujn patrojn kun la distancoj
	# lau tio ni povas aktualigi ties altecon kaj
	# plialtigi ero-nombron je 1
	while (($mrk,$d) = each %all_parents) {
	    my $v = $wordlist{$mrk};
	    if ($v->{'h'} < $d) { 
		$v->{'h'} = $d;
	    }
	    $v->{'c'}++;
	}
    }
}

sub dump_cnt_dep {
    my @root = sort {$a->{'mrk'} cmp $b->{'mrk'}} root([values %wordlist]);

    for $v (@root) {
	print $v->{'mrk'}.": ".$v->{'h'}.", ".$v->{'c'}."\n";
    }
    
}

sub fakroot {
    my $list = shift;
    my $fako = shift;
    my @root = ();
    my $entry;

    foreach $entry (@$list) {

	if (in_list($fako,$entry->{'uzo'}) and # vorto apartenas al fako
	    not (map {  # ne estas supernocio de l'fako
		in_list($fako,$_->{'uzo'})?1:()
		} @{$entry->{'super'}}) and
	    not (map {  # ne estas ujonocio de l'fako
		in_list($fako,$_->{'uzo'})?1:()
		} @{$entry->{'malprt'}}) and
	    ( @{$entry->{'sub'}} or # vorto havas subnociojn, do ne izolita
	      @{$entry->{'prt'}} )) 
	{
	    push @root,($entry);
	};
    }

    return @root;
}

sub root {
    my $list = shift;
    my @root = ();
    my $entry;

    foreach $entry (@$list) {

	if (not @{$entry->{'super'}} and # vorto ne havas supernociojn
	    not @{$entry->{'malprt'}} and
		( @{$entry->{'sub'}} or # vorto havas subnociojn, do ne izolita
		  @{$entry->{'prt'}}
		  )
	    ) 
	{
	    push @root,($entry);
	};
    }

    return @root;
}


sub in_list {
    my $what=shift;
    my $list=shift;

    return (map {$_ eq $what? 1:()} @$list);
}

#################### HTML-eligo de la indeksoj ############
	

sub html_tree {
    my $list = shift;
    local @subs = ();
    my $cnt;

#  sub ordigu {
#    my $list = shift;

#    return sort {$a->{'mrk'} cmp $b->{'mrk'}} @$list;
#  }

  sub ero {
    my $list = shift;
    my $tip = shift;

    for $v ( sort {$a->{'mrk'} cmp $b->{'mrk'}} @$list ) {
	
	print
	    "<a href=\"".tez_link($v)."\">",
	    "<img src=\"../smb/$img{$tip}\" alt=\"$smb{$tip}\" border=0>",
	    "</a>\n";
	if ($v->{'h'}*$v->{'c'}>$tez_lim) { print "<b>"; }
	print
	    "<a href=\"".word_ref($v)."\" target=\"precipa\">",
	    $v->{'kap'}."</a>";
	if ($v->{'h'}*$v->{'c'}>$tez_lim) { print "</b>"; }
	print "\n<br>\n";

	unless ($tip eq 'super' or $tip eq 'malprt'
		or $tz_files{tez_file($v)}) {
	    push @subs, ($v);
	}
    }
    print "<p>\n";
  }

    return unless (@$list);

    foreach $entry (@$list) { 
	@subs = ();

	my $word_mrk = $entry->{'mrk'};
	my $target_file = tez_file($entry);

	#print "$target_file..." if ($verbose);
	$tz_files{$target_file} = 1;

	open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
	select OUT;
	
	header("tezaŭro: ".$word->{'kap'});
	linkbuttons();

	print "<p>\n";
	if (@{$entry->{'uzo'}}) {
	    for $fak (sort @{$entry->{'uzo'}}) {
		# eble testu antaue, chu la fako havas tezauran indekson
		print "<a href=\"fxs_".lc($fak).".html\">";
		print "<img src=\"../smb/$fak.gif\" alt=\"$fak\" border=0>";
		print "</a>\n";
	    }
	   # print "<p>\n";
	}

	# la vorto
	print "<h1><a href=\"".word_ref($entry)."\" target=\"precipa\">";
	print $entry->{'kap'};
	print "</a></h1>\n";
	
        # la supernocioj
	if (@{$entry->{'super'}}) {
	    print "<i class=griza>speco de</i><br>\n";

	    ero($entry->{'super'},'super');
#	    for $v (ordigu($entry->{'super'})) {
#		print 
#		    "<a href=\"".tez_link($v)."\">",
#		    "<img src=\"../smb/super.gif\" alt=\"".$smb{'super'}."\" border=0>",
#		    "</a>\n";
#		print "<a href=\"".word_ref($v)."\" target=\"precipa\">"
#		    .$v->{'kap'}."</a>";
#		print "<br>\n";
#	    }
#	    print "<p>\n";
	}

        # la tutoj
	if (@{$entry->{'malprt'}}) {
	    print "<i class=griza>parto de</i><br>\n";
	    ero($entry->{'malprt'},'malprt');
#	    for $v (ordigu($entry->{'malprt'})) {
#		print
#		"<a href=\"".tez_link($v)."\">",
#		"<img src=\"../smb/super.gif\" alt=\"".$smb{'super'}."\"  border=0>",
#		"</a>\n";
#		print "<a href=\"".word_ref($v)."\" target=\"precipa\">"
#		    .$v->{'kap'}."</a>";
#		print "<br>\n";
#	    }
#
#	   print "<p>\n"; 
	}

        # la difino
	if (@{$entry->{'dif'}}) {
	    print "<i class=griza>difinito</i><br>\n";
	    ero($entry->{'dif'},'dif');
#	    for $v (ordigu($entry->{'dif'})) {
#		print
#		"<a href=\"".tez_link($v)."\">",
#		"<img src=\"../smb/dif.gif\" alt=\"=\" border=0>",
#		"</a>\n";
#
#		print "<a href=\"".word_ref($v)."\" target=\"precipa\">"
#		    .$v->{'kap'}."</a>\n";
#		
#		unless ($tz_files{tez_file($v)}){ # se ne jam ekzistas
#		#	or not ekzistas_referencoj($v)) { # estos iu enhavo
#		    push @subs, ($v)};
#		print "<br>\n";
#	    }
#	    print "<p>\n";
	} 


	# la sinonimoj
	if (@{$entry->{'sin'}}) {
	    print "<i class=griza>sinonimoj</i><br>\n";
	    ero($entry->{'sin'},'sin');
#	    for $v (ordigu($entry->{'sin'})) {
#		print
#		"<a href=\"".tez_link($v)."\">",
#		"<img src=\"../smb/sin.gif\"  alt=\"".$smb{'sin'}."\" border=0>",
#		"</a>\n";
#
#		print "<a href=\"".word_ref($v)."\" target=\"precipa\">"
#		    .$v->{'kap'}."</a>\n";
#		
#		unless ($tz_files{tez_file($v)}){ # se ne jam ekzistas
#		    push @subs, ($v)};
#		print "<br>\n";
#	    }
#	    print "<p>\n";
	} 

	# la antonimoj
	if (@{$entry->{'ant'}}) {
	    print "<i class=griza>antonimoj</i><br>\n";
	    ero($entry->{'ant'},'ant');
#	    for $v (ordigu($entry->{'ant'})) {
#		print
#		"<a href=\"".tez_link($v)."\">",
#		"<img src=\"../smb/ant.gif\"  alt=\"".$smb{'ant'}."\" border=0>",
#		"</a>\n";
#		print "<a href=\"".word_ref($v)."\" target=\"precipa\">"
#		    .$v->{'kap'}."</a>\n";
#		
#		unless ($tz_files{tez_file($v)}){ # se ne jam ekzistas
#		    push @subs, ($v)};
#
#		print "<br>\n";
#	    }
#	    print "<p>\n";
	}

	# la subnocioj
	if (@{$entry->{'sub'}}) {
	    print "<i class=griza>specoj</i><br>\n";
	    ero($entry->{'sub'},'sub');
#	    for $v (ordigu($entry->{'sub'})) {
#		print
#		"<a href=\"".tez_link($v)."\">",
#		"<img src=\"../smb/sub.gif\"  alt=\"".$smb{'sub'}."\" border=0>",
#		"</a>\n";
#		print "<a href=\"".word_ref($v)."\" target=\"precipa\">"
#		    .$v->{'kap'}."</a>\n";
		

#		unless ($tz_files{tez_file($v)}){ # se ne jam ekzistas
#		    push @subs, ($v)};

#		print "<br>\n";
#	    }
#	    print "<p>\n";
	}

        # la partoj
	if (@{$entry->{'prt'}}) {
	    print "<i class=griza>partoj</i><br>\n";
	    ero($entry->{'prt'},'prt');
#	    for $v (ordigu($entry->{'prt'})) {
#		print
#		"<a href=\"".tez_link($v)."\">",
#		"<img src=\"../smb/sub.gif\"  alt=\"".$smb{'sub'}."\" border=0>",
#		"</a>\n";

#		print "<a href=\"".word_ref($v)."\" target=\"precipa\">"
#		    .$v->{'kap'}."</a>\n";

#		unless ($tz_files{tez_file($v)}){ # se ne jam ekzistas
#		    push @subs, ($v)};
#
#		print "<br>\n";
#	    }
#	    print "<p>\n";
	}

	# vidu ankau
	if (@{$entry->{'vid'}}) {
	    print "<i class=griza>vidu</i><br>\n";
	    ero($entry->{'vid'},'vid');
#	    for $v (ordigu($entry->{'vid'})) {
#		print
#		"<a href=\"".tez_link($v)."\">",
#		"<img src=\"../smb/vid.gif\"  alt=\"".$smb{'vid'}."\" border=0>",
#		"</a>\n";
#		print "<a href=\"".word_ref($v)."\" target=\"precipa\">"
#		    .$v->{'kap'}."</a>";

#		unless ($tz_files{tez_file($v)}){ # se ne jam ekzistas
#		    push @subs, ($v)};
#		print "<br>\n";
#	    }
#	    print "<p>\n";
	}
        
	footer();
	
	close OUT;
	select STDOUT;
	diff_mv($tmp_file,$target_file);

	# tezauro-dosieroj por la subnocioj
#	$entry->{'cnt'} =
	html_tree(\@subs);
#	$cnt += $entry->{'cnt'} + 1; # chiuj suberoj + 1 por la ero mem

#	if ($debug) {
#	    warn $entry->{'mrk'}.", valoro: $cnt\n";
#	}

    }

    return $cnt;
    
}

sub ekzistas_referencoj {
    my $word = shift;

    return @{$word->{'sin'}} or @{$word->{'ant'}} or @{$word->{'vid'}}
    or @{$word->{'sub'}} or @{$word->{'prt'}}
}

sub word_ref {
    my $entry = shift;
    my $ref;

#    print STDERR ">>> ",$entry->{'mrk'},"\n" if ($debug);

    $entry->{'mrk'} =~ /^([^.]+)(\..*)?$/;
    $ref = "$ref_pref/$1.html"; $ref .= "#$1$2" if ($2);

    return $ref;
}

sub tez_file {
    my $entry = shift;
    
    my $mrk = $entry->{'mrk'};
    $mrk =~ tr/./_/;
    return "$tz_prefix".$mrk.".html";
}

sub tez_link {
    my $entry = shift;
    
    my $mrk = $entry->{'mrk'};
    $mrk =~ tr/./_/;
    return "tz_$mrk.html";
}

sub read_cfg {
    $cfgfile = shift;
    my %hash = ();

    open CFG, $cfgfile 
	|| die "Ne povis malfermi dosieron \"$cfgfile\": $!\n";

    while ($line = <CFG>) {
	if ($line !~ /^#|^\s*$/) {
	    $line =~ /^([^=]+)=(.*)$/;
	    $hash{$1} = $2;
	}
    }
    close CFG;
    return %hash;
}

sub create_fx {
    foreach $fako (sort keys %fakoj) {

	my $target_file = "$fx_prefix".lc($fako).".html";
	#print "$target_file..." if ($verbose);

	my @root = fakroot([values %wordlist],$fako);
	unless (@root) {
	    #print "neniuj radikaj nocioj\n"
	    #	if ($verbose);
	    unlink "$target_file";
	    next;
	}
	print STDERR join(' ',map {$_->{'mrk'}} @root), "\n" if ($debug);
	push @uzataj_fakoj, ($fako);

	open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
	select OUT;

	header($fako);
	linkbuttons();
	print
	    "<a href=\"../inx/fx_".lc($fako).".html\">alfabete</a> ",
	    "<b>strukture</b>\n<h1>$fakoj{$fako} strukture...</h1>\n";

	foreach $entry ( sort {$a->{'mrk'} cmp $b->{'mrk'}} @root ) {
	    print 
		"<a href=\"".tez_link($entry)."\">",
		"<img src=\"../smb/vid.gif\"   alt=\"".$smb{'vid'}."\" border=0></a>\n";
	    
	    if ($entry->{'h'}*$entry->{'c'}>$tez_lim) { print "<b>"; }
	    print
	        "<a href=\"".word_ref($entry)."\" target=\"precipa\">",
	        $entry->{'kap'}."</a>";
		#" (".($entry->{'h'}*$entry->{'c'}).")";
	    if ($entry->{'h'}*$entry->{'c'}>$tez_lim) { print "</b>"; }
	    print "<br>\n";
	}

	footer();

	close OUT;
	select STDOUT;
	diff_mv($tmp_file,$target_file);
    }

    # kreu la liston de chiuj fakoj kun strukturaj indeksoj
    print "$tezfak...\n" if ($verbose);

    open OUT,">$tezfak" or die "Ne povis krei $tezfak: $!\n";
    select OUT;

    foreach $fako (sort @uzataj_fakoj) { 
	print "../tez/fxs_".lc($fako).".html;$fako\n"; 
    }
    close OUT;
    select STDOUT;
}

sub create_tz {
    my @root = sort {$a->{'mrk'} cmp $b->{'mrk'}} root([values %wordlist]);
    print STDERR join(' ',map {$_->{'mrk'}} @root), "\n" if ($debug);
    
    unless (@root) {
	print "neniuj radikaj nocioj\n"
	    if ($verbose);
	exit;
    }
    
    html_tree(\@root);

    # forigu chiujn dosierojn ne plu aktualajn
    foreach $file (glob("$tz_prefix*")) {
	unless ($tz_files{$file}) {
	    print "forigas $file\n";
	    unlink($file);
	}
    }

    # kreu la liston de chiuj tezauraj radikoj
    print "$tezrad...\n" if ($verbose);

    open OUT,">$tezrad" or die "Ne povis krei $tezrad: $!\n";
    select OUT;

    foreach $word (@root) {
	my $word_mrk = $word->{'mrk'};
	$word_mrk =~ tr/./_/;
	print "../tez/tz_".$word_mrk.".html;".$word->{'kap'}.";"
	    .($word->{'h'}*$word->{'c'})." \n";
    }
    close OUT;
    select STDOUT;
}


sub diff_mv {
    my ($newfile,$oldfile) = @_;

    if ((! -e $oldfile) or (`diff -q $newfile $oldfile`)) {
	print "$oldfile\n" if ($verbose);
	`mv $newfile $oldfile`;
    } else {
	#print "(senshanghe)\n" if ($verbose);
	unlink($newfile);
    }
};


sub linkbuttons {
    print 

	"<script src=\"../smb/butonoj.js\"></script>\n",
	"<a href=\"../inx/_eo.html\" onMouseOver=\"highlight(0)\" ",
	"onMouseOut=\"normalize(0)\">",
	"<img src=\"../smb/nav_eo1.png\" alt=\"[Esperanto]\" border=0></a>\n",
	"<a href=\"../inx/_lng.html\" onMouseOver=\"highlight(1)\" ",
	"onMouseOut=\"normalize(1)\">",
	"<img src=\"../smb/nav_lng1.png\" alt=\"[Lingvoj]\" border=0></a>\n",
	"<a href=\"../inx/_fak.html\" onMouseOver=\"highlight(2)\" ",
	"onMouseOut=\"normalize(2)\">",
	"<img src=\"../smb/nav_fak1.png\" alt=\"[Fakoj]\" border=0></a>\n",
	"<a href=\"../inx/_ktp.html\" onMouseOver=\"highlight(3)\" ",
	"onMouseOut=\"normalize(3)\">",
	"<img src=\"../smb/nav_ktp1.png\" alt=\"[ktp.]\" border=0></a>\n",
	"<br>";
}


sub header {
    my $titolo = shift;

    print
	"<html>\n<head>\n<meta http-equiv=\"Content-Type\" ".
	"content=\"text/html; charset=UTF-8\">\n".
	"<title>$titolo</title>\n".
	"<link title=\"indekso-stilo\" type=\"text/css\" ".
	"rel=stylesheet href=\"../stl/indeksoj.css\">\n".
	"</head>\n<body>\n";
}



sub footer {
    print "</body>\n</html>\n";
}

################### sencimigaj funkcioj ###############

sub start_loop {

    while (1) {
	print ">";
	my $mrk = <STDIN>;

#	print "\n",join(', ',%{$wordlist{$mrk}}),"\n";

	print eval $mrk;
    }
}

sub match {
    my $what=shift;

    print join(' ',grep /^$what/, (keys %wordlist)), "\n";
    
}

sub show {
    my $what=shift;
    
    my $entry = $wordlist{$what};
    
    unless ($entry) {
	print "ne difinita\n";
	return;
    }

    print "kap   : ", $$entry{'kap'}, "\n";
    print "uzo   : ", join(' ',@{$entry->{'uzo'}}), "\n";
    print "dif   : ", join(' ',@{$entry->{'sin'}}), "\n";
    print "sin   : ", join(' ',@{$entry->{'sin'}}), "\n";
    print "ant   : ", join(' ',@{$entry->{'ant'}}), "\n";
    print "super : ", join(' ',@{$entry->{'super'}}), "\n";
    print "sub   : ", join(' ',@{$entry->{'sub'}}), "\n";
    print "prt   : ", join(' ',@{$entry->{'prt'}}), "\n";
    print "malprt: ", join(' ',@{$entry->{'malprt'}}), "\n";
}

#################################################
