#!/usr/bin/perl

#
# redaktu.pl
# 
# 2008-10-30 Wieland Pusch
#

use strict;

use CGI qw(:standard *table);
use CGI::Carp qw(fatalsToBrowser);
use DBI();
use IPC::Open3;
use Encode;
use Text::Tabs;

# propraj perl moduloj estas en:
use lib("/var/www/web277/files/perllib");
use revo::decode;
use revo::encode;
use revo::wrap;
use revodb;

$| = 1;

my $homedir = "/var/www/web277";
my $revo_base    = "$homedir/html/revo";

$ENV{'LD_LIBRARY_PATH'} = '/var/www/web277/files/lib';
$ENV{'PATH'} = "$ENV{'PATH'}:/var/www/web277/files/bin";
autoEscape(0);

my $JSCRIPT=<<'END';
function str_repeat(repeatString, repeatNum) {
    var newString = "";
    for (var x=1; x<=repeatNum; x++) {
        newString = newString + repeatString;
    }
    return (newString);
} 

function str_indent() {
  var txtarea;
  if (document.f) {
    txtarea = document.f.xmlTxt;
  } else {
	// some alternate form? take the first one we can find
	var areas = document.getElementsByTagName('textarea');
	txtarea = areas[0];
  }
  var indent = 0;
  if (document.selection  && document.selection.createRange) { // IE/Opera
		var range = document.selection.createRange();
                range.moveStart('character', - 200); 
		var selText = range.text;
	        var linestart = selText.lastIndexOf("\n");
	        while (selText.charCodeAt(linestart+1+indent) == 32) {
                  indent++;
	        }
  } else if (txtarea.selectionStart || txtarea.selectionStart == '0') { // Mozilla
		var startPos = txtarea.selectionStart;
                var linestart = txtarea.value.substring(0, startPos).lastIndexOf("\n");
	        while (txtarea.value.substring(0, startPos).charCodeAt(linestart+1+indent) == 32) {
                  indent++;
	        }
  }
  return (str_repeat(" ", indent));
}

function cxigi(before, key) {
  var nova = ""
  if (before == 's') nova = '\u015D';
  else if (before == '\u015D') nova = 's'+String.fromCharCode(key);
  else if (before == 'S'     ) nova = '\u015C';
  else if (before == '\u015C') nova = 'S'+String.fromCharCode(key);

  else if (before == 'c'     ) nova = '\u0109';
  else if (before == '\u0109') nova = 'c'+String.fromCharCode(key);
  else if (before == 'C'     ) nova = '\u0108';
  else if (before == '\u0108') nova = 'C'+String.fromCharCode(key);

  else if (before == 'h'     ) nova = '\u0125';
  else if (before == '\u0125') nova = 'h'+String.fromCharCode(key);
  else if (before == 'H'     ) nova = '\u0124';
  else if (before == '\u0124') nova = 'H'+String.fromCharCode(key);

  else if (before == 'g'     ) nova = '\u011D';
  else if (before == '\u011D') nova = 'g'+String.fromCharCode(key);
  else if (before == 'G'     ) nova = '\u011C';
  else if (before == '\u011C') nova = 'G'+String.fromCharCode(key);

  else if (before == 'u'     ) nova = '\u016D';
  else if (before == '\u016D') nova = 'u'+String.fromCharCode(key);
  else if (before == 'U'     ) nova = '\u016C';
  else if (before == '\u016C') nova = 'U'+String.fromCharCode(key);

  else if (before == 'j'     ) nova = '\u0135';
  else if (before == '\u0135') nova = 'j'+String.fromCharCode(key);
  else if (before == 'J'     ) nova = '\u0134';
  else if (before == '\u0134') nova = 'J'+String.fromCharCode(key);

  return nova;
}

