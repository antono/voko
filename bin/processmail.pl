#!/usr/bin/perl

# legas unu post la alia mesaghojn el dosiero
# kaj dispartigas ilin en kapon kaj korpon,
# che MIME-mesaghoj - elpakas ties unuopajn partojn

# agendo
#   konstruo de mesaghoj por forsendado
#   test-programeto por la afero
#     por tio necesas: ekzemplaj mesaghoj, 
#       shaltilo por malhelpi sendadon de mesaghoj, sed
#       anstataua savo en dosieroj
#   sendu unu raporton al redaktantoj anstatau plurajn mesaghojn
#

use MIME::Parser;
use MIME::Entity;

######################### agorda parto ##################

# kiom da informoj
$verbose      = 1;
$debug        = 0;

# dosierujoj
$parts_dir    = '/home/revo/tmp';
$mail_folder  = '/var/spool/mail/revo';
$mail_error   = '/home/revo/tmp/mailerr';
$mail_send    = '/home/revo/tmp/mailsend';
$old_mail     = '/home/revo/oldmail';
$err_mail     = '/home/revo/errmail';
$tmp          = '/home/revo/tmp';
$xml_dir      = '/home/revo/revo/cvs/revo';

$mail_local   = '/home/revo/tmp/mail';
$editor_file  = '/home/revo/etc/redaktoroj';
$attachments  = $tmp.'/atchmnt';
$vokomail_url = 'http://www.uni-leipzig.de/cgi-bin/vokomail.pl';

# programoj
$xmlcheck     = '/usr/bin/rxp -V';
$cvs          = '/usr/bin/cvs';
$sendmail     = '/usr/lib/sendmail -t -i';

# diversaj
$mail_begin   = '^From[^:]';
$possible_keys= 'komando|teksto|shangho';
$commands     = 'redakt[oui]|help[oui]'; # .'|dokumento|artikolo|historio|propono'
$revoservo    = '[Revo-Servo]';
$revo_mailaddr= 'revo@steloj.de';
$revo_from    = "Reta Vortaro <$revo_mailaddr>";
$signature    = "--\nRevo-Servo $revo_mailaddr\n"
    ."retposhta servo por redaktantoj de Reta Vortaro.\n";
$separator    = "-" x 50 . "\n";

################ la precipa masho de la programo ##############

$the_mail   = '';
$editor     = '';
$article_id = '';
$mail_date  = '';
$shangho    = '';
$file_no    = 0;

if ($ARGV[0]) {
    $mail_file = shift @ARGV;
} else {

    # chu estas poshto?
    if (not -s $mail_folder) {
	print "neniu poshto en $mail_folder\n" if ($verbose);
	exit;
    };

    # shovu la poshtdosieron
    `mv $mail_folder $mail_local`;
    #`cp $mail_folder $mail_local`;

    $mail_file = $mail_local;
}

open MAIL, "$mail_file" or die "Ne povis malfermi $mail_file: $!\n";

while ($file = readmail()) {

    print '-' x 50, "\n" if ($verbose);

    # preparu por la nova mesagho
    $editor = '';
    $shangho = '';
    $parser = new MIME::Parser;
    $parser->output_dir($parts_dir);
    $parser->output_prefix("part");
    $parser->output_to_core(20000);        

    # malfermu kaj enlegu la mesaghon
    open ML, $file; 
    $entity = $parser->read(\*ML) or die "couldn't parse MIME stream";

    # eligu iom da informo pri la mesagho
    $header = $entity->head();
    print "From    : ", $header->get('From') if ($verbose);
    print "Subject : ", $header->get('Subject'),
          "Cnt-Type: ", $header->get('Content-Type'), "\n"
	      if ($debug);
    $entity->dump_skeleton if ($debug);

    $mail_date = $header->get('Date');
    chomp $mail_date;

    # analizu la enhavon de la mesagho
    process_ent($entity);

    # purigado
    $entity->purge();
    close ML;
}

close MAIL;

# sendu raportojn
send_reports();

# arkivigu la poshtdosieron
if ($mail_file eq $mail_local) {

    $filename = `date +%Y%m%d_%H%M%S`;  
    print "\nshovas $mail_local al $old_mail/$filename\n" if ($verbose);
    `mv $mail_local $old_mail/$filename`;
}

if (-e $mail_error) {
    print "shovas $mail_error al $err_mail/$filename\n" if ($verbose);
    `mv $mail_error $err_mail/$filename`;
}


###################### analizado de la mesaghoj ################

