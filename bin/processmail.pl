#!/usr/bin/perl -w

# AGENDO:
#   - resendo de respondo al la sendinto
#   - kontrolo pri aktuala versio de la artikolo


# kiom da informoj
$verbose = 1;
$debug = 1;

# dosier(uj)oj
$mail_folder = '/var/spool/mail/revo';
$mail_local  = '/home/revo/tmp/mail';
$old_mail    = '/home/revo/oldmail';
$tmp         = '/home/revo/tmp';
$xml_dir     = '/kde/voko/revo/cvs/revo';
$cvs         = '/usr/bin/cvs';
$editor_file = '/home/revo/etc/redaktoroj';

# programoj
$xmlcheck='/usr/bin/rxp -V';

# aliaj
# je kio rekoni komencon de mesagho
$mail_begin = '^From[^:]';
# sxlosilvortoj en sendita TTT-formularajho
$possible_keys = 'komando|teksto|shangho'; 
# permesitaj komandoj
$commands = 'redakt[oui]|help[oui]'; # .'|dokumento|artikolo|historio|propono'

$revoservo = '[Revo-Servo]';
$signature ="--\nRevo-Servo <revo\@steloj.de>\n"
    ."retposhta servo por redaktantoj de Reta Vortaro.\n";

$vokomail_url = 'http://www.uni-leipzig.de/cgi-bin/vokomail.pl';

####### start

%senditajho = (); # enhavas informojn pri la sendita poshtajho


# chu estas poshto?
if (not -s $mail_folder) {
    print "neniu poshto en $mail_folder\n";
    exit;
};

# shovu la poshtdosieron
`mv $mail_folder $mail_local`;
#open MAIL,">$mail_folder";
#close MAIL;

open MAIL,$mail_local;

while ($mail=readmail(MAIL)) {
	processmail($mail);
};

close MAIL;

# arkivigu la poshtdosieron
$filename = `date +%Y%m%d_%H%M%S`;  
`mv $mail_local $old_mail/$filename`;

########

sub readmail {
	$fh = shift;
	my $mail = '';	
	my $lastpos;
	
	$mail .=<$fh>;

	while (<$fh>) {
		if (/$mail_begin/) {
		    seek($fh,$lastpos,0); # reiru unu linion
		    return $mail;
		} else {
		    $mail .= $_;
		    $lastpos = tell($fh);
		};
	};

	# last mail in file
	return $mail;
}		
		