function klavo(event) {
    var key = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
    if (key == 13) {
	var txtarea;
	if (document.f) {
		txtarea = document.f.xmlTxt;
	} else {
		// some alternate form? take the first one we can find
		var areas = document.getElementsByTagName('textarea');
		txtarea = areas[0];
	}
	var selText, isSample = false;

	if (document.selection  && document.selection.createRange) { // IE/Opera
		//save window scroll position
		if (document.documentElement && document.documentElement.scrollTop)
			var winScroll = document.documentElement.scrollTop
		else if (document.body)
			var winScroll = document.body.scrollTop;
		//get current selection  
		txtarea.focus();
		var range = document.selection.createRange();
		selText = range.text;

		range.text = "\n" + str_indent();
		//mark sample text as selected
		range.select();   
		//restore window scroll position
		if (document.documentElement && document.documentElement.scrollTop)
			document.documentElement.scrollTop = winScroll
		else if (document.body)
			document.body.scrollTop = winScroll;
                return false;
 	} else if (txtarea.selectionStart || txtarea.selectionStart == '0') { // Mozilla
		//save textarea scroll position
		var textScroll = txtarea.scrollTop;
		//get current selection
		txtarea.focus();
		var startPos = txtarea.selectionStart;
		var endPos = txtarea.selectionEnd;
                var tmpstr = "\n" + str_indent();
		txtarea.value = txtarea.value.substring(0, startPos)
			+ tmpstr
			+ txtarea.value.substring(endPos, txtarea.value.length);
		txtarea.selectionStart = startPos + tmpstr.length;
		txtarea.selectionEnd = txtarea.selectionStart;
		//restore textarea scroll position
		txtarea.scrollTop = textScroll;
                return false;
       }
    } else if (key == 88 || key == 120) {   // X or x
      if (event.altKey) {	// shortcut alt-x  --> toggle cx
        document.f.cx.checked = !document.f.cx.checked;
        return false;
      }

      if (!document.f.cx.checked) {
        return true;
      }
      var txtarea;
      if (document.f) {
      	txtarea = document.f.xmlTxt;
      } else {
      	// some alternate form? take the first one we can find
      	var areas = document.getElementsByTagName('textarea');
      	txtarea = areas[0];
      }
      if (document.selection  && document.selection.createRange) { // IE/Opera
	//save window scroll position
	if (document.documentElement && document.documentElement.scrollTop)
		var winScroll = document.documentElement.scrollTop
	else if (document.body)
		var winScroll = document.body.scrollTop;
	//get current selection  
	txtarea.focus();
	var range = document.selection.createRange();
	var selText = range.text;
        if (selText != "") {
          return true;
        }
        range.moveStart('character', - 1); 
	var before = range.text;
        var nova = cxigi(before, key);
        if (nova != "") {
          range.text = nova;
          return false;
        }
      } else if (txtarea.selectionStart || txtarea.selectionStart == '0') { // Mozilla
	var startPos = txtarea.selectionStart;
	var endPos = txtarea.selectionEnd;
        if (startPos != endPos || startPos == 0) { return true; }
        var before = txtarea.value.substring(startPos - 1, startPos);
        var nova = cxigi(before, key);
        if (nova != "") {
	  //save textarea scroll position
	  var textScroll = txtarea.scrollTop;
	  txtarea.value = txtarea.value.substring(0, startPos - 1)
		+ nova
		+ txtarea.value.substring(endPos, txtarea.value.length);
	  txtarea.selectionStart = startPos + nova.length - 1;
	  txtarea.selectionEnd = txtarea.selectionStart;
	  //restore textarea scroll position
	  txtarea.scrollTop = textScroll;
          return false;
        }
      }
    } else if (key == 84 || key == 116) {   // T or t
      if (event.altKey) {	// shortcut alt-t  --> trd
        insertTags2('<trd lng="',document.getElementById('trdlng').value,'">','</trd>','');
      }
    }
}

function insertTags2(tagOpen, tagAttr, tagEndOpen, tagClose, sampleText) {
  if (tagAttr == "") {
    insertTags(tagOpen, tagEndOpen+tagClose, sampleText)
  } else {
    insertTags(tagOpen+tagAttr+tagEndOpen, tagClose, sampleText)
  }
}

// apply tagOpen/tagClose to selection in textarea,
// use sampleText instead of selection if there is none
function insertTags(tagOpen, tagClose, sampleText) {
	var txtarea;
	if (document.f) {
		txtarea = document.f.xmlTxt;
	} else {
		// some alternate form? take the first one we can find
		var areas = document.getElementsByTagName('textarea');
		txtarea = areas[0];
	}
	var selText, isSample = false;

	if (document.selection  && document.selection.createRange) { // IE/Opera
		//save window scroll position
		if (document.documentElement && document.documentElement.scrollTop)
			var winScroll = document.documentElement.scrollTop
		else if (document.body)
			var winScroll = document.body.scrollTop;
		//get current selection  
		txtarea.focus();
		var range = document.selection.createRange();
		selText = range.text;
		//insert tags
		checkSelectedText();
		range.text = tagOpen + selText + tagClose;
		//mark sample text as selected
		if (isSample && range.moveStart) {
			if (window.opera)
				tagClose = tagClose.replace(/\n/g,'');
			range.moveStart('character', - tagClose.length - selText.length); 
			range.moveEnd('character', - tagClose.length); 
		}
		range.select();   
		//restore window scroll position
		if (document.documentElement && document.documentElement.scrollTop)
			document.documentElement.scrollTop = winScroll
		else if (document.body)
			document.body.scrollTop = winScroll;

	} else if (txtarea.selectionStart || txtarea.selectionStart == '0') { // Mozilla

		//save textarea scroll position
		var textScroll = txtarea.scrollTop;
		//get current selection
		txtarea.focus();
		var startPos = txtarea.selectionStart;
		var endPos = txtarea.selectionEnd;
		selText = txtarea.value.substring(startPos, endPos);
		//insert tags
		checkSelectedText();
		txtarea.value = txtarea.value.substring(0, startPos)
			+ tagOpen + selText + tagClose
			+ txtarea.value.substring(endPos, txtarea.value.length);
		//set new selection
		if (isSample) {
			txtarea.selectionStart = startPos + tagOpen.length;
			txtarea.selectionEnd = startPos + tagOpen.length + selText.length;
		} else {
			txtarea.selectionStart = startPos + tagOpen.length + selText.length + tagClose.length;
			txtarea.selectionEnd = txtarea.selectionStart;
		}
		//restore textarea scroll position
		txtarea.scrollTop = textScroll;
	} 

	function checkSelectedText(){
		if (!selText) {
			selText = sampleText;
			isSample = true;
		} else if (selText.charAt(selText.length - 1) == ' ') { //exclude ending space char
			selText = selText.substring(0, selText.length - 1);
			tagClose += ' '
		} 
	}
}

