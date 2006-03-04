#!/usr/local/bin/perl

use Test::Unit::Procedural;

# your code to be tested goes here

$DICT = ".test";
$INX = "$DICT/.tmp";

sub test_kap {

    $ant = "ant -file ".$ENV{"VOKO"}."/ant/indeksoj.xml -Dbasedir=$DICT kapvortoj";
    warn $ant;
    `$ant`;
    assert(-s "$INX/kap.xml","dosiero kap.xml mankas");

    $kap = get_file("$INX/kap.xml");
    assert(check_index($kap,"test","test/o"),"test");
    assert(check_index($kap,"test.0o","testo"),"test.0o");
    assert(check_index($kap,"test.0i","testi"),"test.0i");

};

sub test_trd {

    $ant = "ant -file ".$ENV{"VOKO"}."/ant/indeksoj.xml -Dbasedir=$DICT tradukoj";
    warn $ant;
    `$ant`;
    assert(-s "$INX/kap.xml","dosiero trd.xml mankas");

    $trd = get_file("$INX/trd.xml");
    assert(check_index($trd,"test.0o","Test"),"Test");
    assert(check_index($trd,"test.0i","testen"),"testen");
    assert(check_index($trd,"test.0i","probieren"),"probieren");

};

# set_up and tear_down are used to
# prepare and release resources need for testing

sub set_up    { print "kreas vortareton en $DICT\n"; make_test_dict(); }
sub tear_down { print "forigas vortareton en $DICT\n"; } #delete_test_dict(); }

# run your test

create_suite();
run_suite();

sub make_test_dict {
    `mkdir $DICT`;
    `mkdir $DICT/xml`;
    open FILE,">$DICT/xml/test.xml";
    select FILE;
    print <<EOF;
<?xml version="1.0"?>
<vortaro>
<art mrk="\$Id: test.xml asdfosdf">
  <kap><rad>test</rad>/o</kap>
  <drv mrk="test.0o">
    <kap><tld/>o</kap>
    <snc mrk="test.0o.GEOL">
      <uzo tip="fak">GEOL</uzo>
      <dif>fusx fusx fusx</dif>
      <trd lng="de">Test <klr>(GEO)</klr></trd>
    </snc>
    <snc mrk="test.0o.XXX">
      <dif>balbut balbut balbut</dif>
    </snc>
    <trd lng="de">Test</trd>
    <trd lng="en">test</trd>
  </drv>
  <drv mrk="test.0i">
    <kap><tld/>i</kap>
    <dif>strang strang strang</dif>
    <trdgrp lng="de">
      <trd>testen</trd>,
      <trd>probieren</trd>
    </trdgrp>
    <trd lng="en">to test</trd>
  </drv>
</art>
</vortaro>
EOF

    select STDIN;
}

sub get_file{
    my $filename = shift;
    open FILE,$filename;
    $text = join('',<FILE>);
    close FILE;
    return $text;
}

sub check_index{
    my ($text,$mrk,$v) = @_;

    $mrk =~ s/\./\\./g;
    return $text =~ /<v\s+mrk=\"$mrk\">\s*$v\s*<\/v>/;
}

sub delete_test_dict {
    `rm -rf .test`;
}