sub processmail {
    my (%header, %content);
    my ($key, $value);

    print "-" x 60, "\n" if ($verbose);

    # analizu la kapon de la mesagho
    $mail =~ s/^From.*?\n//; # ignoru la unuan linion
    
    # dum unua linio ne estas malplena
    while ($mail !~ /^\s*\n/) {
	# legu la sxlosilvorton kaj reston de la linioj
	if ($mail =~ /^([a-z\-_]+):[ \t]*(.*?)\n/i) {
	    $key=lc($1); $value=$2;
	    $mail =~ s/^.*?\n//;
	    # foje sekvas aldonaj linioj 
	    while ($mail =~ /^[ \t]+([^\s].*?)\n/) {
		$value .= "\n$1";
		$mail =~ s/^.*?\n//;
	    }
	    $header{$key}=$value;
	    print "$key: $value\n" if ($debug);
	} else {
	    $mail =~ s/^(.*?)\n//;
	    warn "kaplinio $1 ne havas ghustan formon\n";
	}
    }

    $senditajho{'senddato'}=$header{'date'};

    print "---\n" if ($debug);

    # kontrolu, chu temas pri redaktoro au helpkrio
    unless ($editor = is_editor($header{'from'})) { 

	# chu temas pri helpkrio
	if ($mail =~ /^\s*help/) {
	    cmd_help($header{'reply-to'} || $header{'from'});

	    print "komando \"helpo\" de $header{'from'}\n" if ($verbose);
	} else {
	    warn "!!! $header{'from'} ne estas redaktoro "
		."nek petas pri helpo !!!\n"
		."\tsubject: $header{'subject'}\n"
		."\tstart of mail: ".substr($mail,0,100)."\n---\n";
	}
	return; # ne respondu al SPAMo
    }

    print "redaktisto: $editor\n";
    $senditajho{'redaktisto'} = $editor;

    # analizu la korpon de la mesagho

    # chu temas pri mesagho sendita de la TTT-formularo?
    if ($header{'content-type'} =~ /^application\/x-www-form-urlencoded/) {

	print "temas pri: mesagho de TTT-formularo\n" if ($debug);
	# mesagho sendita de la TTT-formularo?

	foreach $pair (split ('&',$mail)) {
	    if ($pair =~ /(.*)=(.*)/) {
                ($key,$value) = ($1,$2);
                if ($key =~ /^(?:$possible_keys)$/) {
                    $value =~ s/\+/ /g; # anstatauigu '+' per ' '
                    $value =~ s/%(..)/pack('c',hex($1))/seg;
                    $content{$key} = $value;
                };
	    }
	};           
    } else {

	# normala retmesagho

	print "temas pri: normala mesagho\n" if ($debug);
	if ($mail =~ s/^($commands)[ \t]*\:[ \t]*(.*?)\n//i) {
	    $key = $1;
	    $value = $2;

	    # legu chion ghis malplena linio au "<?xml..."
	    while (($mail !~ /^\s*\n/) and ($mail !~ /^\s*<?xml/i)) {
		$mail =~ s/^[ \t]*(.*?)\n//;
		$value .= $1;
	    }

	    $content{'komando'}=$key;
	    $content{'priskribo'}=$value;
	    
	    # la resto povus esti la artikolo
	    $mail =~ s/^[\s\n]*//;
	    
	    if ($mail) {
		$content{'teksto'} = $mail;
	    }
	} else {
	    error("nekonata komando en la poshtajho");
	    return;
	}

    }

    # procedu lau la enhavo de la mesagho
    my $cmd = $content{'komando'};
    print "komando: $cmd\n" if ($verbose);

    if ($cmd =~ /^help[oui]$/) {
	cmd_hlp($editor);

    } elsif ($cmd =~ /^dokumento/) {
	cmd_dokument($editor,$content{'priskribo'});

    } elsif ($cmd =~ /^redakt[oui]/) {
	cmd_redakt($editor,
		   $content{'shangho'}||$content{'priskribo'},
		   $content{'teksto'});

    } elsif ($cmd =~ /^historio/) {
	cmd_histori($editor,$content{'priskribo'});
	
    } elsif ($cmd =~ /^artikolo/) {
	cmd_artikol($editor,$content{'priskribo'});

    } elsif ($cmd =~ /^propon[oui]/) {
	cmd_propon($editor,
		   $content{'priskribo'},
		   $content{'teksto'});
    } else {
	error($editor, "nekonata komando $cmd");
	return;
    }

#    print "###############################################\n";
    #print $mail;	
#    while (($key,$value) = each %header) {
#	print "$key: $value\n";
#    }

#    print "komando: $content{'komando'}\n";
#    print "shangho: $content{'shangho'}\n";
#    print "teksto: ".substr($content{'teksto'},0,50)."\n";
}	


sub error {
    my $errmsg = shift;
    
    # poste resendu mesaghon al la sendinto, provizore nur avertu
  
    my $mail_addr = $senditajho{'redaktisto'};
    $mail_addr =~ s/.*<([a-z\.\_\-@]+)>.*/$1/;

    my $mail = 
       "Saluton!\n\nKoncerne vian mesaghon de: $senditajho{'senddato'},\n";
    $mail .=
        "artikolo: $senditajho{'artikolo'}\n" if ($senditajho{'artikolo'});
    $mail .=
        "okazis la sekva eraro:\n\n"
       ."$errmsg\n\n"
       ."Bonvolu provi korekti la eraron kaj resendi la mesaghon.\n"
       ."Se vi ne scias solvi la problemon, vi povas turni vin al\n"
       ."<revo\@onelist.com> au <diestel\@steloj.de> por peti helpon.\n"
       .$signature;


    print ">sendas erar-mesaghon al: $mail_addr\n" if ($verbose);
    print $mail if ($debug);

    open SMAIL, "|mail -s\"$revoservo - eraro\" $mail_addr" 
	or die "Ne povas dukti al mail: $!\n";
    print SMAIL $mail;
    close SMAIL;
    
}