function sf(pos, line, lastline) {
  document.f.xmlTxt.focus();
  var txtarea;
  if (document.f) {
    txtarea = document.f.xmlTxt;
  } else {
    // some alternate form? take the first one we can find
    var areas = document.getElementsByTagName('textarea');
    txtarea = areas[0];
  }
  if (document.selection  && document.selection.createRange) { // IE/Opera
    var range = document.selection.createRange();
    range.moveEnd('character', pos); 
    range.moveStart('character', pos); 
    range.select();
    range.scrollIntoView(true);
  } else if (txtarea.selectionStart || txtarea.selectionStart == '0') { // Mozilla
    txtarea.selectionStart = pos;
    txtarea.selectionEnd = txtarea.selectionStart;
    var scrollTop = txtarea.scrollHeight * line / lastline;
//    alert("scrollTop="+scrollTop);
    txtarea.scrollTop = scrollTop;
  }
}
END

my @cookies;
push @cookies, cookie(-name=>'redaktanto', -value => param('redaktanto')) if param('redaktanto');
push @cookies, cookie(-name=>'trdlng',     -value => param('trdlng'))     if param('trdlng');
push @cookies, cookie(-name=>'klrtip',     -value => param('klrtip'))     if param('klrtip');
push @cookies, cookie(-name=>'reftip',     -value => param('reftip'))     if param('reftip');
push @cookies, cookie(-name=>'sxangxo',    -value => param('sxangxo'))    if param('sxangxo');
push @cookies, cookie(-name=>'cx',         -value => param('cx') || 0 );

my $debugmsg;
my $art = param('art');
#$debugmsg .= "art = $art\n";
my $xml;
my $xmlTxt = param('xmlTxt');
if ($xmlTxt) {
  $xmlTxt =~ s/\r\n/\n/g;
  $xmlTxt = revo::wrap::wrap($xmlTxt);
  $debugmsg .= "wrap -> $xmlTxt\n <- end wrap";
}
my $xml2 = revo::encode::encode2($xmlTxt, 20) if $xmlTxt;

#$debugmsg .= "xmlTxt = $xmlTxt\n";

if ($xml2) {
  $xml = $xmlTxt;
} else {
#  $debugmsg .= "open\n";
  open IN, "<", "$homedir/html/revo/xml/$art.xml" or die "open";
  $xml = join '', <IN>;
  close IN;
  $xml = revo::decode::rvdecode($xml);
}
my $enc = "utf-8";
$xml = Encode::decode($enc, $xml);
my $sxangxo = Encode::decode($enc, param('sxangxo'));
my $redaktanto = param('redaktanto') || cookie(-name=>'redaktanto') || 'via registrita retposxta adreso';
my $mrk = param('mrk');
my ($pos, $line, $lastline) = (0, 0, 1);
my ($prelines, $postlines);
my $debug = $redaktanto eq 'wielandp@yahoo.de';

my ($checklng, $checkxml, $errline, $errchar);
($checkxml, $errline, $errchar) = checkxml($xml2) if $xml2;
#$debugmsg .= "errline = $errline\n";

if ($errline) {
  $errline--;
  $errchar--;
  if ($xml =~ m/^([^\n]*\n){$errline}[^\n]{$errchar}/smg) {
    my @prelines = split "\n", $&;
    $postlines = split "\n", $';

    my @pre = Text::Tabs::expand(@prelines);
    $pos = length(join "\n", @pre);
    $prelines = $#prelines;

    $line = $prelines - 10;
    $lastline = $prelines + $postlines + 30 - 25;
  } else {
#    $debugmsg .= "Ne trovis linio/pos $errline/$errchar\n";
    $line = $lastline = 100;
    my @prelines = split "\n", $xml;
    my @pre = Text::Tabs::expand(@prelines);
    $pos = length(join "\n", @pre);
  }
} else {
  my %lng;
  open IN, "<../revo/cfg/lingvoj.xml" or die "ne povas malfermi lingvoj.xml";
  while (<IN>) {
    if (/<lingvo kodo="([^"]+)">([^<]+)<\/lingvo>/) {
#      $debugmsg .= "lng $1 -> $2\n";
      $lng{$1} = 1;
    }
  }
  close IN;

  while ($xml =~ m/(<(?:trd|dxxxrv) lng=")(.*?)">/smg) {
    if (!exists($lng{$2})) {
      $checklng = "Nekonata lingvo $2.";
#      $debugmsg .= "lng = $2\n";
      my @prelines = split "\n", "$`$1$2";
      $postlines = split "\n", $';

      my @pre = Text::Tabs::expand(@prelines);
      $pos = length(join "\n", @pre);
      $prelines = $#prelines;
      $line = $prelines - 20;
      $lastline = $prelines + $postlines + 20 - 25;
      last;
    }
  }

  if (!$pos and $xml =~ m/<(snc|drv)( mrk="$mrk".*?)(\n?\s*<\/\1>)/smg) {
    my @prelines = split "\n", "$`$1$2";
    $postlines = split "\n", "$3$'";

    my @pre = Text::Tabs::expand(@prelines);
    $pos = length(join "\n", @pre);
    $prelines = $#prelines;
#    $debugmsg .= "prelines = $prelines\n";

    $pos++;
    $line = $prelines - 20;
    $lastline = $prelines + $postlines + 20 - 25;
  }

}
$line = 0 if $line < 0;
$line = $lastline if $line > $lastline;
$lastline = 1 unless $lastline;
#$debugmsg .= "line = $line\n";

