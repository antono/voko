#!/usr/bin/perl

# folgendes sollte getestet werden:
#  - ob die Formulare einzeln aufrufbar und sinnvolles Ergebnis liegern
#  - ob sie nur autorisiert aufgerufen werden können
#  - ob sie bei ungültigen Paramtern korrekte Fehlermeldungen bringen:
#      z.B. falscher Parameter orig, undgenügende Angaben, z.B. art fehlt
#      aldonu mit bereits ex. art, forigu ohne ex. art u.ä.
# Im Prinzip könnte auch ein Durchlaufen der Formulare durch den
# Anwender simuliert werden, indem die notwendigen Parameter aus
# dem HTML-Text gefischt werden und ein Submit simuliert wird...

$login="uzanto=wolfram pasvorto=diestel";

print "NERAJTIGITA_1: \n";
$out = `redakti.pl xxx=yyy`;

if (checkheader($out) and 
    checkhtml($out) and 
    checkform($out,1) and
    checktitle($out,"rajtigilo")) {

    print "ok\n";

} else {
    print "nicht ok:\n$out";
}

print "NERAJTIGITA_2: \n";
$out = `redakti.pl uzanto=wolfram pasvorto=xxx`;

if (checkheader($out) and 
    checkhtml($out) and 
    checkform($out,1) and
    checktitle($out,"rajtigilo")) {

    print "ok\n";

} else {
    print "nicht ok:\n$out";
}

print "REDAKTOPAGHO_1: \n";

@ENV{'PATH_INFO'} = 'redakti';
$out =  `redakti.pl $login orig=aldoni sxablono=simpla kapvorto=test/o 2>&1`;

if (checkheader($out) and
    checkhtml($out) and
    checktitle($out,"redakti") and
    checkform($out,2) and
    checkstr($out,'rad&gt;test&lt;\/rad&gt;\/o')) 
{
    print "ok\n";
} else {
    print "nicht ok:\n$out";
}
    
print "REDAKTOPAGHO_2: \n";
@ENV{'PATH_INFO'} = 'redakti';
$out =  `redakti.pl $login orig=redakti teksto=xyz 2>&1`;

if (checkheader($out) and
    checkhtml($out) and
    checktitle($out,"redakti") and
    checkform($out,2))
{
    print "ok\n";
} else {
    print "nicht ok:\n$out";
}

print "CENTRA REDAKTOPAGHO: \n";
@ENV{'PATH_INFO'} = '';
$out =  `redakti.pl $login 2>&1`;

if (checkheader($out) and
    checkhtml($out) and
    checkform($out,4) and
    checktitle($out,"centra redaktopaøo"))
{
    print "ok\n";
} else {
    print "nicht ok:\n$out";
}


############ check-Funktionen ###################


sub checkheader {
    $text = shift;

    if ($text =~ /Content-Type:\s*text\/html\s*\n\s*\n/si) {
	return true;
    } else {
	warn "Header \"Content-Type...\" fehlt\n";
	return;
    }
}
	

sub checkhtml {
    $text = shift;

    if (($text =~ /<html>/i) and
	($text =~ /<\/html>\s*$/si)) {
	return true;
    } else {
	warn "<html> oder </html> fehlt\n";
	return;
    }
    
}

sub checkform {
    $text = shift;
    $cnt = shift;
    my $c1 = 0;
    my $c2 = 0;

    $text =~ s/<form/$c1++/sieg;
    $text =~ s/<\/form>/$c2++/sieg;

    if ($c1 != $cnt) {
	warn "<form> wurde $c1"."x gefunden, erwartet wurde $cnt"."x\n";
	return;
    }

    if ($c2 != $cnt) {
	warn "</form> wurde $c2"."x gefunden, erwartet wurde $cnt"."x\n";
	return;
    }
	
    return true;
}


sub checktitle {
    $text = shift;
    $title = shift;

    if ($text =~ /<title>\s*$title\s*<\/title>/si) {
	return true;
    } else {
	warn "<title>$title</title> erwartet\n";
	return;
    }
}


sub checkstr {
    $text = shift;
    $string = shift;

    
    if ($text =~ /$string/si) {
	return true;
    } else {
	warn "$string erwartet\n";
	return;
    }
}

