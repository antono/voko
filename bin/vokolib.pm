package vokolib;

require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw(index_header index_footer index_buttons read_cfg diff_mv);

# skribas la supran parton de html-ajho
sub index_header {
    my $title = shift;
    print
        "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n",
	"<html>\n<head>\n<meta http-equiv=\"Content-Type\" ",
	"content=\"text/html; charset=UTF-8\">\n",
	"<title>$title</title>\n",
	"<link title=\"indekso-stilo\" type=\"text/css\" ",
	"rel=stylesheet href=\"../stl/indeksoj.css\">\n",
	"</head>\n<body>\n";
}

# skribas la suban parton de html-ajho
sub index_footer {
    print "\n</body>\n</html>\n";
}


# skribas tabelon kun ligoj al precipaj indekspaghoj
sub index_buttons {
    my $self = shift || "";
    my $bgcolor = 'bgcolor="#AACCAA"';

    print 
	"<script type=\"text/javascript\" src=\"../smb/butonoj.js\"></script>\n",

        (($self eq 'eo')? 
	 "<img src=\"../smb/nav_eo0.png\" alt=\"[Esperanto]\" border=0>\n":
	 "<a href=\"../inx/_eo.html\" onMouseOver=\"highlight(0)\" ".
	 "onMouseOut=\"normalize(0)\">".
	 "<img src=\"../smb/nav_eo1.png\" alt=\"[Esperanto]\" border=0></a>\n"),

	(($self eq 'lng')?
	 "<img src=\"../smb/nav_lng0.png\" alt=\"[Lingvoj]\" border=0>\n":
	 "<a href=\"../inx/_lng.html\" onMouseOver=\"highlight(1)\" ".
	 "onMouseOut=\"normalize(1)\">".
	 "<img src=\"../smb/nav_lng1.png\" alt=\"[Lingvoj]\" border=0></a>\n"),

        (($self eq 'fak')?
	 "<img src=\"../smb/nav_fak0.png\" alt=\"[Fakoj]\" border=0>\n":
	 "<a href=\"../inx/_fak.html\" onMouseOver=\"highlight(2)\" ".
	 "onMouseOut=\"normalize(2)\">".
	 "<img src=\"../smb/nav_fak1.png\" alt=\"[Fakoj]\" border=0></a>\n"),

        (($self eq 'ktp')?
	 "<img src=\"../smb/nav_ktp0.png\" alt=\"[ktp.]\" border=0>\n":
	 "<a href=\"../inx/_ktp.html\" onMouseOver=\"highlight(3)\" ".
	 "onMouseOut=\"normalize(3)\">".
	 "<img src=\"../smb/nav_ktp1.png\" alt=\"[ktp.]\" border=0></a>\n"),

	"<br>";
}

sub read_cfg {
    $cfgfile = shift;
    $stir_lin = shift || 0;
    my %hash = ();

    open CFG, $cfgfile 
	or die "Ne povis malfermi dosieron \"$cfgfile\": $!\n";

    while ($line = <CFG>) {
	# linio komencighanta per #! entenas stir-informojn
	if ($line =~ /^#!/ and $stir_lin) {
	    $line =~ s/^#!//; chomp $line;
	    $hash{'_#!_'} = $line;
	} elsif ($line !~ /^#|^\s*$/) {
	    $line =~ /^([^=]+)=(.*)$/;
	    $hash{$1} = $2;
	}
    }
    close CFG;
    return %hash;
}


# komparas novan dosieron kun ekzistanta,
# kaj nur che shanghoj au neekzisto alshovas
# la novan dosieron

sub diff_mv {
    my ($newfile,$oldfile,$verbose) = @_;

    if ((! -e $oldfile) or (`diff -q $newfile $oldfile`)) {
	print "$oldfile\n" if ($verbose);
	`mv $newfile $oldfile`;
	return 1;
    } else {
	#print "(senshanghe)\n" if ($verbose);
	unlink($newfile);
	return 0;
    }
};