print header(-charset=>'utf-8', -cookie=>\@cookies),
      start_html(-style=>{-src=>'/revo/stl/indeksoj.css'},
                 -title=>"redakti $art",
                 -script=>$JSCRIPT,
                 -onLoad=>"sf($pos, $line, $lastline)"
);

print h1("Redakti $art");
#my $referer =$ENV{HTTP_REFERER};
#print pre("pos=$pos, referer=$referer\n") if $debug;
#print pre("pre=".escapeHTML($prelines)."  post=".escapeHTML($postlines)."  lines=".($prelines + $postlines));
#print pre("pre=".escapeHTML($line)."  post=".escapeHTML($lastline)."  div=".($line / $lastline));

if ($debug and $debugmsg) {
  autoEscape(1);
  print pre(escapeHTML($debugmsg));
  autoEscape(0);
}

my $ne_savu;

print <<'EOD' if 0;
<div class="borderc8 backgroundc1" style="border-style: solid; border-width: medium; padding: 0.3em 0.5em;">
<p><span style="color: rgb(207, 118, 6); font-size: 140%;"><b>Provversio</b></span></p>
<p>Momente tio pagxo estas nur por elprovi</p>
<p><i>Viaj &#349;angxoj momente estas sendata al vi kaj al la auxtoro (sendepende de la subaj butonoj) !</i></p>
</div><br>
EOD


my %fak = ('' => '');
open IN, "<../revo/cfg/fakoj.xml" or die "ne povas malfermi lingvoj.xml";
while (<IN>) {
  if (/<fako kodo="([^"]+)"[^>]*>([^<]+)<\/fako>/i) {
#    $debugmsg .= "lng $1 -> $2\n";
#    print "fak $1 $2<br>\n";
    $fak{$1} = $2;
  }
}
close IN;

# Connect to the database.
my $dbh = revodb::connect();

#print pre('dbconnect'." size=".length($xml2)) if $debug;

