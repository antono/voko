#! /usr/bin/perl
## unshift(@INC, '/usr/lib/perl5');
##---------------------------------------------------------------------------##
##  Tiu �i programeto bazi�as sur:
##
##  File:
##      dtd2html
##  Author:
##      Earl Hood       ehood@convex.com
##  Description:
##	dtd2html is a Perl program to generate HTML documents to allow
##	people to navigate thru an SGML dtd.  This program requires the
##	use of the "dtd" package.
##---------------------------------------------------------------------------##
##  Copyright (C) 1994	Earl Hood, ehood@convex.com
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##  
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##  
##  You should have received a copy of the GNU General Public License
##  along with this program; if not, write to the Free Software
##  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
##---------------------------------------------------------------------------##

package main;

##---------------------------------------------------------------------------##

## Store name of program ##
($PROG = $0) =~ s%.*(/|\\|:)%%;

$VERSION = "1.0";

$HomeDesc = "-home-";
$EntsDesc = "-ents-";
$dfilecnt = 0;

%ElemDesc	= ();	# Element descriptions
%SharedDesc	= ();	# Shared element descriptions
%SharedId	= ();	# Tell is element description is shared

## Require libraries ##
$path = $0;
$path =~ s|\\|/|g; # sub Windows anstatauigu \ per /
$path =~ s/dtd2html.pl$//;
unshift(@INC, $path);
require "dtd.pm" || die "Unable to require dtd.pm\n";
require "newgetopt.pm" || die "Unable to require newgetopt.pm\n";