sub readmail {
	my $lastpos;
	
	$the_mail = <MAIL>;

	while (<MAIL>) {
		if (/$mail_begin/) {
		    seek(MAIL,$lastpos,0); # reiru unu linion
		    last;
		} else {
		    $the_mail .= $_;
		    $lastpos = tell(MAIL);
		};
	};

	if ($the_mail) {

	    my $fn = "/tmp/".$$."mail";
	    open OUT, ">$fn";
	    print OUT $the_mail;
	    close OUT;
	    return $fn;

	} else { 
	    return; 
	};
}		
		

sub process_ent {
    my $entity = shift;
    my $parttxt;
    my $komando = '';
    my $xmltxt = '';

    # kontrolu, chu temas pri redaktoro au helpkrio
    unless ($editor = is_editor($entity->head->get('from'))) { 

	# chu temas pri helpkrio?
	# tia helppeto validas nur en simplaj mesaghoj
	if ($entity->mime_type =~ m|^text/plain|) {
	    my $first_line = $entity->bodyhandle->getline;
	    if ($first_line =~ /^\s*help/) {

		cmd_help($entity->head->get('reply-to') 
			 || $entity->head->get('from'));

		print "komando \"helpo\"\n" 
		    if ($verbose);
		return;
	    };
	};
	    
	print "!!! ".$entity->head->get('from')." ne estas redaktoro "
	    ."nek petas pri helpo !!!\n"
	    ."\tsubject: ".$entity->head->get('subject')."\n"
	    ."\tstart of mail: $first_line\n---\n";
	save_errmail();
	return; # ne respondu al SPAMo
    }
	
    print "redaktisto: $editor\n" if ($debug);

    # unuparta mesagho
    if (! $entity->is_multipart) {
	print "single part message\n" if ($debug);
	# TTT-formularo
	if ($entity->mime_type =~ m|application/x-www-form-urlencoded|) {
	    print "URL encoded form\n" if ($debug);
	    urlencoded_form($entity->bodyhandle->as_string);
	    return;
	# normala mesagho
	} else {
	    print "normala mesagho\n" if ($debug);
	    normal_message($entity->bodyhandle->as_string);
	    return;
	}
	
    # plurparta MIME-mesagho
    } else {
	my $num_parts = $entity->parts;
	print "num of parts: ", $num_parts, "\n" if ($debug);

	# trairu chiujn partojn
	for ($i = 0; $i < $num_parts; $i++) {
	    my $part = $entity->part($i);
	    print $part->mime_type, "\n" if ($debug);

	    # elprenu la tekston
	    $parttxt = $part->bodyhandle->as_string;

	    # chu temas pri TTT-formularo?
	    if (($entity->head->get('subject') 
		 =~ /Internet\s+Explorer/)
		and ($parttxt =~ /^\s*komando=redakto&/)
		or ($part->mime_type 
		    =~ m|application/x-www-form-urlencoded|)) {
		
		# TTT-formularo
		urlencoded_form($parttxt);
		return;
	    }

	    # ekzamenu, chu en la partoj estas komando kaj/au xml
	    if ($parttxt =~ /^\s*($commands)\s*:/si) {
		$komando = $1;
		print "komando $komando en parto $i\n" if ($debug);
		if ($komando =~ /^(help|dokument|artikol|histori)/) {
		    normal_message($parttxt);
		} else {
		    # chu krome enhavas la xml-tekston?
		    if ($parttxt =~ /<\?xml/s) {
			print "xml en parto $i\n" if ($debug);
			normal_message($parttxt);
			return;
		    } else {
			# supozu, ke estas nur la komando kaj trovu la reston
			$komando = $parttxt;
		    }
		}
	    } elsif ($parttxt =~ /^\s*<\?xml/s) {
		print "xml en parto $i\n" if ($debug);
		# memoru la xml-tekston
		$xmltxt = $parttxt;
	    }

	    # se ambau - komando kaj xml - estas trovitaj, daurigu
	    if ($komando and $xmltxt) {
		normal_message("$komando\n\n$xmltxt");
		return;
	    }
	}
	# en la plurparta mesagho shajne ne trovighis la serchita
	send_error("Ne trovighis komando kaj/au XML-teksto en la "
		   ."plurparta mesagho");
    }
}