if (param('button') eq 'antaŭrigardu' or param('button') eq 'savu') {

print <<'EOD';
<div class="borderc8 backgroundc1" style="border-style: solid; border-width: medium; padding: 0.3em 0.5em;">
<p><span style="color: rgb(207, 118, 6); font-size: 140%;"><b>Anta&#365;rigardo</b></span></p>
EOD
#  print pre('open xalan') if $debug;
  if (length($xml2) > 28000) {
    print h2("artikolo estas tro granda por antauxrigardo");
  } else {
    my $pid = IPC::Open3::open3(\*CHLD_IN, \*CHLD_OUT, \*CHLD_ERR,
                      "xalan -XSL $homedir/html/revo/xsl/revohtml.xsl");
    print CHLD_IN $xml2;
    close CHLD_IN;
    my $err = join('', <CHLD_ERR>);
#    print pre("err=$err");
    close CHLD_ERR;
    my $html = join('', <CHLD_OUT>);
    close CHLD_OUT;

#    open IN, "<", "$homedir/html/revo/art/$art.html" or die "open";
#    my $html = join '', <IN>;
#    close IN;

    $html =~ s#href="../stl/#href="/revo/stl/#smg;
    $html =~ s#src="../smb/#src="/revo/smb/#smg;
    $html =~ s#src="../bld/#src="/revo/bld/#smg;
    $html =~ s#<span class="redakto">.*$##sm;

    print $html;
#    print pre('close xalan') if $debug;
  }
print <<'EOD';
</div><br>
EOD


print <<'EOD';
<div class="borderc8 backgroundc1" style="border-style: solid; border-width: medium; padding: 0.3em 0.5em;">
<p><span style="color: rgb(207, 118, 6); font-size: 140%;"><b>
EOD
  print $checkxml.br."\n";

  print $checklng.br.br."\n" if $checklng;

  while ($xml2 =~ /<ref([^g>][^>]*)>/gi) {
    my $ref = $1;
#    print "ref = $ref<br>\n" if $debug;
    if ($ref !~ /cel="([^"]+?)"/i) {
      autoEscape(1);
      print escapeHTML("Referenco <ref$ref>")." ne havas cel a&#365; la celo estas malplena.<br>\n";
      autoEscape(0);
#      print "ref = $ref<br>\n";
#      $ne_savu = 9;
    }
  }

  my $sth = $dbh->prepare("SELECT count(*) FROM art WHERE art_amrk = ?");
  my $sth2 = $dbh->prepare("SELECT drv_mrk FROM drv WHERE drv_mrk = ? union SELECT snc_mrk FROM snc WHERE snc_mrk = ?");
  while ($xml2 =~ /<ref [^>]*?cel="([^".]*)(\.)([^"]*?)">/gi) {
    my ($art, $mrk) = ($1, "$1$2$3");
    $sth->execute($art);
    my ($art_ekzistas) = $sth->fetchrow_array();
    if (!$art_ekzistas) {
#      print "ref = $1-$2 $art-$mrk<br>\n" if $debug;
      print "Referenco celas al dosiero \"$art.xml\", kiu ne ekzistas.<br>\n";
#      $ne_savu = 7;
    } elsif ($2) {
      $sth2->execute($mrk, $mrk);
      my ($mrk_ekzistas) = $sth2->fetchrow_array();
      if (!$mrk_ekzistas) {
        print "ref: art=$art mrk=$mrk<br>\n" if $debug;
        print "Referenco celas al \"$mrk\", kiu ne ekzistas en dosiero \"$art.xml\".<br>\n";
#        $ne_savu = 8;
      }
    }
  }
  $sth->finish;

  while ($xml2 =~ /<uzo tip="fak">(.*?)<\/uzo>/gi) {
    my $fako = $1;
    if (! exists($fak{$fako})) {
      print "Fako $fako estas nekonata.<br>\n";
      $ne_savu = 6;
    }
  }

  while ($xml2 =~ /<(drv|snc) mrk="(.*?)">/gi) {
    my $mrk = $2;
    if ($mrk !~ /^$art\.[^.0]*0/) {
      print "La marko \"$mrk\" ne komencas per \"$art.\" a&#365; poste ne havas 0.<br>\n";
      $ne_savu = 5;
    }
  }

  my $flag = 0;
  $flag = $sxangxo =~ s/\x{0109}/cx/g || $flag;
  $flag = $sxangxo =~ s/\x{0108}/Cx/g || $flag;
  $flag = $sxangxo =~ s/\x{0135}/jx/g || $flag;
  $flag = $sxangxo =~ s/\x{0134}/Jx/g || $flag;
  $flag = $sxangxo =~ s/\x{0125}/hx/g || $flag;
  $flag = $sxangxo =~ s/\x{0124}/Hx/g || $flag;
  $flag = $sxangxo =~ s/\x{016D}/ux/g || $flag;
  $flag = $sxangxo =~ s/\x{016C}/Ux/g || $flag;
  $flag = $sxangxo =~ s/\x{015D}/sx/g || $flag;
  $flag = $sxangxo =~ s/\x{015C}/Sx/g || $flag;
  $flag = $sxangxo =~ s/\x{011D}/gx/g || $flag;
  $flag = $sxangxo =~ s/\x{011C}/Gx/g || $flag;
  if ($flag) {
    print "Esperantaj signoj malunikodita.<br>\n";
  }
  if ($sxangxo =~ s/([\x{80}-\x{10FFFF}]+)/<span style="color:red">$1<\/span>/g) { # kororigu ne-askiajn signojn
    print "Eraro: teksto havas ne-askiaj signoj: $sxangxo".br."\n";
    $ne_savu = 3;
  } else {
    if ($sxangxo) {
      print "teksto en ordo: $sxangxo".br."\n";
    } else {
      print "Eraro: teksto mankas $sxangxo".br."\n";
      $ne_savu = 4;
    }
  }
print <<'EOD';
</div><br>
EOD
}

if ($redaktanto) {
  my $sth = $dbh->prepare("SELECT count(*) FROM email WHERE ema_email = ?");
  $sth->execute($redaktanto);
  my ($permeso) = $sth->fetchrow_array();
  $sth->finish;

  if (!$permeso) {
    $ne_savu = 2;

    print <<"EOD";
<div class="borderc8 backgroundc1" style="border-style: solid; border-width: medium; padding: 0.3em 0.5em;">
<p>Vi ($redaktanto) ne estas registrita kiel redaktanto !</p>
<p>Legu <a href="http://www.reta-vortaro.de/revo/dok/redinfo.html">&#265;i tie</a> kaj 
  <a href="http://www.reta-vortaro.de/revo/dok/revoserv.html">&#265;i tie</a> kiel registri.</p>
<p><i>Viaj &#349;an&#285;oj ne estos savitaj !</i></p>
</div><br>
EOD
  }

  if (param('button') eq 'savu') {
    print <<'EOD';
<div class="borderc8 backgroundc1" style="border-style: solid; border-width: medium; padding: 0.3em 0.5em;">
<p><span style="color: rgb(207, 118, 6); font-size: 140%;"><b>
EOD
    print "Savo</b></span></p>\n";
    # $xml2
    if ($ne_savu) {
      print "ne savita";
    } else {
      my $from    = $redaktanto;
      my $name    = "Revo redaktu.pl";
      my @to;
      push @to, $redaktanto if param('sendu_al_tio');
      push @to, 'revo@retavortaro.de' if param('sendu_al_revo');
      push @to, 'wieland@wielandpusch.de' if param('sendu_al_admin');  # revodb::mail_to
      if (my $to = join(', ', @to)) {
        my $subject = "Revo redaktu.pl $art";

        # konektu al retposxtservilo
        open SENDMAIL, "| /usr/sbin/sendmail -t 2>&1 >sendmail.log" or print LOG "ne povas sendmail\n";
        print SENDMAIL <<End_of_Mail;
From: $name <$from>
To: $to
Reply-To: $from
Subject: $subject
X-retadreso: $ENV{REMOTE_ADDR}

redakto: $sxangxo

$xml2
End_of_Mail
      close SENDMAIL;

      print "sendita al $to";
    } else {
      print "ne sendita, elektu adreson sube";
    }
  }
print <<'EOD';
</div><br>
EOD
  }
}

