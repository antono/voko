#!/usr/bin/perl

#
# revo::encode.pm
# 
# 2008-02-09 Wieland Pusch
#

use strict;
#use warnings;

package revo::encode;

use utf8;
use Encode;
use HTML::Entities;
use CGI qw(:standard); 	# nur por verbose

######################################################################
sub encode {
  my $str = shift @_;
  my $verbose = shift @_;
  return encode2($str, 0, $verbose);
}

######################################################################
sub encode2 {
  my $enc = "utf-8";
  my $str = shift @_;
  my $flag = shift @_;
  my $verbose = shift @_;
  print pre("encode2") if $verbose;
  $str = Encode::decode($enc, $str);

  print pre(escapeHTML("encode ".Encode::encode($enc, $str)))."\n" if $verbose;
#  print pre(escapeHTML("encode ".Encode::encode($enc, $str)))."\n" if $verbose;

  $str =~ s/&(?![#a-zA-Z0-9_]+;)/&amp;/g;

  # <!-- e-aj literoj -->
  $str =~ s/\x{0108}/&Ccirc;/g;
  $str =~ s/\x{0109}/&ccirc;/g;
  $str =~ s/\x{011c}/&Gcirc;/g;
  $str =~ s/\x{011d}/&gcirc;/g;
  $str =~ s/\x{0124}/&Hcirc;/g;
  $str =~ s/\x{0125}/&hcirc;/g;
  $str =~ s/\x{0134}/&Jcirc;/g;
  $str =~ s/\x{0135}/&jcirc;/g;
  $str =~ s/\x{015c}/&Scirc;/g;
  $str =~ s/\x{015d}/&scirc;/g;
  $str =~ s/\x{016c}/&Ubreve;/g;
  $str =~ s/\x{016d}/&ubreve;/g;

  # <!-- francaj k.a. -->
  $str =~ s/\x{0152}/&OElig;/g;
  $str =~ s/\x{0153}/&oelig;/g;
  $str =~ s/\x{00c1}/&Aacute;/g;
  $str =~ s/\x{00e1}/&aacute;/g;
  $str =~ s/\x{00c9}/&Eacute;/g;
  $str =~ s/\x{00e9}/&eacute;/g;
  $str =~ s/\x{00cd}/&Iacute;/g;
  $str =~ s/\x{00ed}/&iacute;/g;
  $str =~ s/\x{00d3}/&Oacute;/g;
  $str =~ s/\x{00f3}/&oacute;/g;
  $str =~ s/\x{00da}/&Uacute;/g;
  $str =~ s/\x{00fa}/&uacute;/g;

  $str =~ s/\x{00c0}/&Agrave;/g;
  $str =~ s/\x{00e0}/&agrave;/g;
  $str =~ s/\x{00c8}/&Egrave;/g;
  $str =~ s/\x{00e8}/&egrave;/g;
  $str =~ s/\x{00cc}/&Igrave;/g;
  $str =~ s/\x{00ec}/&igrave;/g;
  $str =~ s/\x{00d2}/&Ograve;/g;
  $str =~ s/\x{00f2}/&ograve;/g;
  $str =~ s/\x{00d9}/&Ugrave;/g;
  $str =~ s/\x{00f9}/&ugrave;/g;

  $str =~ s/\x{00c2}/&Acirc;/g;
  $str =~ s/\x{00e2}/&acirc;/g;
  $str =~ s/\x{00ca}/&Ecirc;/g;
  $str =~ s/\x{00ea}/&ecirc;/g;
  $str =~ s/\x{00ce}/&Icirc;/g;
  $str =~ s/\x{00ee}/&icirc;/g;
  $str =~ s/\x{00d4}/&Ocirc;/g;
  $str =~ s/\x{00f4}/&ocirc;/g;
  $str =~ s/\x{00db}/&Ucirc;/g;
  $str =~ s/\x{00fb}/&ucirc;/g;

  # <!-- germanaj -->
  $str =~ s/\x{00df}/&szlig;/g;
  $str =~ s/\x{00c4}/&Auml;/g;
  $str =~ s/\x{00e4}/&auml;/g;
  $str =~ s/\x{00d6}/&Ouml;/g;
  $str =~ s/\x{00f6}/&ouml;/g;
  $str =~ s/\x{00dc}/&Uuml;/g;
  $str =~ s/\x{00fc}/&uuml;/g;

  # <!-- turkaj ne jam menciitaj -->
  $str =~ s/\x{011e}/&Gbreve;/g;
  $str =~ s/\x{011f}/&gbreve;/g;
  $str =~ s/\x{0131}/&inodot;/g;
  $str =~ s/\x{0130}/&Idot;/g;
  $str =~ s/\x{015e}/&Scedil;/g;
  $str =~ s/\x{015f}/&scedil;/g;
  $str =~ s/\x{00c7}/&Ccedil;/g;
  $str =~ s/\x{00e7}/&ccedil;/g;

  # <!-- diversaj -->
  $str =~ s/</&lt;/g if $flag < 10;
  $str =~ s/>/&gt;/g if $flag < 10;
#  $str =~ s/'/&apos;/g;
#  $str =~ s/'/&minute;/g;
  $str =~ s/"/&quot;/g if $flag < 10;
#  $str =~ s/\x{0034}/&second;/g;
  $str =~ s/\x{201e}/&leftquot;/g;
  $str =~ s/\x{201c}/&rightquot;/g;
#  $str =~ s/\x{00b0}/&ring;/g;
  $str =~ s/\x{00b0}/&deg;/g;
  $str =~ s/\x{00b2}/&quadrat;/g;
  $str =~ s/\x{00b3}/&cubic;/g;
  $str =~ s/\x{00B6}/&para;/g;
  $str =~ s/\x{00a7}/&FE;/g;
  $str =~ s/\x{2015}/&dash;/g;
  $str =~ s/\x{2014}/&mdash;/g;
  $str =~ s/\x{2013}/&ndash;/g;
  $str =~ s/\x{00a0}/&nbsp;/g;

  $str =~ s/\x{00cb}/&Euml;/g;
  $str =~ s/\x{00eb}/&euml;/g;
  $str =~ s/\x{00cf}/&Iuml;/g;
  $str =~ s/\x{00ef}/&iuml;/g;

  $str =~ s/\x{00c5}/&Aring;/g;
  $str =~ s/\x{00e5}/&aring;/g;
  $str =~ s/\x{00c6}/&AElig;/g;
  $str =~ s/\x{00e6}/&aelig;/g;
  $str =~ s/\x{00d8}/&Oslash;/g;
  $str =~ s/\x{00f8}/&oslash;/g;

  # <!-- portugalaj, hispanaj, katalunaj -->
  $str =~ s/\x{00d1}/&Ntilde;/g;
  $str =~ s/\x{00f1}/&ntilde;/g;

  $str =~ s/\x{00c3}/&Atilde;/g;
  $str =~ s/\x{00e3}/&atilde;/g;
  $str =~ s/\x{00d5}/&Otilde;/g;
  $str =~ s/\x{00f5}/&otilde;/g;

  $str =~ s/\x{00b7}/&middot;/g;

  # <!-- rumanaj -->
  $str =~ s/\x{0102}/&Abreve;/g;
  $str =~ s/\x{0103}/&abreve;/g;
  $str =~ s/\x{0162}/&Tcedil;/g;
  $str =~ s/\x{0163}/&tcedil;/g;

  # <!-- grekaj -->
  $str =~ s/\x{0391}/&Alfa;/g;
  $str =~ s/\x{03b1}/&alfa;/g;
  $str =~ s/\x{1f71}/&alfa_acute;/g;
  $str =~ s/\x{1fbb}/&Alfa_acute;/g;
  $str =~ s/\x{1fb4}/&alfa_acute_subj;/g;
  $str =~ s/\x{1fb0}/&alfa_breve;/g;
  $str =~ s/\x{1fb8}/&Alfa_breve;/g;
  $str =~ s/\x{1fb6}/&alfa_circ;/g;
  $str =~ s/\x{1fb7}/&alfa_circ_subj;/g;
  $str =~ s/\x{1f01}/&alfa_densa;/g;
  $str =~ s/\x{1f09}/&Alfa_densa;/g;
  $str =~ s/\x{1f05}/&alfa_densa_acute;/g;
  $str =~ s/\x{1f0d}/&Alfa_densa_acute;/g;
  $str =~ s/\x{1f85}/&alfa_densa_acute_subj;/g;
  $str =~ s/\x{1f8d}/&Alfa_densa_acute_Subj;/g;
  $str =~ s/\x{1f07}/&alfa_densa_circ;/g;
  $str =~ s/\x{1f0f}/&Alfa_densa_circ;/g;
  $str =~ s/\x{1f87}/&alfa_densa_circ_subj;/g;
  $str =~ s/\x{1f8f}/&Alfa_densa_circ_Subj;/g;
  $str =~ s/\x{1f03}/&alfa_densa_grave;/g;
  $str =~ s/\x{1f0b}/&Alfa_densa_grave;/g;
  $str =~ s/\x{1f83}/&alfa_densa_grave_subj;/g;
  $str =~ s/\x{1f8b}/&Alfa_densa_grave_Subj;/g;
  $str =~ s/\x{1f81}/&alfa_densa_subj;/g;
  $str =~ s/\x{1f89}/&Alfa_densa_Subj;/g;
  $str =~ s/\x{1f70}/&alfa_grave;/g;
  $str =~ s/\x{1fba}/&Alfa_grave;/g;
  $str =~ s/\x{1fb2}/&alfa_grave_subj;/g;
  $str =~ s/\x{1fb1}/&alfa_makron;/g;
  $str =~ s/\x{1fb9}/&Alfa_makron;/g;
  $str =~ s/\x{1f00}/&alfa_psili;/g;
  $str =~ s/\x{1f08}/&Alfa_psili;/g;
  $str =~ s/\x{1f04}/&alfa_psili_acute;/g;
  $str =~ s/\x{1f0c}/&Alfa_psili_acute;/g;
  $str =~ s/\x{1f84}/&alfa_psili_acute_subj;/g;
  $str =~ s/\x{1f8c}/&Alfa_psili_acute_Subj;/g;
  $str =~ s/\x{1f06}/&alfa_psili_circ;/g;
  $str =~ s/\x{1f0e}/&Alfa_psili_circ;/g;
  $str =~ s/\x{1f86}/&alfa_psili_circ_subj;/g;
  $str =~ s/\x{1f8e}/&Alfa_psili_circ_Subj;/g;
  $str =~ s/\x{1f02}/&alfa_psili_grave;/g;
  $str =~ s/\x{1f0a}/&Alfa_psili_grave;/g;
  $str =~ s/\x{1f82}/&alfa_psili_grave_subj;/g;
  $str =~ s/\x{1f8a}/&Alfa_psili_grave_Subj;/g;
  $str =~ s/\x{1f80}/&alfa_psili_subj;/g;
  $str =~ s/\x{1f88}/&Alfa_psili_Subj;/g;
  $str =~ s/\x{1fb3}/&alfa_subj;/g;
  $str =~ s/\x{1fbc}/&Alfa_Subj;/g;
  $str =~ s/\x{0386}/&Alfa_ton;/g;
  $str =~ s/\x{03ac}/&alfa_ton;/g;

  $str =~ s/\x{0392}/&Beta;/g;
  $str =~ s/\x{03b2}/&beta;/g;

  $str =~ s/\x{0393}/&Gamma;/g;
  $str =~ s/\x{03b3}/&gamma;/g;

  $str =~ s/\x{0394}/&Delta;/g;
  $str =~ s/\x{03b4}/&delta;/g;

  $str =~ s/\x{0395}/&Epsilon;/g;
  $str =~ s/\x{03b5}/&epsilon;/g;
  $str =~ s/\x{1f73}/&epsilon_acute;/g;
  $str =~ s/\x{1fc9}/&Epsilon_acute;/g;
  $str =~ s/\x{1f11}/&epsilon_densa;/g;
  $str =~ s/\x{1f19}/&Epsilon_densa;/g;
  $str =~ s/\x{1f15}/&epsilon_densa_acute;/g;
  $str =~ s/\x{1f1d}/&Epsilon_densa_acute;/g;
  $str =~ s/\x{1f13}/&epsilon_densa_grave;/g;
  $str =~ s/\x{1f1b}/&Epsilon_densa_grave;/g;
  $str =~ s/\x{1f72}/&epsilon_grave;/g;
  $str =~ s/\x{1fc8}/&Epsilon_grave;/g;
  $str =~ s/\x{1f10}/&epsilon_psili;/g;
  $str =~ s/\x{1f18}/&Epsilon_psili;/g;
  $str =~ s/\x{1f14}/&epsilon_psili_acute;/g;
  $str =~ s/\x{1f1c}/&Epsilon_psili_acute;/g;
  $str =~ s/\x{1f12}/&epsilon_psili_grave;/g;
  $str =~ s/\x{1f1a}/&Epsilon_psili_grave;/g;
  $str =~ s/\x{0388}/&Epsilon_ton;/g;
  $str =~ s/\x{03ad}/&epsilon_ton;/g;

  $str =~ s/\x{0396}/&Zeta;/g;
  $str =~ s/\x{03b6}/&zeta;/g;

  $str =~ s/\x{0397}/&Eta;/g;
  $str =~ s/\x{03b7}/&eta;/g;
  $str =~ s/\x{1f75}/&eta_acute;/g;
  $str =~ s/\x{1fcb}/&Eta_acute;/g;
  $str =~ s/\x{1fc4}/&eta_acute_subj;/g;
  $str =~ s/\x{1fc6}/&eta_circ;/g;
  $str =~ s/\x{1fc7}/&eta_circ_subj;/g;
  $str =~ s/\x{1f21}/&eta_densa;/g;
  $str =~ s/\x{1f29}/&Eta_densa;/g;
  $str =~ s/\x{1f25}/&eta_densa_acute;/g;
  $str =~ s/\x{1f2d}/&Eta_densa_acute;/g;
  $str =~ s/\x{1f95}/&eta_densa_acute_subj;/g;
  $str =~ s/\x{1f9d}/&Eta_densa_acute_Subj;/g;
  $str =~ s/\x{1f27}/&eta_densa_circ;/g;
  $str =~ s/\x{1f2f}/&Eta_densa_circ;/g;
  $str =~ s/\x{1f97}/&eta_densa_circ_subj;/g;
  $str =~ s/\x{1f9f}/&Eta_densa_circ_Subj;/g;
  $str =~ s/\x{1f23}/&eta_densa_grave;/g;
  $str =~ s/\x{1f2b}/&Eta_densa_grave;/g;
  $str =~ s/\x{1f93}/&eta_densa_grave_subj;/g;
  $str =~ s/\x{1f9b}/&Eta_densa_grave_Subj;/g;
  $str =~ s/\x{1f91}/&eta_densa_subj;/g;
  $str =~ s/\x{1f99}/&Eta_densa_Subj;/g;
  $str =~ s/\x{1f74}/&eta_grave;/g;
  $str =~ s/\x{1fca}/&Eta_grave;/g;
  $str =~ s/\x{1fc2}/&eta_grave_subj;/g;
  $str =~ s/\x{1f20}/&eta_psili;/g;
  $str =~ s/\x{1f28}/&Eta_psili;/g;
  $str =~ s/\x{1f24}/&eta_psili_acute;/g;
  $str =~ s/\x{1f2c}/&Eta_psili_acute;/g;
  $str =~ s/\x{1f94}/&eta_psili_acute_subj;/g;
  $str =~ s/\x{1f9c}/&Eta_psili_acute_Subj;/g;
  $str =~ s/\x{1f26}/&eta_psili_circ;/g;
  $str =~ s/\x{1f2e}/&Eta_psili_circ;/g;
  $str =~ s/\x{1f96}/&eta_psili_circ_subj;/g;
  $str =~ s/\x{1f9e}/&Eta_psili_circ_Subj;/g;
  $str =~ s/\x{1f22}/&eta_psili_grave;/g;
  $str =~ s/\x{1f2a}/&Eta_psili_grave;/g;
  $str =~ s/\x{1f92}/&eta_psili_grave_subj;/g;
  $str =~ s/\x{1f9a}/&Eta_psili_grave_Subj;/g;
  $str =~ s/\x{1f90}/&eta_psili_subj;/g;
  $str =~ s/\x{1f98}/&Eta_psili_Subj;/g;
  $str =~ s/\x{1fc3}/&eta_subj;/g;
  $str =~ s/\x{1fcc}/&Eta_Subj;/g;
  $str =~ s/\x{0389}/&Eta_ton;/g;
  $str =~ s/\x{03ae}/&eta_ton;/g;

  $str =~ s/\x{0398}/&Theta;/g;
  $str =~ s/\x{03b8}/&theta;/g;

  $str =~ s/\x{0399}/&Jota;/g;
  $str =~ s/\x{03b9}/&jota;/g;
  $str =~ s/\x{1f77}/&jota_acute;/g;
  $str =~ s/\x{1fdb}/&Jota_acute;/g;
  $str =~ s/\x{1fd0}/&jota_breve;/g;
  $str =~ s/\x{1fd8}/&Jota_breve;/g;
  $str =~ s/\x{1fd6}/&jota_circ;/g;
  $str =~ s/\x{1f31}/&jota_densa;/g;
  $str =~ s/\x{1f39}/&Jota_densa;/g;
  $str =~ s/\x{1f35}/&jota_densa_acute;/g;
  $str =~ s/\x{1f3d}/&Jota_densa_acute;/g;
  $str =~ s/\x{1f37}/&jota_densa_circ;/g;
  $str =~ s/\x{1f3f}/&Jota_densa_circ;/g;
  $str =~ s/\x{1f33}/&jota_densa_grave;/g;
  $str =~ s/\x{1f3b}/&Jota_densa_grave;/g;
  $str =~ s/\x{1f76}/&jota_grave;/g;
  $str =~ s/\x{1fda}/&Jota_grave;/g;
  $str =~ s/\x{1fd1}/&jota_makron;/g;
  $str =~ s/\x{1fd9}/&Jota_makron;/g;
  $str =~ s/\x{1f30}/&jota_psili;/g;
  $str =~ s/\x{1f38}/&Jota_psili;/g;
  $str =~ s/\x{1f34}/&jota_psili_acute;/g;
  $str =~ s/\x{1f3c}/&Jota_psili_acute;/g;
  $str =~ s/\x{1f36}/&jota_psili_circ;/g;
  $str =~ s/\x{1f3e}/&Jota_psili_circ;/g;
  $str =~ s/\x{1f32}/&jota_psili_grave;/g;
  $str =~ s/\x{1f3a}/&Jota_psili_grave;/g;
  $str =~ s/\x{038a}/&Jota_ton;/g;
  $str =~ s/\x{03af}/&jota_ton;/g;
  $str =~ s/\x{03aa}/&Jota_trema;/g;
  $str =~ s/\x{03ca}/&jota_trema;/g;
  $str =~ s/\x{1fd3}/&jota_trema_acute;/g;
  $str =~ s/\x{1fd7}/&jota_trema_circ;/g;
  $str =~ s/\x{1fd2}/&jota_trema_grave;/g;
  $str =~ s/\x{0390}/&jota_trema_ton;/g;

  $str =~ s/\x{039a}/&Kappa;/g;
  $str =~ s/\x{03ba}/&kappa;/g;
  $str =~ s/\x{039b}/&Lambda;/g;
  $str =~ s/\x{03bb}/&lambda;/g;
  $str =~ s/\x{039c}/&My;/g;
  $str =~ s/\x{03bc}/&my;/g;
  $str =~ s/\x{039d}/&Ny;/g;
  $str =~ s/\x{03bd}/&ny;/g;
  $str =~ s/\x{039e}/&Xi;/g;
  $str =~ s/\x{03be}/&xi;/g;

  $str =~ s/\x{039f}/&Omikron;/g;
  $str =~ s/\x{03bf}/&omikron;/g;
  $str =~ s/\x{1f79}/&omikron_acute;/g;
  $str =~ s/\x{1ff9}/&Omikron_acute;/g;
  $str =~ s/\x{1f41}/&omikron_densa;/g;
  $str =~ s/\x{1f49}/&Omikron_densa;/g;
  $str =~ s/\x{1f45}/&omikron_densa_acute;/g;
  $str =~ s/\x{1f4d}/&Omikron_densa_acute;/g;
  $str =~ s/\x{1f43}/&omikron_densa_grave;/g;
  $str =~ s/\x{1f4b}/&Omikron_densa_grave;/g;
  $str =~ s/\x{1f78}/&omikron_grave;/g;
  $str =~ s/\x{1ff8}/&Omikron_grave;/g;
  $str =~ s/\x{1f40}/&omikron_psili;/g;
  $str =~ s/\x{1f48}/&Omikron_psili;/g;
  $str =~ s/\x{1f44}/&omikron_psili_acute;/g;
  $str =~ s/\x{1f4c}/&Omikron_psili_acute;/g;
  $str =~ s/\x{1f42}/&omikron_psili_grave;/g;
  $str =~ s/\x{1f4a}/&Omikron_psili_grave;/g;
  $str =~ s/\x{038c}/&Omikron_ton;/g;
  $str =~ s/\x{03cc}/&omikron_ton;/g;

  $str =~ s/\x{03a0}/&Pi;/g;
  $str =~ s/\x{03c0}/&pi;/g;

  $str =~ s/\x{03a1}/&Rho;/g;
  $str =~ s/\x{03c1}/&rho;/g;
  $str =~ s/\x{1fe5}/&rho_densa;/g;
  $str =~ s/\x{1fec}/&Rho_densa;/g;
  $str =~ s/\x{1fe4}/&rho_psili;/g;

  $str =~ s/\x{03a3}/&Sigma;/g;
  $str =~ s/\x{03c3}/&sigma;/g;
  $str =~ s/\x{03c2}/&sigma_fina;/g;

  $str =~ s/\x{03a4}/&Tau;/g;
  $str =~ s/\x{03c4}/&tau;/g;

  $str =~ s/\x{03a5}/&Ypsilon;/g;
  $str =~ s/\x{03c5}/&ypsilon;/g;
  $str =~ s/\x{1f7b}/&ypsilon_acute;/g;
  $str =~ s/\x{1feb}/&Ypsilon_acute;/g;
  $str =~ s/\x{1fe0}/&ypsilon_breve;/g;
  $str =~ s/\x{1fe8}/&Ypsilon_breve;/g;
  $str =~ s/\x{1fe6}/&ypsilon_circ;/g;
  $str =~ s/\x{1f51}/&ypsilon_densa;/g;
  $str =~ s/\x{1f59}/&Ypsilon_densa;/g;
  $str =~ s/\x{1f55}/&ypsilon_densa_acute;/g;
  $str =~ s/\x{1f5d}/&Ypsilon_densa_acute;/g;
  $str =~ s/\x{1f57}/&ypsilon_densa_circ;/g;
  $str =~ s/\x{1f5f}/&Ypsilon_densa_circ;/g;
  $str =~ s/\x{1f53}/&ypsilon_densa_grave;/g;
  $str =~ s/\x{1f5b}/&Ypsilon_densa_grave;/g;
  $str =~ s/\x{1f7a}/&ypsilon_grave;/g;
  $str =~ s/\x{1fea}/&Ypsilon_grave;/g;
  $str =~ s/\x{1fe1}/&ypsilon_makron;/g;
  $str =~ s/\x{1fe9}/&Ypsilon_makron;/g;
  $str =~ s/\x{1f50}/&ypsilon_psili;/g;
  $str =~ s/\x{1f54}/&ypsilon_psili_acute;/g;
  $str =~ s/\x{1f56}/&ypsilon_psili_circ;/g;
  $str =~ s/\x{1f52}/&ypsilon_psili_grave;/g;
  $str =~ s/\x{038e}/&Ypsilon_ton;/g;
  $str =~ s/\x{03cd}/&ypsilon_ton;/g;
  $str =~ s/\x{03ab}/&Ypsilon_trema;/g;
  $str =~ s/\x{03cb}/&ypsilon_trema;/g;
  $str =~ s/\x{1fe3}/&ypsilon_trema_acute;/g;
  $str =~ s/\x{1fe7}/&ypsilon_trema_circ;/g;
  $str =~ s/\x{1fe2}/&ypsilon_trema_grave;/g;
  $str =~ s/\x{03b0}/&ypsilon_trema_ton;/g;

  $str =~ s/\x{03a6}/&Phi;/g;
  $str =~ s/\x{03c6}/&phi;/g;
  $str =~ s/\x{03a7}/&Chi;/g;
  $str =~ s/\x{03c7}/&chi;/g;
  $str =~ s/\x{03a8}/&Psi;/g;
  $str =~ s/\x{03c8}/&psi;/g;

  $str =~ s/\x{03a9}/&Omega;/g;
  $str =~ s/\x{03c9}/&omega;/g;
  $str =~ s/\x{1f7d}/&omega_acute;/g;
  $str =~ s/\x{1ffb}/&Omega_acute;/g;
  $str =~ s/\x{1ff4}/&omega_acute_subj;/g;
  $str =~ s/\x{1ff6}/&omega_circ;/g;
  $str =~ s/\x{1ff7}/&omega_circ_subj;/g;
  $str =~ s/\x{1f61}/&omega_densa;/g;
  $str =~ s/\x{1f69}/&Omega_densa;/g;
  $str =~ s/\x{1f65}/&omega_densa_acute;/g;
  $str =~ s/\x{1f6d}/&Omega_densa_acute;/g;
  $str =~ s/\x{1fa5}/&omega_densa_acute_subj;/g;
  $str =~ s/\x{1fad}/&Omega_densa_acute_Subj;/g;
  $str =~ s/\x{1f67}/&omega_densa_circ;/g;
  $str =~ s/\x{1f6f}/&Omega_densa_circ;/g;
  $str =~ s/\x{1fa7}/&omega_densa_circ_subj;/g;
  $str =~ s/\x{1faf}/&Omega_densa_circ_Subj;/g;
  $str =~ s/\x{1f63}/&omega_densa_grave;/g;
  $str =~ s/\x{1f6b}/&Omega_densa_grave;/g;
  $str =~ s/\x{1fa3}/&omega_densa_grave_subj;/g;
  $str =~ s/\x{1fab}/&Omega_densa_grave_Subj;/g;
  $str =~ s/\x{1fa1}/&omega_densa_subj;/g;
  $str =~ s/\x{1fa9}/&Omega_densa_Subj;/g;
  $str =~ s/\x{1f7c}/&omega_grave;/g;
  $str =~ s/\x{1ffa}/&Omega_grave;/g;
  $str =~ s/\x{1ff2}/&omega_grave_subj;/g;
  $str =~ s/\x{1f60}/&omega_psili;/g;
  $str =~ s/\x{1f68}/&Omega_psili;/g;
  $str =~ s/\x{1f64}/&omega_psili_acute;/g;
  $str =~ s/\x{1f6c}/&Omega_psili_acute;/g;
  $str =~ s/\x{1fa4}/&omega_psili_acute_subj;/g;
  $str =~ s/\x{1fac}/&Omega_psili_acute_Subj;/g;
  $str =~ s/\x{1f66}/&omega_psili_circ;/g;
  $str =~ s/\x{1f6e}/&Omega_psili_circ;/g;
  $str =~ s/\x{1fa6}/&omega_psili_circ_subj;/g;
  $str =~ s/\x{1fae}/&Omega_psili_circ_Subj;/g;
  $str =~ s/\x{1f62}/&omega_psili_grave;/g;
  $str =~ s/\x{1f6a}/&Omega_psili_grave;/g;
  $str =~ s/\x{1fa2}/&omega_psili_grave_subj;/g;
  $str =~ s/\x{1faa}/&Omega_psili_grave_Subj;/g;
  $str =~ s/\x{1fa0}/&omega_psili_subj;/g;
  $str =~ s/\x{1fa8}/&Omega_psili_Subj;/g;
  $str =~ s/\x{1ff3}/&omega_subj;/g;
  $str =~ s/\x{1ffc}/&Omega_Subj;/g;
  $str =~ s/\x{038f}/&Omega_ton;/g;
  $str =~ s/\x{03ce}/&omega_ton;/g;

  # <!-- cirilaj -->
  $str =~ s/\x{042e}/&c_Ju;/g;
  $str =~ s/\x{0410}/&c_A;/g;
  $str =~ s/\x{0411}/&c_B;/g;
  $str =~ s/\x{0426}/&c_C;/g;
  $str =~ s/\x{0414}/&c_D;/g;
  $str =~ s/\x{0415}/&c_Je;/g;
  $str =~ s/\x{0424}/&c_F;/g;
  $str =~ s/\x{0413}/&c_G;/g;
  $str =~ s/\x{0425}/&c_H;/g;
  $str =~ s/\x{0418}/&c_I;/g;
  $str =~ s/\x{0419}/&c_J;/g;
  $str =~ s/\x{041a}/&c_K;/g;
  $str =~ s/\x{041b}/&c_L;/g;
  $str =~ s/\x{041c}/&c_M;/g;
  $str =~ s/\x{041d}/&c_N;/g;
  $str =~ s/\x{041e}/&c_O;/g;
  $str =~ s/\x{041f}/&c_P;/g;
  $str =~ s/\x{042f}/&c_Ja;/g;
  $str =~ s/\x{0420}/&c_R;/g;
  $str =~ s/\x{0421}/&c_S;/g;
  $str =~ s/\x{0422}/&c_T;/g;
  $str =~ s/\x{0423}/&c_U;/g;
  $str =~ s/\x{0416}/&c_Zh;/g;
  $str =~ s/\x{0412}/&c_V;/g;
  $str =~ s/\x{042c}/&c_Mol;/g;
  $str =~ s/\x{042b}/&c_Y;/g;
  $str =~ s/\x{0417}/&c_Z;/g;
  $str =~ s/\x{0428}/&c_Sh;/g;
  $str =~ s/\x{042d}/&c_E;/g;
  $str =~ s/\x{0429}/&c_Shch;/g;
  $str =~ s/\x{0427}/&c_Ch;/g;

  $str =~ s/\x{0401}/&c_Jo;/g;
  $str =~ s/\x{040E}/&c_W;/g;
  $str =~ s/\x{0406}/&c_Ib;/g;
  $str =~ s/\x{0490}/&c_Gu;/g;
  $str =~ s/\x{0404}/&c_Jeu;/g;
  $str =~ s/\x{0407}/&c_Ji;/g;

  $str =~ s/\x{044e}/&c_ju;/g;
  $str =~ s/\x{0430}/&c_a;/g;
  $str =~ s/\x{0431}/&c_b;/g;
  $str =~ s/\x{0446}/&c_c;/g;
  $str =~ s/\x{0434}/&c_d;/g;
  $str =~ s/\x{0435}/&c_je;/g;
  $str =~ s/\x{0444}/&c_f;/g;
  $str =~ s/\x{0433}/&c_g;/g;
  $str =~ s/\x{0445}/&c_h;/g;
  $str =~ s/\x{0438}/&c_i;/g;
  $str =~ s/\x{0439}/&c_j;/g;
  $str =~ s/\x{043a}/&c_k;/g;
  $str =~ s/\x{043b}/&c_l;/g;
  $str =~ s/\x{043c}/&c_m;/g;
  $str =~ s/\x{043d}/&c_n;/g;
  $str =~ s/\x{043e}/&c_o;/g;
  $str =~ s/\x{043f}/&c_p;/g;
  $str =~ s/\x{044f}/&c_ja;/g;
  $str =~ s/\x{0440}/&c_r;/g;
  $str =~ s/\x{0441}/&c_s;/g;
  $str =~ s/\x{0442}/&c_t;/g;
  $str =~ s/\x{0443}/&c_u;/g;
  $str =~ s/\x{0436}/&c_zh;/g;
  $str =~ s/\x{0432}/&c_v;/g;
  $str =~ s/\x{044c}/&c_mol;/g;
  $str =~ s/\x{044b}/&c_y;/g;
  $str =~ s/\x{0437}/&c_z;/g;
  $str =~ s/\x{0448}/&c_sh;/g;
  $str =~ s/\x{044d}/&c_e;/g;
  $str =~ s/\x{0449}/&c_shch;/g;
  $str =~ s/\x{0447}/&c_ch;/g;
  $str =~ s/\x{044a}/&c_malmol;/g;

  $str =~ s/\x{0451}/&c_jo;/g;
  $str =~ s/\x{045E}/&c_w;/g;
  $str =~ s/\x{0456}/&c_ib;/g;
  $str =~ s/\x{0491}/&c_gu;/g;
  $str =~ s/\x{0454}/&c_jeu;/g;
  $str =~ s/\x{0457}/&c_ji;/g;

  # <!-- chehhaj, slovakaj kaj polaj -->
  $str =~ s/\x{010c}/&Ccaron;/g;
  $str =~ s/\x{010d}/&ccaron;/g;
  $str =~ s/\x{0160}/&Scaron;/g;
  $str =~ s/\x{0161}/&scaron;/g;
  $str =~ s/\x{0158}/&Rcaron;/g;
  $str =~ s/\x{0159}/&rcaron;/g;
  $str =~ s/\x{00dd}/&Yacute;/g;
  $str =~ s/\x{00fd}/&yacute;/g;
  $str =~ s/\x{017d}/&Zcaron;/g;
  $str =~ s/\x{017e}/&zcaron;/g;
  $str =~ s/\x{017b}/&Zdot;/g;
  $str =~ s/\x{017c}/&zdot;/g;
  $str =~ s/\x{0147}/&Ncaron;/g;
  $str =~ s/\x{0148}/&ncaron;/g;
  $str =~ s/\x{011a}/&Ecaron;/g;
  $str =~ s/\x{011b}/&ecaron;/g;
  $str =~ s/\x{010e}/&Dcaron;/g;
  $str =~ s/\x{010f}/&dcaron;/g;
  $str =~ s/\x{0164}/&Tcaron;/g;
  $str =~ s/\x{0165}/&tcaron;/g;
  $str =~ s/\x{016e}/&Uring ;/g;
  $str =~ s/\x{016f}/&uring ;/g;

  $str =~ s/\x{0139}/&Lacute;/g;
  $str =~ s/\x{013a}/&lacute;/g;
  $str =~ s/\x{013d}/&Lcaron;/g;
  $str =~ s/\x{013e}/&lcaron;/g;
  $str =~ s/\x{0154}/&Racute;/g;
  $str =~ s/\x{0155}/&racute;/g;

  $str =~ s/\x{0104}/&Aogonek;/g;
  $str =~ s/\x{0105}/&aogonek;/g;
  $str =~ s/\x{0141}/&Lstroke;/g;
  $str =~ s/\x{0142}/&lstroke;/g;
  $str =~ s/\x{0118}/&Eogonek;/g;
  $str =~ s/\x{0119}/&eogonek;/g;
  $str =~ s/\x{0106}/&Cacute;/g;
  $str =~ s/\x{0107}/&cacute;/g;
  $str =~ s/\x{0143}/&Nacute;/g;
  $str =~ s/\x{0144}/&nacute;/g;
  $str =~ s/\x{015a}/&Sacute;/g;
  $str =~ s/\x{015b}/&sacute;/g;
  $str =~ s/\x{0179}/&Zacute;/g;
  $str =~ s/\x{017a}/&zacute;/g;

  $str =~ s/\x{05d0}/&alef;/g;
  $str =~ s/\x{05d1}/&bet;/g;
  $str =~ s/\x{05d2}/&gimel;/g;
  $str =~ s/\x{05d3}/&dalet;/g;
  $str =~ s/\x{05d4}/&he;/g;
  $str =~ s/\x{05d5}/&vav;/g;
  $str =~ s/\x{05d6}/&zayin;/g;
  $str =~ s/\x{05d7}/&het;/g;
  $str =~ s/\x{05d8}/&tet;/g;
  $str =~ s/\x{05d9}/&yod;/g;
  $str =~ s/\x{05da}/&fkaf;/g;
  $str =~ s/\x{05db}/&kaf;/g;
  $str =~ s/\x{05dc}/&lamed;/g;
  $str =~ s/\x{05dd}/&fmem;/g;
  $str =~ s/\x{05de}/&mem;/g;
  $str =~ s/\x{05df}/&fnun;/g;
  $str =~ s/\x{05e0}/&nun;/g;
  $str =~ s/\x{05e1}/&samekh;/g;
  $str =~ s/\x{05e2}/&ayin;/g;
  $str =~ s/\x{05e3}/&fpe;/g;
  $str =~ s/\x{05e4}/&pe;/g;
  $str =~ s/\x{05e5}/&ftsadi;/g;
  $str =~ s/\x{05e6}/&tsadi;/g;
  $str =~ s/\x{05e7}/&qof;/g;
  $str =~ s/\x{05e8}/&resh;/g;
  $str =~ s/\x{05e9}/&shin;/g;
  $str =~ s/\x{05ea}/&tav;/g;

  # <!-- hungaraj -->

  # <!-- evitu, char shajne ne launormaj liternomoj -->
#  $str =~ s/\x{0150}/&Odacute;/g;
#  $str =~ s/\x{0151}/&odacute;/g;
#  $str =~ s/\x{0170}/&Udacute;/g;
#  $str =~ s/\x{0171}/&udacute;/g;

  # <!-- uzu tiujn anstataue -->
  $str =~ s/\x{0150}/&Odblac;/g;
  $str =~ s/\x{0151}/&odblac;/g;
  $str =~ s/\x{0170}/&Udblac;/g;
  $str =~ s/\x{0171}/&udblac;/g;

  # <!-- latvaj -->
  $str =~ s/\x{257;}/&amacro;/g;
  $str =~ s/\x{#275}/&emacr;/g;
  $str =~ s/\x{291;}/&gcommaaccen;/g;
  $str =~ s/\x{299;}/&imacro;/g;
  $str =~ s/\x{311;}/&kcommaaccen;/g;
  $str =~ s/\x{#316}/&lcommaacce;/g;
  $str =~ s/\x{326;}/&ncommaaccen;/g;
  $str =~ s/\x{333;}/&omacro;/g;
  $str =~ s/\x{343;}/&rcommaaccen;/g;
  $str =~ s/\x{363;}/&umacro;/g;

  $str =~ s/\x{#256}/&Amacr;/g;
  $str =~ s/\x{#274}/&Emacr;/g;
  $str =~ s/\x{#290}/&Gcommaacce;/g;
  $str =~ s/\x{#298}/&Imacr;/g;
  $str =~ s/\x{#310}/&Kcommaacce;/g;
  $str =~ s/\x{#315}/&Lcommaacce;/g;
  $str =~ s/\x{#325}/&Ncommaacce;/g;
  $str =~ s/\x{#332}/&Omacr;/g;
  $str =~ s/\x{#342}/&Rcommaacce;/g;
  $str =~ s/\x{#362}/&Umacr;/g;

  # <!-- kimraj -->
  $str =~ s/\x{0176}/&Ycirc ;/g;
  $str =~ s/\x{0177}/&ycirc ;/g;
  $str =~ s/\x{1e80}/&Wgrave;/g;
  $str =~ s/\x{1e81}/&wgrave;/g;
  $str =~ s/\x{1e82}/&Wacute;/g;
  $str =~ s/\x{1e83}/&wacute;/g;
  $str =~ s/\x{1e84}/&Wuml  ;/g;
  $str =~ s/\x{1e85}/&wuml  ;/g;
  $str =~ s/\x{1ef2}/&Ygrave;/g;
  $str =~ s/\x{1ef3}/&ygrave;/g;
  $str =~ s/\x{0174}/&Wcirc ;/g;
  $str =~ s/\x{0175}/&wcirc ;/g;
  $str =~ s/\x{0178}/&Yuml  ;/g;
  $str =~ s/\x{00ff}/&yuml  ;/g;

  # <!-- arabaj -->
  $str =~ s/\x{0628}/&ba;/g;
  $str =~ s/\x{062A}/&ta;/g;
  $str =~ s/\x{062B}/&tha;/g;
  $str =~ s/\x{062C}/&jim;/g;
  $str =~ s/\x{062D}/&Ha;/g;
  $str =~ s/\x{062E}/&hha;/g;
  $str =~ s/\x{062F}/&dal;/g;
  $str =~ s/\x{0630}/&dhal;/g;
  $str =~ s/\x{0631}/&ra;/g;
  $str =~ s/\x{0632}/&zin;/g;
  $str =~ s/\x{0633}/&sin;/g;
  $str =~ s/\x{0634}/&shin1;/g;
  $str =~ s/\x{0635}/&Sad;/g;
  $str =~ s/\x{0636}/&Dad;/g;
  $str =~ s/\x{0637}/&Ta;/g;
  $str =~ s/\x{0638}/&Za;/g;
  $str =~ s/\x{0639}/&ayn;/g;
  $str =~ s/\x{063A}/&ghayn;/g;
  $str =~ s/\x{0641}/&fa;/g;
  $str =~ s/\x{0642}/&qaf;/g;
  $str =~ s/\x{0643}/&kaf1;/g;
  $str =~ s/\x{0644}/&lam;/g;
  $str =~ s/\x{0645}/&mim;/g;
  $str =~ s/\x{0646}/&nun1;/g;
  $str =~ s/\x{0647}/&ha;/g;

  $str =~ s/\x{064E}\x{0627}/&fatha_alif;/g;
  $str =~ s/\x{064E}/&fatha;/g;
  $str =~ s/\x{0627}/&alif;/g;
  $str =~ s/\x{0650}\x{064A}/&kasra_ya;/g;
  $str =~ s/\x{0650}/&kasra;/g;
  $str =~ s/\x{064A}/&ya;/g;
  $str =~ s/\x{0648}\x{064F}/&damma_waw;/g;
  $str =~ s/\x{064F}/&damma;/g;
  $str =~ s/\x{0648}/&waw;/g;
  $str =~ s/\x{064B}/&fathatan;/g;
  $str =~ s/\x{064D}/&kasratan;/g;
  $str =~ s/\x{064C}/&dammatan;/g;
  $str =~ s/\x{0652}/&sukun;/g;
  $str =~ s/\x{0651}/&shadda;/g;

  $str =~ s/\x{0649}/&alif_maqsura;/g;
  $str =~ s/\x{0629}/&ta_marbuta;/g;
  $str =~ s/\x{0623}/&alif_hamza_sure;/g;
  $str =~ s/\x{0625}/&alif_hamza_sube;/g;
  $str =~ s/\x{0622}/&alif_madda;/g;
  $str =~ s/\x{0671}/&alif_wasla;/g;
  $str =~ s/\x{0626}/&ya_hamza;/g;
  $str =~ s/\x{0624}/&waw_hamza;/g;
  $str =~ s/\x{0621}/&hamza;/g;

  $str =~ s/\x{060C}/&ar_komo;/g;
  $str =~ s/\x{066B}/&ar_dekumakomo;/g;
  $str =~ s/\x{061B}/&ar_punktokomo;/g;
  $str =~ s/\x{061F}/&ar_demandopunkto;/g;
  $str =~ s/\x{0660}/&ar_0;/g;
  $str =~ s/\x{0661}/&ar_1;/g;
  $str =~ s/\x{0662}/&ar_2;/g;
  $str =~ s/\x{0663}/&ar_3;/g;
  $str =~ s/\x{0664}/&ar_4;/g;
  $str =~ s/\x{0665}/&ar_5;/g;
  $str =~ s/\x{0666}/&ar_6;/g;
  $str =~ s/\x{0667}/&ar_7;/g;
  $str =~ s/\x{0668}/&ar_8;/g;
  $str =~ s/\x{0669}/&ar_9;/g;
  

#  $str = HTML::Entities::encode_entities_numeric($str, "\x{01D0}\x{014D}\x{012B}\x{01DC}\x{1000}-\x{10FFFF}"); 
  $str = HTML::Entities::encode_entities_numeric($str, "\x{80}-\x{10FFFF}"); 
#  print "encode -> ".Encode::encode($enc, $str)."\n";
  return $str;
}

######################################################################
package HTML::Entities;
sub num_entity {
    sprintf "&#%u;", ord($_[0]);
}    
######################################################################

1;