sub is_editor {
    my $email_addr = shift;
    my $res_addr = '';

    chomp $email_addr;
    $email_addr =~ s/^.*<([a-z0-9\.\_\-]+\@[a-z0-9\._\-]+)>.*$/<$1>/si;
    unless ($email_addr =~ /<?[a-z0-9\.\_\-]+\@[a-z0-9\._\-]+>?/i) { 
	return; # ne estas valida retadreso
    }

    # serchu en la dosiero kun redaktoroj
    open EDI, $editor_file;
    while (<EDI>) {
	chomp;
	unless (/^#/) {
		if (index($_,$email_addr) >= 0) {
		    print "retadreso trovita en: $_\n" if ($debug);
		    /([a-z\s]*<[a-z\@0-9\._]*>)/i;
		    $res_addr = $1;
		    unless ($res_addr) {
			print "ne povis ekstrakti la adreson el $_\n";
		    } else {
			print "sendadreso de la redaktoro: $res_addr\n" 
			    if ($debug);
		    }
		    return $res_addr;
		}
	    }
    }
		
    return; # ne trovita
}


sub urlencoded_form {
    my $text = shift;
    my %content = ();
    my ($key,$value);

    $text =~ s/!?\n//sg;
    foreach $pair (split ('&',$text)) {
	if ($pair =~ /(.*)=(.*)/) {
	    ($key,$value) = ($1,$2);
	    if ($key =~ /^(?:$possible_keys)$/) {
		$value =~ s/\+/ /g; # anstatauigu '+' per ' '
		$value =~ s/%(..)/pack('c',hex($1))/seg;
		$content{$key} = $value;
	    };
	}
    };           

    komando($content{'komando'},$content{'shangho'},$content{'teksto'});
}

sub normal_message {
    my $text = shift;
    my ($cmd,$arg,$xml);

    if ($text =~ s/^[\s\n]*($commands)[ \t]*:[ \t]*(.*?)\n//si) {
	$cmd = $1;
	$arg = $2;

	# legu chion ghis malplena linio au "<?xml..."
	while (($text !~ /^\s*\n/) and ($text !~ /^\s*<\?xml/i)) {
	    $text =~ s/^[ \t]*(.*?)\n//;
	    $arg .= $1;
	}

	# la resto povus esti la artikolo
	$text =~ s/^[\s\n]*//;
	
	# kaze, ke iu subskribo finas la mesaghon, forigu
	# chion post </vortaro>
	$text =~ s/(<\/vortaro>).*$/$1/s; 
	
	if ($text) {
	    $xml = $text;
	}

	komando($cmd,$arg,$xml);
	
    } else {
	send_error("nekonata komando en la poshtajho");
	return;
    }
}

sub komando {
    my ($cmd,$arg,$txt) = @_;

    if ($cmd =~ /^help[oui]$/) {
	cmd_hlp();

    } elsif ($cmd =~ /^dokumento/) {
	cmd_dokument($arg);

    } elsif ($cmd =~ /^redakt[oui]/) {
	cmd_redakt($arg, $txt);

    } elsif ($cmd =~ /^historio/) {
	cmd_histori($arg);
	
    } elsif ($cmd =~ /^artikolo/) {
	cmd_artikol($arg);

    } elsif ($cmd =~ /^propon[oui]/) {
	cmd_propon($arg, $txt);
    } else {
	send_error("nekonata komando $cmd");
	return;
    }
}

sub save_errmail {
    open ERRMAIL, ">>$mail_error" or die "Ne povis malfermi $mail_error: $!\n";
    print ERRMAIL $the_mail;
    close ERRMAIL;
    print "erara mesagho sekurigita al $mail_error\n" if ($verbose);
}


######################### respondoj al sendintoj ###################

sub send_error {
    my ($errmsg,$file,$attachment,$text) = @_;
    
    print "ERARO   : $errmsg\n" if ($verbose);

    # donu provizoran nomon al kunsendajho
    if ($file) {

	# enmetu "redakto: $shanghoj" komence
	if ($file =~ /\.xml$/) {
	    open FILE, $file or die "Ne povis malfermi $file: $!\n";
	    $text = join('',<FILE>);
	    close FILE;
	    open FILE, ">$file" or die "Ne povis malfermi $file: $!\n";
	    print FILE "redakto: $shangho\n\n";
	    print FILE $text;
	    close FILE;
	}
	
	# donu provizoran nomon al la dosiero
	$file_no++;
	$attachment = "$attachments$file_no";
	`mv $file $attachment`;
    }

    # skribu informon en $mail_send por poste sendi raporton al $editor
    open SMAIL, ">>$mail_send" or die "Ne povis malfermi $mail_send: $!\n";

    print SMAIL "sendinto: $editor\n";
    print SMAIL "dosieroj: $attachment\n" if ($file);
    print SMAIL "senddato: $mail_date\n";
    print SMAIL "artikolo: $article_id\n";
    print SMAIL "shanghoj: $shangho\n" if ($shangho);
    print SMAIL "ERARO   : $errmsg\n";
    print SMAIL $separator;

    close SMAIL;
}