$dbh->disconnect() if $dbh;

#print form
#<form id="f" name="f" method="post" action="/w/index.php?title=Sandbox&amp;action=submit" enctype="multipart/form-data"><div id="antispam-containter" style="display: none;">
print start_form(-id => "f", -name => "f"  #, -method => 'post',
);

my @fakoj = sort keys %fak;
print "\n&nbsp;aldoni:\n".
      " <a onclick=\"var i=str_indent();insertTags(&#39;<drv mrk=\\&#34;$art.&#39;,&#39;\\&#34;>\\n&#39;+i+&#39;  <kap><tld/>...</kap>\\n&#39;+i+&#39;  <snc mrk=\\&#34;$art.\\&#34;>\\n&#39;+i+&#39;    <dif>\\n&#39;+i+&#39;      \\n&#39;+i+&#39;    </dif>\\n&#39;+i+&#39;    \\n&#39;+i+&#39;  </snc>\\n&#39;+i+&#39;</drv>&#39;,&#39;&#39;);return false\" href=\"#\">[drv]</a>\n",
      " <a onclick=\"var i=str_indent();insertTags(&#39;<dif>\\n&#39;+i+&#39;  &#39;,&#39;\\n&#39;+i+&#39;</dif>&#39;,&#39;&#39;);return false\" href=\"#\">[dif]</a>\n",
      " <a onclick=\"var i=str_indent();insertTags(&#39;<snc mrk=\\&#34;$art.&#39;,&#39;\\&#34;>\\n&#39;+i+&#39;  <dif>\\n&#39;+i+&#39;    \\n&#39;+i+&#39;  </dif>\\n&#39;+i+&#39;</snc>&#39;,&#39;&#39;);return false\" href=\"#\">[snc]</a>\n",
      " <a onclick=\"insertTags2(&#39;<uzo tip=\\&#34;fak\\&#34;>&#39;,document.getElementById(&#34;uzofak&#34;).value,&#39;</uzo>&#39;,&#39;&#39;,&#39;&#39;);return false\" href=\"#\">[fak]</a> ",
      "\n fak=".popup_menu(-id=>'uzofak',
		    -name    => 'uzofak',
                    -values  => \@fakoj,
		    -default => '',
		    -labels  => %fak,
      )."\n ",
      " <a onclick=\"insertTags2(&#39;<ref tip=\\&#34;&#39;,document.getElementById(&#34;reftip&#34;).value,&#39;\\&#34; cel=\\&#34;&#39;,&#39;\\&#34;></ref>&#39;,&#39;&#39;);return false\" href=\"#\">[ref tip]</a> ",
      "\n tip=".popup_menu(-id=>'reftip',
		    -name=>'reftip',
                    -values=>['', qw/vid hom dif sin ant super sub prt malprt lst ekz/],
		    -default=>'',
		    -labels=>{'vid'=>'vid-u',
                              'hom'=>'hom-onima',
                              'dif'=>'dif-ina',
                              'sin'=>'sin-onimo',
                              'ant'=>'ant-onimo',
                              'super'=>'super-nocio',
                              'sub'=>'sub-nocio',
                              'prt'=>'part-o',
                              'malprt'=>'malpart-o',
                              'ekz'=>'ekz-emplo',
		    },
#                    -size => 2,
#                    -maxlength => 3,
#                    -value=> cookie(-name=>'reftip') || '',
      )."\n ",
      " <a onclick=\"var i=str_indent();insertTags(&#39;<rim>\\n&#39;+i+&#39;  &#39;,&#39;\\n&#39;+i+&#39;</rim>&#39;,&#39;&#39;);return false\" href=\"#\">[rim]</a>\n",
      "&nbsp; &nbsp; ".a({target=>"_new", href=>'/revo/dok/manlibro.html#drv'}, "[helpo]")."\n ".
      a({target=>"_new", href=>'/revo/dok/dtd.html#drv'}, "[dtd]")."\n".
      br.
      "\n&nbsp;ekzemplo:\n".
      " <a onclick=\"var i=str_indent();insertTags(&#39;<ekz>\\n&#39;+i+&#39;  &#39;,&#39;\\n&#39;+i+&#39;</ekz>&#39;,&#39;&#39;);return false\" href=\"#\">[ekz]</a>\n",
      " <a onclick=\"insertTags(&#39;<tld/>&#39;,&#39;&#39;,&#39;&#39;);return false\" href=\"#\">[tld]</a>\n",
      " <a onclick=\"var i=str_indent();insertTags(&#39;<fnt>\\n&#39;+i+&#39;  <aut>&#39;,&#39;</aut>,\\n&#39;+i+&#39;  <vrk><url ref=\\&#34;\\&#34;></url></vrk>,\\n&#39;+i+&#39;  <bib></bib>,\\n&#39;+i+&#39;  <lok></lok>\\n&#39;+i+&#39;</fnt>&#39;,&#39;&#39;);return false\" href=\"#\">[fnt]</a>\n ",
      "&nbsp; &nbsp; ".a({target=>"_new", href=>'/revo/dok/manlibro.html#ekz'}, "[helpo]")."\n ".
      a({target=>"_new", href=>'/revo/dok/dtd.html#ekz'}, "[dtd]")."\n".
      "&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ".
      checkbox(-name      => 'cx',
               -checked   => defined(cookie(-name=>'cx')) ? cookie(-name=>'cx') : 1,
               -value     => '1',
               -accesskey => "x",
               -onClick   => "document.f.xmlTxt.focus()",
               -label     => 'anstata&#365;igu&nbsp; c<u>x</u>,&nbsp;gx,&nbsp;...,&nbsp;ux').

