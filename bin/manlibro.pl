#!/usr/bin/perl -w

# transformas krudan tekston de manlibro en validan HTML
# uzo:
# manlibro.pl manlibro.txt > manlibro.html

$infile = shift @ARGV;

open IN,$infile or die "Ne povis legi $infile: $!\n";
$_ = join('',<IN>);
close IN;

# konverti la e-literojn de Lat-3 al utf-8
s/\306/\304\210/g; #Cx
s/\330/\304\234/g; #Gx
s/\246/\304\244/g; #Hx
s/\254/\304\264/g; #Jx
s/\336/\305\234/g; #Sx
s/\335/\305\254/g; #Ux
s/\346/\304\211/g; #cx
s/\370/\304\235/g; #gx
s/\266/\304\245/g; #hx
s/\274/\304\265/g; #jx
s/\376/\305\235/g; #sx
s/\375/\305\255/g; #ux    

# konverti la e-literojn de cx al utf-8
s/Cx/\304\210/g; #Cx
s/Gx/\304\234/g; #Gx
s/Hx/\304\244/g; #Hx
s/Jx/\304\264/g; #Jx
s/Sx/\305\234/g; #Sx
s/Ux/\305\254/g; #Ux
s/cx/\304\211/g; #cx
s/gx/\304\235/g; #gx
s/hx/\304\245/g; #hx
s/jx/\304\265/g; #jx
s/sx/\305\235/g; #sx
s/ux/\305\255/g; #ux
s/\\x/x/g;

# elprenu la titolon
m/<h1>(.*)<\/h1>/si;
$title=$1;

# registru la chapitrojn
s/%([a-z]+)%<h2>(.*?)<\/h2>/push(@chapitroj,[$1,$2]),"%$1%<h2>$2<\/h2>"/sieg;

# enshovu enhavtabelon
for $ch (@chapitroj) {
    $enh .= "<li><a href=\"#".$ch->[0]."\">".$ch->[1]."</a>\n";
}
s/<\/h1>/"<\/h1>\n\n<ul>\n$enh<\/ul>\n"/ie;

# anstataýigu referencojn
s/#([a-z]+)%(.*?)#/<a href="#$1">$2<\/a>/sig;
s/%([a-z]+)%/<a name="$1"><\/a>/sig;

# formatu la ekzemplojn
s/\[\[(.*?)\]\]/formatu_ekz($1)/seg;

# eligu la kapon

print <<EOH;
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link title="artikolo-stilo" type="text/css" rel=stylesheet href="../stl/artikolo.css">

<title>$title</title>
</head>
<body>    
EOH

print $_;

# eligu la finon

print <<EOH;
</body>
</html>
EOH

###################

sub formatu_ekz {
    $ekz = shift;

    $ekz =~ s/&([a-z]+);/&amp;$1;/sg;
    $ekz =~ s/<([a-z\-\/\?\!]+)([^>]*)>/markup($1,$2,"blue","#007700")/sieg;
#    $ekz =~ s/<([^>]*)>/markup($1,'',"green")/sieg;

    return "<table bgcolor=#EEEECC width=100%><tr><td><pre>\n$ekz</pre></td></tr></table>";
}

sub markup {
    $el = shift;
    $args = shift;
    $clr_el = shift;
    $clr_args = shift;

    return $args?

	"<font color=$clr_el>&lt;$el</font>".
	"<font color=$clr_args>$args</font>".
        "<font color=$clr_el>&gt;</font>" :

        "<font color=$clr_el>&lt;$el&gt;</font>"
}