sub konfirmo {
    my $msg = shift;

    # poste resendu mesaghon al la sendinto, provizore nur avertu
  
    my $mail_addr = $senditajho{'redaktisto'};
    $mail_addr =~ s/.*<([a-z\.\_\-@]+)>.*/$1/;

    my $mail =
        "Saluton!\n\nVia mesagho de: $senditajho{'senddato'},\n";
    $mail .=
        "artikolo: $senditajho{'artikolo'}\n" if ($senditajho{'artikolo'});
    $mail .=
	"sukcese traktighis:\n\n"
       ."$msg\n\n"
       .$signature;

    print ">sendas konfirm-mesaghon al: $mail_addr\n" if ($verbose);
    print $mail if ($debug);

    open SMAIL, "|mail -s \"$revoservo - konfirmo\" $mail_addr" 
	or die "Ne povas dukti al mail: $!\n";
    print SMAIL $mail;
    close SMAIL;
}


sub print_hash {
    my $hash = shift;
    my ($key, $value);

    while (($key,$value) = each %$hash) {
	print "$key: $value\n";
    }
}

sub is_editor {
    my $email_addr = shift;
    my $res_addr = '';

    $email_addr =~ s/^.*<([a-z0-9\.\_\-]+\@[a-z0-9\._\-]+)>.*$/<$1>/i;

    # serchu en la dosiero kun redaktoroj
    open EDI, $editor_file;
    while (<EDI>) {
	chop;
	unless (/^#/) {
		if (/$email_addr/i) {
		    print "retadreso trovita en: $_\n" if ($debug);
		    /([a-z\s]*<[a-z\@0-9\._]*>)/i;
		    $res_addr = $1;
		    unless ($res_addr) {
			warn "ne povis ekstrakti la adreson el $_\n";
		    } else {
			print "sendadreso de la redaktoro: $res_addr\n" 
			    if ($verbose);
		    }
		}
	    }
    }
		
    return $res_addr;
}


############# trakto de la komandoj ##############

sub cmd_help {
    my $email_addr = shift;

    # sendu helpdokumenton al la sendinto
}