#      "<input name="x" id="x" checked="checked" type="checkbox">".
#  onclick=""
      br.
      "\n&nbsp;traduki: <a accesskey=\"t\" onclick=\"insertTags2(&#39;<trd lng=\\&#34;&#39;,document.getElementById(&#34;trdlng&#34;).value,&#39;\\&#34;>&#39;,&#39;</trd>&#39;,&#39;&#39;);return false\" href=\"#\">[<u>t</u>rd lng]</a> ",
#      "\n&nbsp;<a onclick=\"var i=str_indent();insertTags(&#39;<trdgrp>\\n&#39;+i+&#39;  <trd>&#39;,&#39;</trd>\\n&#39;+i+&#39;</trdgrp>&#39;,&#39;&#39;);return false\" href=\"#\">[trdgrp]</a> ",
      "\n&nbsp;<a onclick=\"var i=str_indent();insertTags2(&#39;<trdgrp lng=\\&#34;&#39;,document.getElementById(&#34;trdlng&#34;).value,&#39;\\&#34;>\\n&#39;+i+&#39;  <trd>&#39;,&#39;</trd>,\\n&#39;+i+&#39;  <trd></trd>\\n&#39;+i+&#39;</trdgrp>&#39;,&#39;&#39;);return false\" href=\"#\">[trdgrp lng]</a> ",
      "\n lng=".textfield(-id=>'trdlng',
		    -name=>'trdlng',
                    -size => 2,
                    -maxlength => 3,
                    -value=> cookie(-name=>'trdlng') || '',
      ),
      "\n&nbsp;<a onclick=\"insertTags(&#39;<trd>&#39;,&#39;</trd>&#39;,&#39;&#39;);return false\" href=\"#\">[trd]</a> ",
      "\n&nbsp;<a onclick=\"insertTags(&#39;<klr>&#39;,&#39;</klr>&#39;,&#39;&#39;);return false\" href=\"#\">[klr]</a> ",
      "\n&nbsp;<a onclick=\"insertTags2(&#39;<klr tip=\\&#34;&#39;,document.getElementById(&#34;klrtip&#34;).value,&#39;\\&#34;>&#39;,&#39;</klr>&#39;,&#39;&#39;);return false\" href=\"#\">[klr tip]</a> ",
      "\n tip=".popup_menu(-id=>'klrtip',
		    -name=>'klrtip',
                    -values=>['', qw/ind amb/],
		    -default=> cookie(-name=>'klrtip') || 'amb',
		    -labels=>{'ind'=>'ind-ekso',
                              'amb'=>'amb-aux',
		    },
#                    -size => 2,
#                    -maxlength => 3,
#                    -value=> cookie(-name=>'reftip') || '',
      )."\n ",
      "\n&nbsp;<a onclick=\"insertTags(&#39;<ind>&#39;,&#39;</ind>&#39;,&#39;&#39;);return false\" href=\"#\">[ind]</a> ",
      "&nbsp; &nbsp; ".a({target=>"_new", href=>'/revo/dok/manlibro.html#trd'}, "[helpo]").
      a({target=>"_new", href=>'/revo/dok/dtd.html#trd'}, "[dtd]").
      br."\n",
      hidden(-name=>'art', -default=>param('art')),
      hidden(-name=>'mrk', -default=>param('mrk')),
      "&nbsp;".textarea(-id    => 'xmlTxt', -name    => 'xmlTxt',
               -rows    => 25,
               -columns => 80,
	       -default => $xml,
               -onkeypress => "return klavo(event)",
      ),
      br."\n",
      "&nbsp;&#348;an&#285;o: ".textfield(-name=>'sxangxo',
                    -value=>cookie(-name=>'sxangxo') || 'klarigo de la &#349;an&#285;o',
                    -size=>70,
                    -maxlength=>80),
      br."\n&nbsp;Retpo&#349;ta adreso:".textfield(-name=>'redaktanto',
                    -size      => 70,
                    -maxlength => 80,
                    -value     => (cookie(-name=>'redaktanto') || 'via retpo&#349;ta adreso')
      ),
      br."\n",
      submit(-name => 'button', -value => 'preview', -label => 'anta&#365;rigardu'),
      submit(-name => 'button', -value => 'save', -label => 'savu');
      print checkbox(-name    => 'sendu_al_tio',
                     -checked => 1,
                     -value   => '1',
                     -label   => 'sendu al supra adreso');
      print checkbox(-name    => 'sendu_al_revo',
                     -checked => 1,
                     -value   => '1',
                     -label   => 'sendu al ReVo');
      print checkbox(-name    => 'sendu_al_admin',
                     -checked => 1,
                     -value   => '1',
                     -label   => 'sendu por analizo');