sub send_confirm {
    my ($msg,$file,$attachment) = @_;

    print "KONFIRMO: $msg\n" if ($verbose);

    # donu provizoran nomon al kunsendajho
    if ($file) {
	$file_no++;
	$attachment = "$attachments$file_no";
	`mv $file $attachment`;
    }

    # skribu informon en $mail_send por poste sendi raporton al $editor
    open SMAIL, ">>$mail_send" or die "Ne povis malfermi $mail_send: $!\n";

    print SMAIL "sendinto: $editor\n";
    print SMAIL "dosieroj: $attachment\n" if ($file);
    print SMAIL "senddato: $mail_date\n";
    print SMAIL "artikolo: $article_id\n";
    print SMAIL "shanghoj: $shangho\n" if ($shangho);
    print SMAIL "KONFIRMO: $msg\n";
    print SMAIL $separator;

    close SMAIL;
}

sub send_reports {
    my $newline = $/;
    my %reports = ();
    my %dosieroj = ();
    my ($mail_addr,$message,$mail_handle,$file,$art_id,$marko,$dos);

    # legu la respondojn el $mail_send
    $/ = $separator;
    open SMAIL, $mail_send or die "Ne povis malfermi $mail_send: $!\n";
    while (<SMAIL>) {
	# elprenu la sendinton
	if (s/^sendinto:\s*([^\n]+)\n//) {
	    $mail_addr = $1;
	    # chu dosierojn sendu?
	    if (s/^dosieroj:\s*([^\n\s]+)\n//) {
		$dos = $1;
		$_ =~ /artikolo:\s*([^\n]+)\n/s; $art_id = $1;
		
		$dosieroj{$mail_addr} .= "$dos $art_id|";
	    }
	    $reports{$mail_addr} .= $_;
	} else {
	    die "Ne povis elpreni sendinton el $_\n";
	}
    }
    close SMAIL;
    $/ = $newline;

    # forsendu la raportojn
    while (($mail_addr,$message) = each %reports) {
	$dos = $dosieroj{$mail_addr};
	$mail_addr =~ s/.*<([a-z\.\_\-@]+)>.*/$1/;

	# preparu mesaghon
	$message = "Saluton!\n"
	    ."Jen raporto pri via(j) sendita(j) artikolo(j).\n\n"
	    .$separator.$message."\n".$signature;

	$mail_handle = build MIME::Entity(Type=>"multipart/mixed",
					  From=>$revo_from,
					  To=>"$mail_addr",
					  Subject=>"$revoservo - raporto");
	
	$mail_handle->attach(Type=>"text/plain",
			     Encoding=>"quoted-printable",
			     Data=>$message);

	# alpendigu dosierojn
	if ($dos) {
	    for $file (split (/\|/,$dos)) {
		$file =~ s/^\s*([^\044]+)\s*\044([^\044]+)\044\s*$/$1/;
		$art_id = $2;
		$art_id =~ /^Id: ([^ ,\.]+\.xml),v/;
		$marko = $1;

		print "attach: $file\n" if ($debug);
		if ($file) {
		    $mail_handle->attach(Path=>$file,
					Type=>'text/plain',
					Encoding=>'quoted-printable',
					Disposition=>'attachment',
					Filename=>$marko,
					Description=>$art_id);
		}
	    }
	}

	# forsendu
	open SENDMAIL, "|$sendmail" 
	    or die "Ne povas dukti al $sendmail: $!\n";
	$mail_handle->print(\*SENDMAIL);
	close SENDMAIL;
    }

    # forigu $mail_send
    unlink($mail_send);
}


###################### komandoj kaj helpfunkcioj ##############


sub cmd_help {

    # sendu helpdokumenton al la sendinto
}

sub cmd_redakt {
    my ($shangh,$teksto) = @_;
    my $id,$art,$err;
    $shangho = $shangh; # memoru por poste

    # uniksajn linirompojn!
    $teksto =~ s/\r\n/\n/sg;

    # pri kiu artikolo temas, trovighas en <art mrk="...">
    $teksto =~ /(<art[^>]*>)/s;
    $1 =~ /mrk="([^\"]*)"/s; 
    $id = $1;
    print "artikolo: $id\n" if ($verbose);
    $article_id = $id;

    # ekstraktu dosiernomon el $Id: ...
    $id =~ /^\044Id: ([^ ,\.]+)\.xml,v\s+([0-9\.]+)/;
    $art = $1;
    #my $ver = $2;

    unless ($art =~ /^[a-z0-9_]+$/i) {
	send_error("Ne valida artikolmarko $art. Ghi povas enhavi nur "
	      ."literojn, ciferojn kaj substrekon.\n");
	return;
    }

    if (checkxml($teksto)) {
	checkin($art,$id);
    }
}