sub cmd_redakt {
    my ($email_addr,$shangho,$teksto) = @_;
    my $err;

    # pri kiu artikolo temas, trovighas en <art mrk="...">
    $teksto =~ /(<art[^>]*>)/s;
    $1 =~ /mrk="([^\"]*)"/s; 
    my $id = $1;
    print "artikolo: $id\n" if ($verbose);
    $senditajho{'artikolo'} = $id;

    # ekstraktu dosiernomon el $Id: ...
    $id =~ /^\044Id: ([^ ,\.]+)\.xml,v\s+([0-9\.]+)/;
    my $art = $1;
    my $ver = $2;

    unless ($art =~ /^[a-z0-9_]+$/i) {
	error("Ne valida artikolmarko $art. Ghi povas enhavi nur "
	      ."literojn, ciferojn kaj substrekon.\n");
	return;
    }

    # skribu la dosieron provizore al ~/tmp
    open XML,">$tmp/xml.xml";
    print XML $teksto;
    close XML;

    # kontrolu la sintakson de la XML-teksto
    `$xmlcheck $tmp/xml.xml 2> $tmp/xml.err`;

    # legu la erarojn
    open ERR,"$tmp/xml.err";
    $err=join('',<ERR>);
    close ERR;

    if ($err) {
	$err .= "\nkunteksto:\n".xml_context($err,"$tmp/xml.xml");
	print "XML-eraroj:\n$err" if ($verbose);

	error("La sendita XML-dosiero enhavas la sekvajn "
	      ."sintakserarojn:\n$err");
	return;
    } else {
	print "XML: en ordo\n" if ($verbose);
    }

    # kontrolu chu ekzistas shangh-priskribo
    unless ($shangho) {
	print "mankas shangh-indiko\n" if ($verbose);
	error ("Vi fogesis indiki, kiujn shanghojn vi faris "
	    ."en la dosiero.\n");
        return;
    } 
    print "shanghoj: $shangho\n" if ($verbose);

    # skribu la shanghojn en dosieron
    open MSG,">$tmp/shanghoj.msg";
    print MSG "$email_addr: $shangho";
    close MSG;

    # kontrolu, chu la artikolo bazighas sur la aktuala versio
    # de la artikolo, se necese faru "diff"
    my $old_id = get_old_version($art);
    if ($old_id ne $id) {
	print "konflikto: nova kaj malnova Id diferencas!\n" if ($verbose);
	error ("La de vi sendita artikolo ($id) ne havas la saman\n"
	       ."version kiel la aktuala arkiva ($old_id)!\n"
	       ."Bonvolu preni aktualan version el la TTTejo\n"
	       ."($vokomail_url?art=$art)\n");
	return;
    }

    # checkin
    my $xmlfile="$art.xml";
    `mv $tmp/xml.xml $xml_dir/$xmlfile`;
    chdir($xml_dir);
    open CVS, "|$cvs ci -F $tmp/shanghoj.msg $xmlfile "
	."1> $tmp/ci.log 2> $tmp/ci.err" or 
	die "Ne povas dukti al $cvs: $!\n";
    close CVS;

    # chu checkin sukcesis?
    open LOG,"$tmp/ci.log";
    my $log = join('',<LOG>);
    print "ci-log:\n$log\n" if ($debug);
    close LOG;

    # se finighas "done" - chio en ordo, 
    # se finighas "aborting" - fiask'
    # se neniu eligajho, la dosiero ne estas shanghita
    
    open ERR,"$tmp/ci.err";
    $err = join('',<ERR>);
    print "ci-err:\n$err\n" if ($verbose);
    close ERR;

    if ($log =~ /^\s*$/s) {
	error("La sendita artikolo shajne ne diferencas de "
	      ."la aktuala versio.");
	return;
    } elsif (($log =~ /aborting\s*$/s) 
	     or ($err !~ /^ \s*$/s)) {
	error("Eraro dum arkivado de la nova artikolversio:\n"
	      ."$log\n$err");
	return;
    }

    # sendu raporton al la sendinto
    konfirmo($log);
}

sub cmd_dokument {
  # realigu poste
}

sub cmd_artikol {
  # realigu poste
}

sub cmd_propon {
  # realigu poste
}

sub cmd_histori {
  # realigu poste
}


sub xml_context {
    my ($err,$file) = @_;
    my ($line, $char,$result,$n,$txt);

    if ($err =~ /line\s+([0-9]+)\s+char\s+([0-9]+)\s+/s) {
	$line = $1;
	$char = $2;

	open XML,$file or die "Ne povis malfermi $file:$!\n";
	
	# la linio antau la eraro
	if ($line > 1) {
	    for ($n=1; $n<$line-1; $n++) {
		$txt=<XML>;
	    }
	    
	    $result .= "$n: ".<XML>;
	}
	$result .= "$line: ".<XML>;
	$result .= "-" x ($char + length($line) + 1) . "^\n";

	if (defined($txt=<XML>)) {
	    $line++;
	    $result .= "$line: $txt";
	}

	close XML;
	    
	return $result;
    }

    return '';
}

get_old_version {
    my ($art) = @_;
    my $xmlfile = "$xml_dir/$art.xml";

    # legu la ghisnunan artikolon
    open XMLFILE, $xmlfile or die "Ne povis legi $xmlfile: $!\n";
    my $txt = join('',XMLFILE);
    close XMLFILE;

    # pri kiu artikolo temas, trovighas en <art mrk="...">
    $txt =~ /(<art[^>]*>)/s;
    $1 =~ /mrk="([^\"]*)"/s; 
    my $id = $1;
    print "malnova artikolo: $id\n" if ($verbose);  

    return $id;
}