print endform;

print <<"EOD";
<h1>Klarigoj:</h1>
Se vi permesas kuketojn, vi ne da&#365;re devas entajpi vian retadreson kaj lingvon.<br>
klavo kontrolo-Z malfaras la lastan &#349;an&#285;on<br>
klavo kontrolo-Y refaras la lastan &#349;an&#285;on<br>
klavo kontrolo-F ebligas ser&#265;i<br>
via retadreso estas $ENV{REMOTE_ADDR}<br>
EOD
print p('svn versio: $Id$'.br.
	'hg versio: $HgId: vokomail.pl 5:28f6201b3825 2008/11/19 17:41:15 Wieland $');

print end_html();

sub checkxml {
    my $teksto = shift;
    my ($err, $konteksto, $line, $char);

#    # enmetu Log se ankorau mankas...
#    unless ($teksto =~ /<!--\s+\044Log/s) {
#	$teksto =~ s/(<\/vortaro>)/\n<!--\n\044Log\044\n-->\n$1/s;
#    }
#
#    # mallongigu Log al 20 linioj
#    $teksto =~ s/(<!--\s+\044Log(?:[^\n]*\n){20})(?:[^\n]*\n)*(-->)/$1$2/s;

    chdir($revo_base) or die "chdir";
#    $debugmsg .= "checkxml: teksto = $teksto\n";
    my $pid = IPC::Open3::open3(\*CHLD_IN, \*CHLD_OUT, \*CHLD_ERR,
                    'rxp -Vs >/dev/null');
    print CHLD_IN $teksto;
    close CHLD_IN;
    my $err = join('', <CHLD_ERR>);
#    $debugmsg .= "checkxml: err = $err\n";
    close CHLD_ERR;
    close CHLD_OUT;

    # legu la erarojn
#    open ERR,"$tmp/xml.err";
#    $err=join('',<ERR>);
#    close ERR;
#    unlink("$tmp/xml.err");

    if ($err) {
        $ne_savu = 1;
        my $ret = "XML check malsukcesis - Eraro";

        $err =~ s/^Warning: /Atentu: /smg;
        $err =~ s/^Error: /Eraro: /smg;
        $err =~ s/ of <stdin>$//smg;
        $err =~ s/^ in unnamed entity//smg;
        $err =~ s/Start tag for undeclared element ([^\n]*)/Ne konata komencokodero $1/smg;
        $err =~ s/Content model for ([^ \n]*) does not allow element ([^ \n]*) here$/Reguloj por $1 malpermesas $2 cxi tie/smg;
        $err =~ s/Mismatched end tag: expected ([^,\n]*), got ([^ \n]*)$/Malkongrua finokodero: atendis $1, trovis $2/smg;
        $err =~ s/^ at line (\d+) char (\d+)$/ cxe linio $1 pozicio $2/smg;
        $err =~ s/Document contains multiple elements/Artikolo enhavas pli ol unu elemento (kaj tio devas esti <vortaro>)/smg;
        $err =~ s/Root element is ([^ ,\n]*), should be ([^ \n]*)/Radika elemento estas $1, devus esti $2/smg;
        $err =~ s/Content model for ([^ \n]*) does not allow PCDATA/Enhave de elemento $1 estas malpermesita/smg;
        $err =~ s/The attribute ([^ \n]*) of element ([^ \n]*) is declared as ENUMERATION but is empty/La atributo $1 de la kodero $2 mankas/smg;
        $err =~ s/In the attribute ([^ \n]*) of element ([^ \n]*), ([^ \n]*) is not one of the allowed values/Cxe la atributo $1 de la kodero $2, $3 ne estas permesata./smg;
        $err =~ s/Document ends too soon/Dokumento finis, sed mankis finkodero/smg;

        autoEscape(1);
        ($konteksto, $line, $char) = xml_context($err, $teksto);
	$err .= "kunteksto de unua eraro:\n$konteksto";
	$ret .= pre(escapeHTML("XML-eraroj:\n$err\n")); # if ($verbose);
        autoEscape(0);
	$ret .= "&nbsp;&nbsp;&nbsp;&nbsp; * se vi trovas anglan mesagxon aux malbonan erarmesagxon, skribu al wieland(cxe)wielandpusch.de";
	$err = $ret;
    } else {
	$err = "XML en ordo</b></span></p>\n";
    }
    return ("Kontrolo</b></span></p>\n$err", $line, $char);
}


sub xml_context {
    my ($err, $teksto) = @_;
    my ($line, $char, $result, $n, $txt);

    if ($err =~ /linio\s+([0-9]+)\s+pozicio\s+([0-9]+)\s+/s) {
	$line = $1;
	$char = $2;
#        $debugmsg .= "context: line = $line, char = $char, err = $err\n";

        my @a = split "\n", $teksto;

	# la linio antau la eraro
	if ($line > 1) {
	    $result .= ($line-1).": $a[$line - 2]\n";
	}
	$result .= "$line: $a[$line - 1]\n";
	$result .= "-" x ($char + length($line) + 1) . "^\n";

	if (exists($a[$line])) {
	    $result .= ($line+1).": $a[$line]";
	}

	return ($result, $line, $char);
    }

    return ('', 0, 0);
}

