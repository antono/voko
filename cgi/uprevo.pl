#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use Cwd;
use IO::Handle;

# propraj perl moduloj estas en:
use lib("/var/www/web277/files/perllib");
use parseart;

my $exitcode;

print header,
      start_html('Sendu sxangxitajn pagxojn'),
      h1('fname='.param('fname'));

open LOG, ">>../../../files/log/uprevo.log" or die("ne eblas skribi log");	
autoflush LOG 1;

my $fname = param('fname');

my $homedir = "/var/www/web277";
#print h1("homedir = $homedir");

$ret = `du -sh $homedir`;
print h2("du -> $exitcode");
print pre($ret);

my $htmldir = "$homedir/html";

#$ENV{'LD_LIBRARY_PATH'} = "$homedir/files/lib";
#print h1("LD_LIBRARY_PATH = ".$ENV{'LD_LIBRARY_PATH'});
$ENV{'PATH'} = $ENV{'PATH'}.":$homedir/files/bin";
#print h1("PATH = ".$ENV{'PATH'});

print LOG "uprevo started at ".localtime()." with fname=$fname\n";
unless ($fname =~ /^revo-\d\d\d\d\d\d\d\d\.tgz$/) {
  print LOG "Nevalidaj parametroj\n\n";
  print h1("Nevalidaj parametroj"), end_html;
  exit 1;
}

my $ret;

chdir $htmldir or die "chdir ne funkciis";

#$ret = `ln -s revo . 2>&1`;
#print h2("ln -s -> $exitcode");
#print pre($ret);

#$ret = `rm revo . 2>&1`;
#print h2("rm -> $exitcode");
#print pre($ret);

#$ret = `tar --help 2>&1`;
#print h2("tar -tv -> $exitcode");
#print pre($ret);

#print h1("cwd=".cwd());

$ret = `tar -xvzf alveno/$fname revo/art tgz revo/xml revo/tez revo/bld revo/stl revo/smb revo/dok revo/inx revo/index.html revo/sercxo.html revo/titolo.html revo/revo.ico revo/araneo.gif revo/reto.gif revo/revo.jpg revo/revo.gif revo/travidebla.gif 2>&1`;
$exitcode = $?;
print h2("tar -xv -> $exitcode");
print LOG "tar -xv -> $exitcode\n$ret";
print pre($ret);

if (0 and !$exitcode) {
  $ret = `rm alveno/$fname 2>&1`;
  $exitcode = $?;
  print h2("rm -> $exitcode");
  print LOG "rm -> $exitcode\n";
  print LOG "$ret\n" if $exitcode;
  print pre($ret);
#  if ($exitcode) {
#    print LOG "$ret\n";
#    exit 1;
#  }
}

$ret = `du -sh $homedir`;
print h2("du -> $exitcode");
print pre($ret);

print LOG "normala fino de uprevo.pl\n\n";
print end_html;

close LOG;

1;