## Import dtd variables ##
$rni = $dtd::rni;
$PCDATA = $dtd::PCDATA;
$RCDATA = $dtd::RCDATA;
$SDATA = $dtd::SDATA;
$CDATA = $dtd::CDATA;
$EMPTY = $dtd::EMPTY;
$FIXED = $dtd::FIXED;
$NOTATION = $dtd::NOTATION;
##
## Replace dtd::print_elem routine to spit out HTML.
## This requires intimate knowledge of how dtd.pm calls print_elem().
##
$sub_print_elem =<<'EndOfSub';
package dtd;
sub print_elem {
    local($elem, $level, *open) = @_;
    local($i, $indent, $base);
    if ($level == 1) {
	local($tmp) = ($elem);
	$tmp =~ tr/A-Z/a-z/;
	print($TREEFILE qq|<A HREF="#$tmp">|,
			qq|<STRONG>$elem</STRONG></A>\n|);
    } else {
	for ($i=2; $i < $level; $i++) {
	    $indent .= ($open{$i} ? " | " : "   "); }
	if ($elem ne "") {
	    if ($elem =~ /\(/) {
		$indent .= " | ";
	    } elsif ($elem !~ /\|/) {
		$indent .= " +-"; # " |_";
		if (!&::DTDis_elem_keyword($elem)) {
		    $elem  =~ /^(\S+)(.*)$/;
		    if ($2) {
			$elem = qq|<A HREF="#$1">$1</A>$2|;
		    } else {
			$elem = qq|<A HREF="#$1">| .
				qq|<STRONG>$1</STRONG></A>|;
		    }
		}
	    }
	}
	print($TREEFILE $indent, $elem, "\n");
    }
}
EndOfSub
eval $sub_print_elem;

##-------------------------------------##
## Comment-Callback ##

%Komentoj;

sub print_comment {
    my $txt = ${$_[0]}; # prenu la enhavon de la variablo transdonita
                        # en la unua parametro

    # Chu la komento rilatas al elemento?
    if ($txt =~ s/^\s*\[([^\[]*)\]\s*//) {
	$Komentoj{$1}=$txt;
    };
};

$dtd::COMMENT_CALLBACK='main::print_comment';


##---------------------------------------------------------------------------##
			    ##------------##
			    ## MAIN BLOCK ##
			    ##------------##
{
&get_cli_opts();

    print STDERR "Reading $MAPFILE ...\n" if $VERBOSE;
&DTDread_catalog_files($MAPFILE);
    print STDERR "Finished $MAPFILE\n" if $VERBOSE;

    print STDERR "Reading $DTDFILE ...\n" if $VERBOSE;
&DTDread_dtd($DTD);
    print STDERR "Finished $DTDFILE\n" if $VERBOSE;

&print_begin();

if ($UPDATEEL)	{ &update_elemdesc(); exit 0; }
if ($ELEMLIST)	{ &print_elemdescfile(); exit 0; }
if ($ENTSLIST)	{ &print_entsdescfile(); exit 0; }
if ($QREF)	{ &write_qref(); exit 0; }
#if ($TREE)	{ &write_tree_page(); }
#&print_elemdescfile(); exit 0; 
#&print_entsdescfile(); exit 0; 
#&write_qref(); 
 
if (!$TREEONLY) {
    &read_descfile($DESCFILE);
    &write_home_page();
    &write_topelem_page();
    &write_allelem_page();

&write_tree_page();

    if ($ENTS) { &write_ents_page(); }
    foreach (&DTDget_elements()) {
	&write_elem_page($_);
    }
}
&print_end();

# konvertu al UTF8
`lat3_utf8.pl dtd.html`;

exit 0;
}
			    ##----------##
			    ## END MAIN ##
			    ##----------##

##---------------------------------------------------------------------------##
##				SubRoutines				     ##
##---------------------------------------------------------------------------##
sub get_cli_opts {
    local($tmp);
    &usage() unless
    &NGetOpt(

	"allname=s",	# Name of all element list page
	"contnosort",	# Base content list is in order of model declaration
	"descfile=s",	# Element description file
	"docurl=s",	# URL to dtd2html HTML document
	"dtdname=s",	# Name of DTD
	"elemlist",	# Flag to generate empty element list
	"ents",		# Create a general entities page
	"entsfile=s",	# Name of general entities page
	"entslist",	# Flag to generate empty entity list
	"homefile=s",	# Name of home page
	"keepold",	# Keep old descriptions if -updateel specified
	"level=i",	# Cutoff level for tree
	"mapfile=s",	# Entity map file
	"modelwidth=i",	# Maximum output width for <elem>.cont pages
	"nodocurl",	# Flag for not putting link to dtd2html docs
	"noreport",	# No report generated if -updateel specified
	"outdir=s",	# Destination directory for files
	"qref",		# Output quick reference
	"qrefdl",	# Output quick reference in a <DL>
	"qrefhtag=s",	# Header tag for element name in quick reference
	"reportonly",	# Only output report -updateel specified
	"topfile=s",	# Name of top element list page
	"tree",		# Create tree file
	"treelink",	# Create link to tree in HTML pages, regardless
	"treefile=s",	# Name of tree page
	"treeonly",	# Create only the tree file
	"treetop=s",	# Comma separated list of top elements for tree
	"updateel=s",	# Update an element description file
	"verbose",	# Flag to print out what is going on

	"help"		# Print usage
    );

    &usage() if defined($opt_help);

    $ANNOTATE = (defined($opt_contnosort) ? 1 : 0);
    $ENTS     = (defined($opt_ents)	? 1 : 0);
    $TREE     = (defined($opt_tree)	? 1 : 0);
    $TREELINK = (defined($opt_treelink) ? 1 : 0);
    $TREEONLY = (defined($opt_treeonly) ? 1 : 0);
	$TREE = 1 if $TREEONLY;
    $ELEMLIST = (defined($opt_elemlist) ? 1 : 0);
    $ENTSLIST = (defined($opt_entslist) ? 1 : 0);
    $KEEPOLD  = (defined($opt_keepold)	? 1 : 0);
    $NODOCURL = (defined($opt_nodocurl) ? 1 : 0);
    $NOREPORT = (defined($opt_noreport) ? 1 : 0);
    $RPRTONLY = (defined($opt_reportonly) ? 1 : 0);
    $QREF     = (defined($opt_qref)	? 1 : 0);
    $QREFDL   = (defined($opt_qrefdl)	? 1 : 0);
	$QREF = 1 if $QREFDL;
    $VERBOSE  = (defined($opt_verbose)	? 1 : 0);
	&DTDset_verbosity(1) if $VERBOSE;

    $ENTSFILE = $opt_entsfile	|| "ENTS.html";
    $DTDFILE  = $ARGV[0]	|| "";
    $MAPFILE  = $opt_mapfile	|| "map.txt";
    $MWIDTH   = $opt_modelwidth || 65;
    $DESCFILE = $opt_descfile	|| "";
    $DOCURL   = $opt_docurl	||
		 "http://www.oac.uci.edu/indiv/ehood/dtd2html.html";
    $OUTDIR   = $opt_outdir	|| ".";
    $DTDNAME  = $opt_dtdname	|| "";
    $HOMEFILE = $opt_homefile	|| "dtd.html"; #"DTD-HOME.html";
    $TOPFILE  = $opt_topfile	|| "dtd.html"; #"TOP-ELEM.html";
    $ALLFILE  = $opt_allfile	|| "dtd.html"; #"ALL-ELEM.html";
    $TREEFILE = $opt_treefile	|| "dtd.html"; #"DTD-TREE.html";
    $UPDATEEL = $opt_updateel	|| "";
    $LEVEL    = $opt_level	|| 15;
    $TREETOP  = $opt_treetop	|| "";
    $QHb      = $opt_qrefhtag	|| "H2";
	$QHb  =~ tr/a-z/A-Z/;
	$QHe  = "</$QHb>";  $QHb = "<$QHb>";
 
    if ($DTDFILE) {
	open(DTD_FILE, "< $DTDFILE") || die "Unable to open $DTDFILE\n";
	$DTD = "main::DTD_FILE";
    } else {
	$DTD = 'STDIN';
    }
    if (! $DTDNAME) {
	if ($DTDFILE) {
	    $DTDNAME = $DTDFILE;
	    $DTDNAME =~ s/.*\///;  $DTDNAME =~ s/^(.*)\..*$/\1/;
	} else {
	    $DTDNAME = 'Unknown';
	}
    }
    $DTDNAME = 'DTD '.$DTDNAME;
    $DTDFILE = 'DTD' unless $DTDFILE;
}
##---------------------------------------------------------------------------##
sub read_descfile {
    local($filename) = shift;

    return unless $filename;
    local($handle) = ('FILE' . $dfilecnt++);
    if (!open($handle, "< $filename")) {
	warn "Unable to open $filename\n";
	return;
    }
    print STDERR "Reading $filename ...\n" if $VERBOSE;
    
    local(@elem, $txt, $tmp, $id, $action, $arg);
    $txt = "";

    while(<$handle>) {
	next if /^\s*<!--/ || /^\s*<!>/;	# Skip comments

	if (s/^\s*<\?\s*DTD2HTML\s+([^>\s]+)//) {
	    $id = $1;
	    $txt = "" if $txt =~ /^\s*(<P>)?\s*$/;
	    foreach (@elem) {
		if ($_ && !$ElemDesc{$_}) { $ElemDesc{$_} = $txt; }
	    }
	    if ($UPDATEEL) {
		if ($#elem > 0) {
		    $tmp = join(',', @elem);
		    $SharedDesc{$tmp} = $txt;
		    foreach (@elem) {
			$SharedId{$_} = $tmp;
		    }
		} else {
		    $SharedId{$elem[0]} = ''  if $txt;
		}
	    }

	    ## Determine type of action
	    if ($id =~ s/^#//) {		# Processing directive
		($arg) = /^\s*(\S+)\s*>\s*$/;
		if ($id =~ /include/i) {
		    &read_descfile($arg);
		}
		@elem = ();
	    } else {				# Description entry
		@elem = split(/,/, $id);
		grep(/&/ || tr/A-Z/a-z/, @elem);
	    }
	    $txt = "";

	} else {			# Text for a description
	    $txt .= $_;
	}
    }
    foreach (@elem) {
	$ElemDesc{$_} = $txt
	    if $_ && $txt !~ /^\s*<P>\s*$/;
    }

    close($handle);
    print STDERR "Finished $filename\n" if $VERBOSE;
}
##---------------------------------------------------------------------------##
sub write_home_page {
    open(PGFILE, ">>$OUTDIR/$HOMEFILE") ||
	die "Unable to create $OUTDIR/$HOMEFILE\n";

    print STDERR "Writing $HOMEFILE ...\n" if $VERBOSE;
#    &print_head(PGFILE, $DTDNAME);
    if ($ElemDesc{$HomeDesc}) {
	print PGFILE "<HR>\n";
	&print_elem_desc(PGFILE, $HomeDesc);
    }
#    &print_goto_topall(PGFILE);
    if (!$NODOCURL) {
	print PGFILE "<HR>\n";
	&print_info(PGFILE);
    }
#    &print_end(PGFILE);
    close(PGFILE);
}
##---------------------------------------------------------------------------##
sub write_tree_page {
    local(@array);

    open(PGFILE, ">>$OUTDIR/$TREEFILE") ||
	die "Unable to create $OUTDIR/$TREEFILE\n";
    print STDERR "Writing $TREEFILE ...\n" if $VERBOSE;

#    &print_head(PGFILE, "$DTDNAME: Arbo de la elementoj",
#		"$DTDNAME: <BR>Arbo de la elementoj");

    print PGFILE "<hr><h2>Strukturarbo</h2>";

    if ($TREETOP) {
	@array = split(/,/, $TREETOP);
    } else {
	@array = &DTDget_top_elements();
    }
#   if ($#array > 0) {
#	print PGFILE "<HR>\n",
#		     "<UL>\n";
#	foreach (@array) {
#	    tr/a-z/A-Z/;
#	    print PGFILE qq|<LI><A HREF="#$_">$_</A></LI>\n|;
#	}
#	print PGFILE "</UL>\n";
#    }
    foreach (@array) {
	tr/a-z/A-Z/;
#	print PGFILE "<HR>\n",
#		     "<H2><A NAME=\"$_\">$_</A></H2>\n",
#		     "<HR>\n",
	print PGFILE	     "<PRE STYLE=\"line-height: 0.6em \">\n";
	&DTDprint_tree($_, $LEVEL, "main::PGFILE");
	print PGFILE "</PRE>\n";
    }
#    &print_goto_topall(PGFILE);
#    &print_end(PGFILE);
    close(PGFILE);
}
##---------------------------------------------------------------------------##
sub write_topelem_page {
    local(@array);

    open(PGFILE, ">>$OUTDIR/$TOPFILE") ||
	die "Unable to create $OUTDIR/$TOPFILE\n";
    print STDERR "Writing $TOPFILE ...\n" if $VERBOSE;

#    &print_head(PGFILE, "$DTDNAME: plej supra(j) elemento(j)",
#			"Plej supra(j) elemento(j) en $DTDNAME");
    print PGFILE "Ple(j) supra(j) elemento(j):\n";
    @array = ($TREETOP ? split(/,/, $TREETOP) : &DTDget_top_elements());
    &print_elem_list(PGFILE, *array);
    close(PGFILE);
}
##---------------------------------------------------------------------------##
sub write_allelem_page {
    local(@array);

    open(PGFILE, ">>$OUTDIR/$ALLFILE") ||
	die "Unable to create $OUTDIR/$ALLFILE\n";
    print STDERR "Writing $ALLFILE ...\n" if $VERBOSE;

#    &print_head(PGFILE, "$DTDNAME: �iuj elementoj",
#			"�iuj elementoj en $DTDNAME");
    print PGFILE "�iuj elementoj: ";
    @array = &DTDget_elements();
    &print_elem_list(PGFILE, *array);
#    &print_goto_topall(PGFILE);
#    &print_end(PGFILE);
    close(PGFILE);
}
##---------------------------------------------------------------------------##
sub write_ents_page {
    local($tmp) = ("$OUTDIR/$ENTSFILE");

    open(PGFILE, ">>$tmp") || die "Unable to create $tmp\n";
    print STDERR "Writing $ENTSFILE ...\n" if $VERBOSE;

#    &print_head(PGFILE, "$DTDNAME: �eneralaj unuoj",
#			"�eneralaj unuoj en $DTDNAME");
    if ($ElemDesc{$EntsDesc}) {
	print PGFILE "<HR>\n";
	&print_elem_desc(PGFILE, $EntsDesc);
    }
    @array = &DTDget_gen_data_ents();
    &print_ent_list(PGFILE, *array);
#    &print_goto_topall(PGFILE);
#    &print_end(PGFILE);
    close(PGFILE);
}
##---------------------------------------------------------------------------##
sub write_elem_page {
    local($elem) = shift @_;
    local($Elem) = $elem;
    local(@array);

    open(FILE, ">>$OUTDIR/dtd.html") ||
	die "Unable to create $OUTDIR/$dtd.html\n";
    print STDERR "Writing $dtd.html ...\n" if $VERBOSE;

    print FILE "<HR><a name=\"$elem\"></a>\n";
    $Elem =~ tr/a-z/A-Z/;
#    &print_head(FILE, "$DTDNAME: Elemento $Elem", $elem);
    print FILE "<h1>$elem</h1>";
    &print_elem_desc(FILE, $elem);

    ## Parents ##
    &print_parent_list(FILE, $elem);

    ## Content ##
    print FILE "�ia enhavo estas deklarita kiel\n";

    if (&write_elem_syntax($elem,FILE)) {
	print FILE "\n";
    } else {
	print FILE "<em>malplena</em>.\n";
    }

    print FILE "\n";

    if (&write_elem_attr($elem,FILE)) {
	print FILE "<BR>\n";
    } else {
	print FILE "�i ne havas atributojn.<BR>\n";
    }

    print FILE "</P>\n";

    my $txt;
    if ($txt=$Komentoj{$elem}) {
	print FILE "<h4>komentoj</h4>\n";
	print FILE $txt;
    };

    close(FILE);
}
##---------------------------------------------------------------------------##
sub write_elem_attr {
    local($elem) = shift @_;
    local($Elem) = $elem;
    local $file = shift @_;
    local(%attr, @array, @vals, $def, $tmp);

    %attr = &DTDget_elem_attr($elem);
    @array = sort keys %attr;
    return 0 if ($#array < 0);

    $Elem =~ tr/a-z/A-Z/;

    &print_attr_desc($file, $elem);
    print $file "\n";

    foreach (@array) {
	($tmp = $_) =~ tr/a-z/A-Z/;
	print $file qq|La atributo <strong>$_</strong>\n|;
	&print_attr_sp_desc($file, $elem, $_);

	@vals = split(/$;/o, $attr{$_});
	$def = shift @vals;
	$def .= ' = ' . shift @vals if ($def =~ /^\s*$rni$FIXED\s*$/o);
	if ($#vals > 0) {

	    print $file "povas havi la valoro(j)n ";
	    
	    if ($vals[0] eq $NOTATION) {
		print $file "<CODE>", shift(@vals), "</CODE>", "\n"; }
	    &print_attr_list($file, *vals);
	} else {
	    if (&DTDis_attr_keyword($vals[0])) {
		$vals[0] =~ tr/a-z/A-Z/;
		$vals[0] = "<CODE>".$vals[0]."</CODE>";
	    }
	    print $file " estas ";
	    print $file $vals[0], "\n";
	}
	print $file "(anta�difino: \n",
		   "<code>", &htmlize($def), "</code>)\n";
    }
    1;
}
##---------------------------------------------------------------------------##
sub write_elem_syntax {
    local($elem) = shift @_;
    local($Elem) = $elem;
    local $file = shift @_;

    return 0 if $dtd::ElemCont{$elem} =~ /^\s*$EMPTY\s*$/oi;

    $Elem =~ tr/a-z/A-Z/;

    ## Content Rule ##

    @array = &DTDget_base_children($elem, 1);
    &print_elem_content($file, *array);

    ## Inclusions ##
    if ($dtd::ElemInc{$elem}) {
	print $file "<H3>Inclusions</H3>\n";
	@array = &DTDget_inc_children($elem, 1);
	&print_elem_content($file, *array);
    }
    ## Exclusions ##
    if ($dtd::ElemExc{$elem}) {
	print $file "<H3>Exclusions</H3>\n";
	@array = &DTDget_exc_children($elem, 1);
	&print_elem_content($file, *array);
    }
    1;
}
##---------------------------------------------------------------------------##
sub print_elem_content {
    local($handle, *array) = @_;
    local($prev, $open, $len, $tmp) = ('',0,0,0);

    print $handle "<code>";
    foreach (@array) {
	next if $_ eq "";	    # Ignore NULL strings
	if ($_ eq $dtd::grpo_) {	    # '('
	    if ($prev eq $_) {		# Print consecutive ('s together     '
		print $handle &htmlize($_);
	    } else {			# Else, start newline
		print $handle "\n", ' ' x $open, $_;
	    }
	    $open++;			# Increase group open counter
	    $len = $open+1;		# Adjust length of line counter
	    next;			# Goto next token
	} elsif ($_ eq $dtd::grpc_) {
	    $open--;			# ')', decrement group open counter #
	}
	$tmp = $len + length($_);
	if ($tmp > $MWIDTH) {	    # Check if line goes past $MWIDTH chars
	    if (&DTDis_occur_indicator($_) || &DTDis_group_connector($_)) {
		print $handle &htmlize($_), "\n", ' ' x ($open); 
		$len = $open;
		next;
	    } else {
		print $handle "\n", ' ' x $open; 
		$len = $open + length($_);
	    }
	} else {
	    $len = $tmp;
	}

	if ($_ eq $dtd::and_) {		# Put spaces around '&'.
	    print $handle ' ', &htmlize($_), ' ';
	    $len += 2;
	    if ($len > 70) {
		print $handle "\n", ' ' x $open;
		$len = $open;
	    }
	} elsif (!&DTDis_element($_)) {	# Uppercase reserved words, OR
					# bogus elements
	    tr/a-z/A-Z/;
	    print $handle &htmlize($_);
	} elsif (&DTDis_tag_name($_)) {	# Create anchors for element names
	    print $handle qq|<A HREF="#$_">$_</A>|;
	} else {
	    print $handle &htmlize($_);
	}

    } continue {
	$prev = $_ unless /^\s*$/;
    }

    print $handle "</code>.\n";
}
##---------------------------------------------------------------------------##
sub print_elem_desc {
    local($handle, $elem) = @_;
    $elem =~ tr/A-Z/a-z/;
    if ($elem && $ElemDesc{$elem}) {
	print $handle $ElemDesc{$elem};
    }
}
##---------------------------------------------------------------------------##
sub print_attr_desc {
    local($handle, $elem) = @_;
    local($attr);
    $elem =~ tr/A-Z/a-z/;
    $attr = $elem . '*';
    if ($elem && $ElemDesc{$attr}) {
	print $handle $ElemDesc{$attr};
    }
}
##---------------------------------------------------------------------------##
sub print_attr_sp_desc {
    local($handle, $elem, $attr) = @_;
    $elem =~ tr/A-Z/a-z/;
    $attr =~ tr/A-Z/a-z/;
    if ($elem) {
	if ($ElemDesc{"$elem*$attr"}) {		# Check for local description
	    print $handle $ElemDesc{"$elem*$attr"};
	} elsif ($ElemDesc{"\*$attr"}) { 	# Check for global description
	    print $handle $ElemDesc{"\*$attr"};
	}
    }
}
##---------------------------------------------------------------------------##
sub print_goto_topall {
    local($old) = select(shift);
    local($elem) = shift;
    local($tmp);
    print <<End;
<HR>
<P>
<A HREF="$TOPFILE"><STRONG>Top Elements</STRONG></A>
<BR>
<A HREF="$ALLFILE"><STRONG>All Elements</STRONG></A>
<BR>
End
    ## Link to entities page
    print qq|<A HREF="$ENTSFILE"><STRONG>General Entities</STRONG></A><BR>\n|
	if $ENTS;

    ## Link to tree page
    $tmp = $TREEFILE . ($elem ? "#$elem" : '');
    print qq|<A HREF="$tmp"><STRONG>Tree</STRONG></A>\n|
	if $TREE || $TREELINK;

    print "</P>\n";
    select($old);
}
##---------------------------------------------------------------------------##
sub print_attr_list {
    local($handle, *array) = @_;
#    print $handle "<UL COMPACT>\n";
    foreach (@array) {
	if (&DTDis_attr_keyword($_)) { tr/a-z/A-Z/; }
	print $handle '"'.&htmlize($_).'" ';
    }
#    print $handle "</UL>\n";
}
##---------------------------------------------------------------------------##
sub print_ent_list {
    local($handle, *array) = @_;

    print $handle "<UL>\n";
    foreach (@array) {
	next if /^\s*$/;
	print $handle qq|<LI><STRONG>$_</STRONG>|;
	print $handle qq| -- $ElemDesc{"$_&"}| if $ElemDesc{"$_&"};
	print $handle qq|</LI>\n|;
    }
    print $handle "</UL>\n";
}
##---------------------------------------------------------------------------##
sub print_elem_list {
    local($handle, *array, $hascons) = @_;

    if ($hascons) {			# Connectors in list
	local($ep, $iselem) = ('', 0);
#	print $handle "<UL>\n";
#	print $handle "<LI>";
	foreach (@array) {
	    next if /^\s*$/;
	    if (/$dtd::grpo/o) {
		if ($ep) {
		    print $handle qq| -- $ElemDesc{"$ep+"}|
			if $iselem && $ElemDesc{"$ep+"};
#		    print $handle "</LI>\n<LI>";
		    print $handle ", ";
		    $ep = ''; 
		}
		print $handle &htmlize($_);
	    } elsif (&DTDis_occur_indicator($_) ||
		     &DTDis_group_connector($_) ||
		     /$dtd::grpc/o ) {
		print $handle &htmlize($_);
	    } else {
		if ($ep) {
		    print $handle qq| -- $ElemDesc{"$ep+"}|
			if $iselem && $ElemDesc{"$ep+"};
#		    print $handle "</LI>\n<LI>";
		    print $handle ", ";
		}
		if (!&DTDis_element($_)) {
		    tr/a-z/A-Z/;
		    print $handle &htmlize($_);
		    $iselem = 0;
		} else {
		    print $handle qq|<A HREF="#$_">|,
				  qq|<STRONG>$_</STRONG></A>|;
		    $iselem = 1;
		}
		$ep = $_;
	    }
	}
	print $handle qq| -- $ElemDesc{"$ep+"}|
	    if $iselem && $ElemDesc{"$ep+"};
#	print $handle "</LI>\n</UL>\n"

    } else {				# Just the elements in list
#	print $handle "<UL>\n";
	my $n=0;
	foreach (@array) {
	    next if /^\s*$/;
	    if (!&DTDis_element($_)) {
		tr/a-z/A-Z/;
#		print $handle "<LI>", &htmlize($_), "</LI>\n";
		print $handle &htmlize($_), ", "
	    } else {
		print $handle qq|<A HREF="#$_">|,
			      qq|<STRONG>$_</STRONG></A>|;
		print $handle qq| -- $ElemDesc{"$_+"}|
		    if $ElemDesc{"$_+"};
		print $handle ($n++ < $#array)? ", " : ". ";
	    }
	}
#	print $handle "</UL>\n";
	print $handle "<p>";
    }
}
##---------------------------------------------------------------------------##
sub print_head {
    local($handle, $title, $head) = @_;
    local($old) = select($handle);
    $head = $title  unless $head;
    print <<End;
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<HEAD>
<TITLE>$title</TITLE>
</HEAD>
<BODY>
<H1>$head</H1>
End
    select($old);
}
##---------------------------------------------------------------------------##
sub print_begin {

    open(PGFILE, ">$OUTDIR/$HOMEFILE") ||
	die "Unable to create $OUTDIR/$HOMEFILE\n";

    local($old) = select(PGFILE);

    print <<End;
<HTML>
<HEAD>
<TITLE>$DTDNAME</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-3">
<link titel="artikolo-stilo" type="text/css" rel=stylesheet 
href="../stl/artikolo.css">
</HEAD>
<BODY>
<H1>$DTDNAME</H1>
End
    select($old);
    close PGFILE;
}
##---------------------------------------------------------------------------##
sub print_end {

    open(PGFILE, ">>$OUTDIR/$HOMEFILE") ||
	die "Unable to create $OUTDIR/$HOMEFILE\n";

    local($old) = select(PGFILE);

    print <<End;
<HR>
</BODY>
</HTML>
End
    select($old);
    close PGFILE;
}
##---------------------------------------------------------------------------##
sub print_info {
    local($old) = select(shift);
    print <<End;
<ADDRESS>
Dokumento kreita de <CODE>dtd2html.pl</CODE> $VERSION
</ADDRESS>
<HR>
End
    select($old);
}
##---------------------------------------------------------------------------##
sub remove_dups {
    local(*array) = shift;
    local(%dup) = ();
    @array = grep($dup{$_}++ < 1, @array);
}
##---------------------------------------------------------------------------##
sub print_entsdescfile {
    local($str);

    @ids = sort &DTDget_gen_data_ents();
    select(STDOUT);  $^ = Empty;  $~ = CenterCom;  $= = 1000000;
    $str = "General Entity Descriptions"; write;
    foreach (@ids) {
	print STDOUT "<?DTD2HTML $_& >\n";
    }
}
##---------------------------------------------------------------------------##
sub print_elemdescfile {
    local($f, *others) = @_;
    local(%attribute, @array, @ids, $elem, $attr, $str);

    @ids = sort (&DTDget_elements(), keys %others);

    ## Output Home Page description ##
    select(STDOUT);  $^ = Empty;  $~ = CenterCom;  $= = 1000000;
    $str = "Home Page Description";  write;
    print STDOUT "<?DTD2HTML $HomeDesc >\n";
    if ($f && $ElemDesc{$HomeDesc}) { print STDOUT $ElemDesc{$HomeDesc}; }

    ## Output any shared descriptions ##
    @array = sort keys %SharedDesc;
    if ($#array >= 0) {
	$str = "Shared Descriptions";  write;
	foreach $elem (sort keys %SharedDesc) {
	    print STDOUT "<?DTD2HTML $elem >\n";
	    if ($f && $SharedDesc{$elem}) { print STDOUT $SharedDesc{$elem}; }
	}
    }

    ## Output brief descriptions ##
    $str = "Short Descriptions"; write;
    foreach $elem (@ids) {
	next if $elem =~ /\*/ || $elem =~ /\+/;
	print STDOUT "<?DTD2HTML $elem+ >\n";
	if ($f && $ElemDesc{"$elem+"}) { print STDOUT $ElemDesc{"$elem+"}; }
    }

    ## Output descriptions ##
    $str = "Descriptions";  write;
    foreach $elem (@ids) {
	next  if $elem =~ /\+/;
	print STDOUT "<?DTD2HTML $elem >\n";
	if ($f && $ElemDesc{$elem} && !$SharedId{$elem}) {
	    print STDOUT $ElemDesc{$elem};
	}
	%attribute = &DTDget_elem_attr($elem);
	@array = sort keys %attribute;
	if ($#array >= 0) {
	    print STDOUT "<?DTD2HTML $elem* >\n";
	    if ($f && $ElemDesc{"$elem*"}) {
		print STDOUT $ElemDesc{"$elem*"}; }
	    foreach $attr (@array) {
		print STDOUT "<?DTD2HTML $elem*$attr >\n";
		if ($f && $ElemDesc{"$elem*$attr"}) {
		    print STDOUT $ElemDesc{"$elem*$attr"}; }
	    }
	}
	%attribute = ();
    }
}
##---------------------------------------------------------------------------##
sub update_elemdesc {
    local(@array, $elem, $attr, %attribute, %new, $str);
    local(%old);

    ## Read element description file ##
    &read_descfile($UPDATEEL);
    foreach (grep(/&/, keys %ElemDesc)) { delete $ElemDesc{$_}; }
    %old = %ElemDesc;

    ## Check for Home Page description ##
    if (!defined($ElemDesc{$HomeDesc})) { $new{$HomeDesc} = 1; }
    else { delete $old{$HomeDesc}; }

    ## Check for new elements and old descriptions ##
    foreach $elem (&DTDget_elements()) {
	## Check elements
	if (!defined($ElemDesc{$elem})) { $new{$elem} = 1; }
	else { delete $old{$elem}; }
	delete $old{"$elem+"};

	## Check attributes
	%attribute = &DTDget_elem_attr($elem);
	@array = keys %attribute;
	if ($#array >= 0) {
	    if (!defined($ElemDesc{"$elem*"})) { $new{"$elem*"} = 1; }
	    else { delete $old{"$elem*"}; }
	    foreach $attr (@array) {
		if (!defined($ElemDesc{"$elem*$attr"})) {
		    $new{"$elem*$attr"} = 1; }
		else { delete $old{"$elem*$attr"}; }
	    }
	}
	%attribute = ();
    }

    ## Output status report of updating element description file ##
    if (!$NOREPORT) {
	local($delold, $date) = (($KEEPOLD ? "No" : "Yes"), `date`);
	select(STDOUT);  $^ = ReportTop;  $= = 1000000;
	@array = sort keys %new;
	if ($#array >= 0) {
	    $~ = ReportLine;
	    $str = "New identifiers:";  write;
	    $~ = ReportIds;
	    $str = join(', ', @array);  while ($str) { write; }
	    # foreach (@array) { $str = "  $_"; write; }
	}
	@array = grep(!/^\*/, sort keys %old);	# Ignore global attr ids
	if ($#array >= 0) {
	    $~ = ReportLine;
	    $str = "Old identifiers:";  write;
	    $~ = ReportIds;
	    $str = join(', ', @array);   while ($str) { write; }
	    # foreach (@array) { $str = "  $_"; write; }
	}
	$~ = ReportLine;
	$str = "";  write;
    }

    ## Output descriptions ##
    if (!$RPRTONLY) {
	grep(!/^\*/ && delete $old{$_}, keys %old) unless $KEEPOLD;
	&print_elemdescfile(1, *old);
    }
}
##---------------------------------------------------------------------------##
sub print_parent_list {
    local($handle, $elem) = @_;
    local(@array);

    print $handle "La elemento <em>$elem</em> povas okazi en\n";
    @array = &DTDget_parents($elem);
    if ($#array >= 0) {
	&remove_dups(*array);
#	print $handle "<UL COMPACT>\n";
	my $n=0;
	foreach (@array) {
	    tr/A-Z/a-z/;
	    print $handle qq|<A HREF="#$_">|,
			  qq|$_</A>|;
	    print $handle qq| -- $ElemDesc{"$_+"}|
		if $ElemDesc{"$_+"};
	    print $handle ($n++ < $#array)? ", " : ". "; 
#	    print $handle qq|</LI>\n|;
	}
#	print $handle "</UL>\n";
    } else {
	print $handle "neniu alia elemento.\n";
    }
}
##---------------------------------------------------------------------------##
sub write_qref {
    local($elem);

    &read_descfile($DESCFILE);
#    &print_head(STDOUT, "$DTDNAME Quick Reference");
    if ($ElemDesc{$HomeDesc}) { print STDOUT $ElemDesc{$HomeDesc}; }
    print STDOUT "<HR>\n";
    print STDOUT "<DL>\n"  if $QREFDL;
    foreach $elem (&DTDget_elements()) {
	if ($QREFDL) { print STDOUT "<DT>"; }
	else { print STDOUT $QHb; }
	print STDOUT qq|<A NAME="$elem">&lt;$elem&gt;</A>|;
	if ($QREFDL) { print STDOUT "\n<DD>"; }
	else { print STDOUT $QHe; }
	print STDOUT "\n", $ElemDesc{$elem}, "\n";
    }
    print STDOUT "</DL>\n"  if $QREFDL;
#    &print_end(STDOUT);
}
##---------------------------------------------------------------------------##
sub htmlize {
    local($string) = shift;
    $string =~ s/\&/\&amp;/g;
    $string =~ s/</\&lt;/g;
    $string =~ s/>/\&gt;/g;
    $string;
}
##---------------------------------------------------------------------------##
sub usage {
    print STDOUT <<EndOfUsage;
Usage: $PROG [<options>] file 
Options:
  -allfile <filename>   : Filename for All Elements page.
                    (def: ALL-ELEM.html)
  -contnosort           : Base content list is in order of model declaration.
  -descfile <filename>  : Element description file.
  -docurl <URL>         : URL to dtd2html HTML document.
                    (def: http://www.oac.uci.edu/indiv/ehood/dtd2html.html)
  -dtdname <string>     : String name of DTD for HTML output; " DTD" is
			  appended to <string>.
  -elemlist             : Generate empty element description file.
  -ents                 : Create a general entities page.
  -entsfile <filename>  : Filename of general entities page.
  -entslist             : Generate empty entity list for use in a description
                          file.
  -help                 : This usage message.
  -homefile <filename>  : Filename for Home page.
                    (def: DTD-HOME.html)
  -keepold              : Keep old descriptions if -updateel specified.
  -level <#>            : Cutoff level for tree.
                    (def: 15)
  -mapfile <filename>   : Catalog file for mapping public identifiers and
			  entities to system files.
                    (def: map.txt)
  -modelwidth <#>       : Maximum output width for content model declarations.
                    (def: 65)
  -nodocurl             : Do not put link to $PROG doc on home page.
  -noreport             : No report generated if -updateel specified.
  -outdir <path>        : Destination directory for HTML files.
                    (def: ./)
  -qref                 : Output quick reference.
  -qrefdl               : Output quick reference in a <DL>, implies -qref.
  -qrefhtag <string>    : Header tag for element name in qref.
                    (def: H2)
  -reportonly           : Only output report if -updateel specified.
  -topfile <filename>   : Filename for Top Elements page.
                    (def: TOP-ELEM.html)
  -tree                 : Create tree file.
  -treelink             : Create link to tree in HTML pages, regardless.
  -treefile <filename>  : Filename of Tree page.
                    (def: DTD-TREE.html)
  -treeonly             : Just output the Tree page; implies -tree.
  -treetop <string>     : Comma separated list of top elements for tree;
			  overrides computed top elements.
  -updateel <filename>  : Update an element description file; update
			  sent to stdout (NOTE: entities are not computed).
  -verbose              : Print out what's going on (generates much output);
			  mainly used for debugging purposes.

Version: $VERSION
dtd.pm Version: $dtd'VERSION

  Copyright (C) 1994  Earl Hood, ehood\@convex.com
  dtd2html comes with ABSOLUTELY NO WARRANTY and dtd2html may be copied only
  under the terms of the GNU General Public License (version 2, or later),
  which may be found in the distribution.

EndOfUsage
    exit 0;
}
##---------------------------------------------------------------------------##
##	Formats
##
format ReportTop=
<!-- Element Description File Update				          -->
<!-- Source File:  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<    -->
$UPDATEEL
<!-- Source DTD:  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<    -->
$DTDFILE
<!-- Deleting Old?  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<    -->
$delold
<!-- Date:  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<    -->
$date
.

format ReportLine=
<!-- @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<    -->
$str
.

format ReportIds=
<!--    ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<    -->
$str
.

format CenterCom=
<!-- #################################################################### -->
<!-- ## @||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| ## -->
$str
<!-- #################################################################### -->
.

format Empty=
.
