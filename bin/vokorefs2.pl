#!/usr/bin/perl -w
#
# voku ekz.
#   vokorefs2.pl [-v] rilatoj.xml 
#
################# komenco de la programo ################

use XML::Parser;

$debug = 1;
$| = 1;

$ref_pref='../revo/art';
$header="<html>\n<head>\n<meta http-equiv=\"Content-Type\" ".
	"content=\"text/html; charset=UTF-8\">\n".
	"<title>strukturita indekso</title>\n",
	"<link title=\"indekso-stilo\" type=\"text/css\" ",
	"rel=stylesheet href=\"../revo/stl/indeksoj.css\">\n",
	"</head>\n<body>\n",
        "<i><a href=\"indeksoj.html\">indeksoj</a></i>\n";
        "<h1>strukturita indekso</h1>\n";
$footer = "</body>\n</html>\n";
$fakcfg = '/home/revo/revo/cfg/fakoj.cfg'; 
$fx_prefix = '/home/revo/tmp/fxs_';

%fakoj = read_cfg($fakcfg);


# analizi la argumentojn

while (@ARGV) {
    if ($ARGV[0] eq '-v') {
	$verbose = 1;
	shift @ARGV;
    } else {
	$dos = shift @ARGV;
    };
};

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

# kompletigi la referencojn ambaudirekte

complete_refs();

# ...

root_super('BOT');

open OUT, '>/home/revo/tmp/bot_sub.html';
select OUT;
print "$header";
html_tree([root([keys %wordlist],'BOT','super')],'BOT','sub',5);
print "$footer";
select STDOUT;
close OUT;

open OUT, '>/home/revo/tmp/bot_prt.html';
select OUT;
print "$header";
html_tree([root([keys %wordlist],'BOT','malprt')],'BOT','prt',5);
print "$footer";
select STDOUT;
close OUT;

print "\n";
#start_loop();


################## traktantoj de analiz-eventoj ################
 
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

	print '.' if ($verbose);
	print "\n" if ($verbose and ($art_no++ % 80 == 0));

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
	print '+' if ($verbose);
	print "\n" if ($verbose and ($art_no++ % 80 == 0));

	cmpl_refs_aux($mrk,'sin',$entry->{'dif'}); # dif alidirkete estu sin!
	cmpl_refs_aux($mrk,'sin',$entry->{'sin'});
	cmpl_refs_aux($mrk,'ant',$entry->{'ant'});
	cmpl_refs_aux($mrk,'sub',$entry->{'super'});
	cmpl_refs_aux($mrk,'super',$entry->{'sub'});
	cmpl_refs_aux($mrk,'prt',$entry->{'malprt'});
	cmpl_refs_aux($mrk,'malprt',$entry->{'prt'});
    }
}

sub cmpl_refs_aux {
    my $mrk = shift;
    my $reftype = shift;
    my $refs = shift;

#    print "$mrk/$reftype: ", join(" ",@$refs), "\n" if ($debug and $mrk eq 'aster.0o');

    for $word (@$refs) {

#	print "x"  if ($debug and $word eq 'aster.0acoj');

	my $entry=$wordlist{$word};
	
	unless ($entry) {
	    warn "\nAVERTO: \"$word\" ne ekzistas.\n";
	    return;
	}
	
	unless (grep /^$mrk$/, @{$entry->{$reftype}}) {
	    push @{$entry->{$reftype}}, ($mrk);

#	    show ($word) if ($debug and $word eq 'aster.0acoj');
	}
    }
}

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

sub root_super {
    my $fako=shift;

    print join(' ',root([keys %wordlist],$fako,'super'));
    print "\n";
}

sub root {
    my $list = shift;
    my $fako = shift;
    my $reftype = shift;
    my $reftype2;
    my @root = ();

    if ($reftype eq 'super') {
	$reftype2 = 'sub';
    } elsif ($reftype eq 'malprt') {
	$reftype2 = 'prt';
    } else {
	warn "Nur 'super' kaj 'malprt' permesita kiel 3a argumento.\n";
	return;
    }

    foreach $word (@$list) {

	my $entry = $wordlist{$word};
	unless ($entry) {
	    warn "\"$word\" ne ekzistas!\n";
	    last;
	}

	if (map {$_ eq $fako} @{$entry->{'uzo'}} and
	    not @{$entry->{$reftype}} and
	    @{$entry->{$reftype2}}) {

		    push @root,($word);
		    
		};
    }

    return @root;
}

sub successors {
    my $word = shift;
#    my $fako = shift;
    my $reftype = shift;

    return @{$wordlist{$word}->{$reftype}};
}

sub tree {
    my $list = shift;
    my $fako = shift;
    my $max_depth = shift;

    foreach $word (sort @$list) {
	print " " x (2*(5-$max_depth)), ($wordlist{$word}->{'kap'} or "[$word]"), "\n";
	if ($max_depth > 1) {
	    tree($wordlist{$word}->{'sub'},$fako,$max_depth-1);
	}
    }
}
	
sub html_tree {
    my $list = shift;
    my $fako = shift;
    my $reftype = shift;
    my $max_depth = shift;
    my $depth = shift || 0;

    return unless ($list);

    print "<dl>\n";

    foreach $word (sort @$list) {

	my $entry = $wordlist{$word};
	
	# la vorto
	print "<dt>";
	print "<u>" if ($depth < 1);
	print "<b>" if ($depth < 2);
	print "<a href=\"".word_ref($word)."\">";
	print ($entry->{'kap'} or "[$word]");
	print "</a>";
	print "</b>" if ($depth < 2);
	print "</u>" if ($depth < 1);

	# la sinonimoj
	my @sinonimoj = map {
	    "<a href=\"".word_ref($_)."\"><i>".
            ($wordlist{$_}->{'kap'} or $_)."</i></a>";
	} @{$entry->{'sin'}}; 
	if (@sinonimoj) { print " (", join(', ',@sinonimoj), ")" };

	print "</dt>\n";

	# la subvortoj
	if ($depth < $max_depth -1) {
	    print "<dd>\n";
	    html_tree($wordlist{$word}->{$reftype},
		      $fako,$reftype,$max_depth,$depth+1);
	    print "</dd>\n";
	}
    }
    print "</dl>";
}

sub word_ref {
    my $word = shift;
    my $ref;

    $word =~ /^([^.]+)(\..*)?$/;
    $ref = "$ref_pref/$1.html"; $ref .= "#$1$2" if ($2);
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
    foreach $fako (keys %fakoj) {
	open OUT, ">$fx_prefix$fako.html";
	select OUT;
	print "$header";
	html_tree([root([keys %wordlist],$fako,'super')],$fako,'sub',5);
	print "$footer";
	select STDOUT;
	close OUT;
    }
}