sub checkxml {
    my $teksto = shift;
    my $err;

    # enmetu $Log$
    # enmetu Revision 1.7  1999/11/24 17:05:33  revo
    # enmetu *** empty log message ***
    # enmetu
    # enmetu Revision 1.6  1999/11/22 17:18:25  revo
    # enmetu sendu raportojn anstatau unuopajn respondojn
    # enmetu en la tekston, se ankorau ne estas
    unless ($teksto =~ /<!--\s+\044Log/s) {
	$teksto =~ s/(<\/vortaro>)/\n<!--\n\044Log\044\n-->\n$1/s;
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

	send_error("La sendita XML-dosiero enhavas la sekvajn "
	      ."sintakserarojn:\n$err","$tmp/xml.xml");
	return;
    } else {
	print "XML: en ordo\n" if ($debug);
	return 1;
    }
}

sub checkin {
    my ($art,$id) = @_;
    my ($log,$err,$edtr);

    # kontrolu chu ekzistas shangh-priskribo
    unless ($shangho) {
	send_error ("Vi fogesis indiki, kiujn shanghojn vi faris "
	    ."en la dosiero.\n","$tmp/xml.xml");
        return;
    } 
    print "shanghoj: $shangho\n" if ($verbose);

    # skribu la shanghojn en dosieron
    $edtr = $editor;
    $edtr =~ s/\s*<(.*?)>\s*//;

    open MSG,">$tmp/shanghoj.msg";
    print MSG "$edtr: $shangho";
    close MSG;

    # kontrolu, chu la artikolo bazighas sur la aktuala versio
    # de la artikolo, se necese faru "diff"
    my $old_id = get_old_version($art);
    if ($old_id ne $id) {
	send_error ("La de vi sendita artikolo\n"
	       ."ne havas la saman version kiel la aktuala arkiva\n"
	       ."($old_id)\n"
	       ."Bonvolu preni aktualan version el la TTTejo\n"
	       ."($vokomail_url?art=$art)\n","$tmp/xml.xml");
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
    $log = join('',<LOG>);
    print "ci-log:\n$log\n" if ($debug);
    close LOG;

    # se finighas "done" - chio en ordo, 
    # se finighas "aborting" - fiasko
    # se neniu eligajho, la dosiero ne estas shanghita
    
    open ERR,"$tmp/ci.err";
    $err = join('',<ERR>);
    print "ci-err:\n$err\n" if ($debug);
    close ERR;

    if ($log =~ /^\s*$/s) {
	send_error("La sendita artikolo shajne ne diferencas de "
	      ."la aktuala versio.");
	return;
    } elsif (($log =~ /aborting\s*$/s) 
	     or ($err !~ /^\s*$/s)) {
	send_error("Eraro dum arkivado de la nova artikolversio:\n"
	      ."$log\n$err","$tmp/xml.xml");
	return;
    }

    # sendu raporton al la sendinto
    send_confirm($log);
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
		<XML>;
	    }
	    
	    $result .= "$n: ".<XML>;
	    $result =~ s/\n?$/\n/s;
	}
	$result .= "$line: ".<XML>;
	$result =~ s/\n?$/\n/s;
	$result .= "-" x ($char + length($line) + 1) . "^\n";

	if (defined($txt=<XML>)) {
	    $line++;
	    $result .= "$line: $txt";
	    $result =~ s/\n?$/\n/s;
	}

	close XML;
	    
	return $result;
    }

    return '';
}

sub get_old_version {
    my ($art) = @_;
    my $xmlfile = "$xml_dir/$art.xml";

    # legu la ghisnunan artikolon
    open XMLFILE, $xmlfile or die "Ne povis legi $xmlfile: $!\n";
    my $txt = join('',<XMLFILE>);
    close XMLFILE;

    # pri kiu artikolo temas, trovighas en <art mrk="...">
    $txt =~ /(<art[^>]*>)/s;
    $1 =~ /mrk="([^\"]*)"/s; 
    my $id = $1;
    print "malnova artikolo: $id\n" if ($debug);  

    return $id;
}










