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
$fx_prefix = "$revo_baz/inx/fxs_";
$tz_prefix = "$revo_baz/inx/tz_";
$smb_dos = '../smb';
$tmp_file = '/tmp/'.$$.'voko.inx';
$ref_pref='../art';

$tezfak=$config{"tezauro_fakoj"};
$tezrad=$config{"tezauro_radikoj"};
$dos=$config{"rilato_dosiero"};

%smb = ('vid' => '&#x2192;',
	'sin' => '&#x21d2;',
	'ant' => '&#x21cf;',
	'sub' => '&#x2283;',
	'super' => '&#x2282;',
	'prt' => '&#x220b;',
	'malprt' => '&#2208;');

die "Ne ekzistas dosierujo \"$dos\""
  unless -f $dos;

# XML-analizo

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

# faru la fakindeksojn

create_fx();
create_tz();


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
	@art_super = ();
	@art_sub = ();
	@art_prt = ();
	@art_malprt = ();
    }
    elsif ($el eq 'drv') 
    {
	$drv_mrk = get_attr('mrk',@attrs);
	$drv_kap = ();
	@drv_uzo = ();
	@drv_dif = ();
	@drv_sin = ();
	@drv_ant = ();
	@drv_super = ();
	@drv_sub = ();
	@drv_prt = ();
	@drv_malprt = ();
	$drv_snc = 0;
    }
    elsif ($el eq 'snc') 
    {
	++$drv_snc;
	unless ($snc_mrk = get_attr('mrk',@attrs)) {
	    $snc_mrk = $drv_mrk.".".$drv_snc;
	};
	$snc_kap = $drv_kap." ".$drv_snc;
	@snc_uzo = ();
	@snc_dif = ();
	@snc_sin = ();
	@snc_ant = ();
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
	    $subsnc_mrk = $snc_mrk.".".chr(ord('a')+$snc_subsnc);
	};
	$subsnc_kap = $drv_kap." ".$drv_snc.$snc_subsnc;
	@subsnc_uzo = ();
	@subsnc_dif = ();
	@subsnc_sin = ();
	@subsnc_ant = ();
	@subsnc_super = ();
	@subsnc_sub = ();
	@subsnc_prt = ();
	@subsnc_malprt = ();
    }
    elsif ($el eq 'ref')
    {
	my $tip = get_attr('tip',@attrs);
	if (($tip eq 'dif') or ($tip eq 'sin') or ($tip eq 'ant') or
	    ($tip eq 'sub') or ($tip eq 'super') or
	    ($tip eq 'prt') or ($tip eq 'malprt')) {
	    push @{$xp->current_element()."_".$tip}, (get_attr('cel',@attrs));

#	    print $xp->current_element()."_".$tip, ": ",
#	          @{$xp->current_element()."_".$tip}, "\n" if ($debug);

	} 
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

    $entry{'mrk'} = ${$el.'_mrk'};
    $entry{'kap'} = ${$el.'_kap'};

    foreach $a ('uzo','dif','sin','ant','super','sub','prt','malprt') {
      my @array = @{$el.'_'.$a};
      $entry{$a} = \@array;
    }

    $wordlist{${$el.'_mrk'}} = \%entry;
}

sub append_entry {
    my $to = shift;
    my $from = shift;

    my $entry = $wordlist{${$to.'_mrk'}};

    foreach $a ('uzo','dif','sin','ant','super','sub','prt','malprt') {
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

    # noto: momente tiu shangho al montrilo ankorau ne okazas
    #  pro tio ankau jhus faritaj referencoj estas denove testataj
    #  en la alia direkto.

    while (($mrk,$entry) = each %wordlist) {
	print '+' if ($show_progress);
	print "\n" if ($show_progress and ($art_no++ % 80 == 0));

	print "$mrk\n" if ($debug);

	cmpl_refs_aux($entry,'sin',$entry->{'dif'}); # 'dif' alidirekte estu 'sin'!
	cmpl_refs_aux($entry,'sin',$entry->{'sin'});
	cmpl_refs_aux($entry,'ant',$entry->{'ant'});
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

	    # anstatauigu la signovicon "word" per montrilo al ghi
	    @$refs->[$i] = $distant;
	}
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

#################### tekst-eligo (neuzata nun) ###############

sub tree {
    my $list = shift;
    my $fako = shift;
    my $max_depth = shift;

    foreach $entry (sort {$a->{'mrk'} cmp $b->{'mrk'}} @$list) {
	print " " x (2*(5-$max_depth)), ($entry->{'kap'}), "\n";
	if ($max_depth > 1) {
	    tree($entry->{'sub'},$fako,$max_depth-1);
	}
    }
}

#################### HTML-eligo de la indeksoj ############
	
sub html_tree_fako_dl { # fako momente ignorata, dependas de la radiko
    my $list = shift;
    my $fako = shift;
#    my $reftype = shift;
    my $max_depth = shift;
    my $depth = shift || 0;
    my $symbol = shift || '';

    return unless (@$list);

#    print STDERR join(' ',@$list), "\n" if ($debug);

    print "<dl>\n";

    foreach $entry (sort {$a->{'mrk'} cmp $b->{'mrk'}} @$list) {

#	next unless (in_list($fako,$entry->{'uzo'}));
	
	# la vorto
	print "<dt>";
	print "<b>" if ($depth < 1);
	print "<img src=\"$smb_dos/$symbol.gif\" alt=\"$symbol\"> " 
	    if ($symbol);
	print "<a href=\"".word_ref($entry)."\">";
	print $entry->{'kap'};
	print "</a>";
	print "</b>" if ($depth < 1);

	# la sinonimoj
	my @sinonimoj = map {
	    "<img src=\"$smb_dos/sin.gif\" alt=\"sin\"><a href=\"".
		word_ref($_)."\"><i>".$_->{'kap'}."</i></a>";
	} @{$entry->{'sin'}}; 

	# la antonimoj
	my @antonimoj = map {
	    "<img src=\"$smb_dos/ant.gif\" alt=\"sin\"><a href=\"".
		word_ref($_)."\"><i>".$_->{'kap'}."</i></a>";
	} @{$entry->{'ant'}};
	
	push @sinonimoj, @antonimoj;
	if (@sinonimoj) { print " (", join(', ',@sinonimoj), ")" };

	print "</dt>\n";

	# la subvortoj
	if ($depth < $max_depth -1) {
	    print "<dd>\n";
	    html_tree($entry->{'sub'},$fako,$max_depth,$depth+1,'sub');
	    print "</dd>\n";
	}

        # la partoj
	if ($depth < $max_depth -1) {
	    print "<dd>\n";
	    html_tree($entry->{'prt'},$fako,$max_depth,$depth+1,'prt');
	    print "</dd>\n";
	}

    }
    print "</dl>";
}

sub html_tree_fako_pre { # fako momente ignorata, dependas de la radiko
    my $list = shift;
    my $fako = shift;
    my $max_depth = shift;
    my $depth = shift || 0;
    my $symbol = shift || '';

    return unless (@$list);

#    print STDERR join(' ',@$list), "\n" if ($debug);

    print "<pre>\n" if ($depth == 0);

    foreach $entry (sort {$a->{'mrk'} cmp $b->{'mrk'}} @$list) {

#	next unless (in_list($fako,$entry->{'uzo'}));

	# la vorto
	print " " x (2*$depth);
	print "<b>" if ($depth < 1);
	print "$smb{$symbol} " if ($symbol);
	print "<a href=\"".word_ref($entry)."\" target=\"precipa\">";
	print $entry->{'kap'};
	print "</a>";
	print "</b>" if ($depth < 1);

	# la sinonimoj
	my @sinonimoj = map {
	    $smb{'sin'}.
	    " <a href=\"".word_ref($_)."\" target=\"precipa\"><i>"
	    .$_->{'kap'}."</i></a>";
	} @{$entry->{'sin'}}; 

	# la antonimoj
	my @antonimoj = map {
	    $smb{'ant'}.
	    " <a href=\"".word_ref($_)."\" target=\"precipa\"><i>"
	    .$_->{'kap'}."</i></a>";
	} @{$entry->{'ant'}};
	
	push @sinonimoj, @antonimoj;
	if (@sinonimoj) { print " (", join(', ',@sinonimoj), ")" };

	print "\n";

	# la subvortoj
	if ($depth < $max_depth -1) {
	    html_tree_fako_pre($entry->{'sub'},$fako,$max_depth,$depth+1,'sub');
	}

        # la partoj
	if ($depth < $max_depth -1) {
	    html_tree_fako_pre($entry->{'prt'},$fako,$max_depth,$depth+1,'prt');
	}

    }
    print "</pre>" if ($depth == 0);
}

sub html_tree_pre {
    my $list = shift;
    my $max_depth = shift;
    my $depth = shift || 0;
    my $symbol = shift || '';

    return unless (@$list);

#    print STDERR join(' ',@$list), "\n" if ($debug);

    print "<pre>\n" if ($depth == 0);

    foreach $entry (sort {$a->{'mrk'} cmp $b->{'mrk'}} @$list) {

	# la vorto
	print " " x (2*$depth);
	print "<b>" if ($depth < 1);
	print "$smb{$symbol} " if ($symbol);
	print "<a href=\"".word_ref($entry)."\" target=\"precipa\">";
	print $entry->{'kap'};
	print "</a>";
	print "</b>" if ($depth < 1);

	# la sinonimoj
	my @sinonimoj = map {
	    $smb{'sin'}.
	    " <a href=\"".word_ref($_)."\" target=\"precipa\"><i>"
	    .$_->{'kap'}."</i></a>";
	} @{$entry->{'sin'}}; 

	# la antonimoj
	my @antonimoj = map {
	    $smb{'ant'}.
	    " <a href=\"".word_ref($_)."\" target=\"precipa\"><i>"
	    .$_->{'kap'}."</i></a>";
	} @{$entry->{'ant'}};
	
	push @sinonimoj, @antonimoj;
	if (@sinonimoj) { print " (", join(', ',@sinonimoj), ")" };

	print "\n";

	# la subvortoj
	if ($depth < $max_depth -1) {
	    html_tree_pre($entry->{'sub'},$max_depth,$depth+1,'sub');
	}

        # la partoj
	if ($depth < $max_depth -1) {
	    html_tree_pre($entry->{'prt'},$max_depth,$depth+1,'prt');
	}

    }
    print "</pre>" if ($depth == 0);
}

sub word_ref {
    my $entry = shift;
    my $ref;

#    print STDERR ">>> ",$entry->{'mrk'},"\n" if ($debug);

    $entry->{'mrk'} =~ /^([^.]+)(\..*)?$/;
    $ref = "$ref_pref/$1.html"; $ref .= "#$1$2" if ($2);

    return $ref;
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
	print "$target_file..." if ($verbose);

	my @root = fakroot([values %wordlist],$fako);
	unless (@root) {
	    print "neniuj radikaj nocioj\n"
		if ($verbose);
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
	    "<a href=\"fx_".lc($fako).".html\">alfabete</a> ".
	    "<b>strukture</b>\n<h1>$fakoj{$fako} strukture...</h1>\n";

	html_tree_fako_pre(\@root,$fako,10);
	footer();

	close OUT;
	select STDOUT;
	diff_mv($tmp_file,$target_file);
    }

    # kreu la liston de chiuj fakoj kun strukturaj indeksoj
    print "$tezfak...\n" if ($verbose);

    open OUT,">$tezfak" or die "Ne povis krei $tezfak: $!\n";
    select OUT;

    foreach $fako (sort @uzataj_fakoj) { print "$fako\n"; }
    close OUT;
    select STDOUT;
}

sub create_tz {
    my @tz_files;
#    foreach $fako (keys %fakoj) {

#	my $target_file = "$tz_prefix"."index.html";

#	print "$target_file...\n" if ($verbose);

	my @root = sort {$a->{'mrk'} cmp $b->{'mrk'}} root([values %wordlist]);
	print STDERR join(' ',map {$_->{'mrk'}} @root), "\n" if ($debug);

	unless (@root) {
	    print "neniuj radikaj nocioj\n"
		if ($verbose);
	    exit;
#	    unlink "$target_file";
#	    next;
	}

	# kreu por chiu radik-vorto HTML-dosieron kun ghia arbo
	foreach $word (@root) {

	    my $word_mrk = $word->{'mrk'};
	    $word_mrk =~ tr/./_/;
	    my $target_file = "$tz_prefix".$word_mrk.".html";
	    print "$target_file..." if ($verbose);
	    push @tz_files, ($target_file);

	    open OUT,">$tmp_file" or die "Ne povis krei $tmp_file: $!\n";
	    select OUT;

	    header("tezaŭro: ".$word->{'kap'}."...");
	    linkbuttons();
	    html_tree_pre([$word],10);
	    footer();

	    close OUT;
	    select STDOUT;
	    diff_mv($tmp_file,$target_file);
	}

        # forigu chiujn dosierojn ne plu aktualajn
        foreach $file (glob("$tz_prefix*")) {
	    unless (in_list($file,\@tz_files)) {
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
	print "tz_".$word_mrk.".html;".$word->{'kap'}."\n";
    }
    close OUT;
    select STDOUT;
}


sub diff_mv {
    my ($newfile,$oldfile) = @_;

    if ((! -e $oldfile) or (`diff -q $newfile $oldfile`)) {
	print "farite\n" if ($verbose);
	`mv $newfile $oldfile`;
    } else {
	print "(senshanghe)\n" if ($verbose);
	unlink($newfile);
    }
};


sub linkbuttons {
    print 

	"<script src=\"../smb/butonoj.js\"></script>\n",
	 "<a href=\"_eo.html\" onMouseOver=\"highlight(0)\" ",
	 "onMouseOut=\"normalize(0)\">",
	 "<img src=\"../smb/nav_eo1.png\" alt=\"[Esperanto]\" border=0></a>\n"),
	 "<a href=\"_lng.html\" onMouseOver=\"highlight(1)\" ",
	 "onMouseOut=\"normalize(1)\">",
	 "<img src=\"../smb/nav_lng1.png\" alt=\"[Lingvoj]\" border=0></a>\n"),
	 "<a href=\"_fak.html\" onMouseOver=\"highlight(2)\" ",
	 "onMouseOut=\"normalize(2)\">",
	 "<img src=\"../smb/nav_fak1.png\" alt=\"[Fakoj]\" border=0></a>\n"),
	 "<a href=\"_ktp.html\" onMouseOver=\"highlight(3)\" ",
	 "onMouseOut=\"normalize(3)\">",
	 "<img src=\"../smb/nav_ktp1.png\" alt=\"[ktp.]\" border=0></a>\n");
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
