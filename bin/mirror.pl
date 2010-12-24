#!/usr/bin/perl 
#
# Programm zum Spiegeln von Verzeichnissen via FTP
#
# Copyright: c't, Heise Verlag
# Autor: Erich Kramer, 1999

# wd 3.6.2003: umgestellt von ftp auf sftp mit Batchdatei
# wd 26.01.2007 umgestellt auf tar-Archiv als Ziel

$| = 1;

use strict "vars"; # alle Variablen müssen deklariert werden!
use strict "subs";
no strict "refs";

package main;

my $stop = 0;
my $configdatei = '';
my $site = '';

while (@ARGV) {
    if ($ARGV[0] eq '-stop') { 
	$stop = 1; 
         # Nach Erstellung von mirror.tmp anhalten, d.h. nix übertragen
	shift @ARGV;
    } elsif ($ARGV[0] eq '-c') {
	shift @ARGV;
	$configdatei = shift @ARGV;
    } else {
	$site = shift @ARGV;
	last;
    }
}

my $version = "0.7";
my $stand = "12.06.2003";

my %config = ();    # Inhalt der Konfigurationsdatei
my %sr = ();        # zu ersetzende Zeichenketten

# ToDo-Listen:
my @mirror = ();            # Liste der zu übertragenden Dateien
my @mirror_ver = ();        # Liste der zu neuen Verzeichnisse
my @unlink = ();            # Liste der zu löschenden Dateien
my @unlink_ver = ();        # Liste der zu löschenden Verzeichnisse
my @error_mirror = ();      # Fehlerliste der zu übertragenden Dateien
my @error_mirror_ver = ();  # Fehlerliste neue Verzeichnisse
my @error_unlink = ();      # Fehlerliste zu löschenden Dateien
my @error_unlink_ver = ();  # Fehlerliste zu löschende Verzeichnisse

# Dateinamen:
unless ($configdatei) {
    $configdatei = $ENV{"VOKO"}."/../etc/mirror.cfg";   # Konfigurationsdatei
}

readconfig($configdatei);

my $srDatei = $config{"SrFile"};           # zu ersetzende Zeichenketten
my $tempdatei = "/tmp/tmp.tmp";	  # temporäre Konvertierungsdatei
my $mirrordat = $config{"MirrorDat"}."/mirror.dat";     # Sicherung, Zustaende der Dateien
my $mirrortmp = $config{"MirrorDat"}."/mirror.tmp"; # Neuerstellung der mirrordat
my $logdatei = $config{"LogDir"}."/smirror.log";     # Übertragungs-Logdatei

my $batchfile =  $config{"MirrorDat"}."/mirror.batch"; # Batchdatei für sftp
my $max_tries = 1;
my $logdir = $config{"LogDir"};
my $include = $config{"include"};

# Optionen für die Archivierung der geänderten Dateien mit tar
my $tar_dir = $config{"LocalDir"};
my $tar_cmd = "tar -C $tar_dir -h -rf ";
my $zip_cmd = 'gzip';
my @now = gmtime(time());
my $now_str = sprintf('%4d%02d%02d',$now[5]+1900,$now[4]+1,$now[3]);
my $tar_file = $config{'TarFilePrefix'}.$now_str.".tar";
my $tgz_file = $config{'TarFilePrefix'}.$now_str.".tgz";
my $ren_tar_tgz = "mv $tar_file.gz $tgz_file";
$tar_cmd .= "$tar_file ";
my $del_file = $config{TarDelFile};
$del_file =~ /^(.*)\/([^\/]+)$/;
my $del_path = $1; my $del_filename = $2; # $del_path=~s/^(.*)\/[^\/]+$/$1/;

my $tar_del_file = "tar ";
$tar_del_file .= "-C ".$del_path if ($del_path);
$tar_del_file .= " -rf ".$tar_file." ".$del_filename;

# ftp-Variablen:
#my $ftp_port = 21;
my $retry_call = 1;
my $attempts = 2;
my $text_mode;

# Daten aus der mirrordat:
my %laenge = ();      # Länge der Dateien
my %datum = ();       # Datum der Dateien

# Extensions:
my @ReplaceIn = ();
my @exclude = ();

#******
# Main:
#******
print "Homepage-Upload $version von Erich Kramer modifiziert von wd\n";
print "Stand: $stand\n";

#**********************************
# Einlesen der Konfigurationsdatei:
#**********************************
sub readconfig {
    my $configdatei = shift;
    open(CONFIG, "< $configdatei") 
	|| die ("\nkann Konfigurationsdatei $configdatei nicht oeffnen");

# Suche Beginn des Abschnittes [$site]
    if ($site) {
	while (<CONFIG>) {
	    last if $_ =~ /\[$site\]/; 
	}
	unless ($_ =~ /\[$site\]/) {
	    die "Agord-sekcio \"$site\" ne trovighis en $configdatei\n";
	}
    }

    while(<CONFIG>) {
	last if ($_ =~ /^\[/);

	next if ($_ =~ /^(?:#|\s*\n)/);	 
        # Kommentare und Leerzeilen auslassen
        my ($bezeichner,$wert);
        ($bezeichner,$wert) = split (/=/, $_);
        $wert =~ s/\n//;             		 
        $config{$bezeichner} = $wert;
    }
    close (CONFIG);

    unless ($config{"LocalDir"}) {
       unless ($site) {
	  die "Eraro en agorddosiero au vi forgesis doni retejon en komandlinio.\n";
      } else {
	  die "Eraro en agorddosiero.\n";
      }
   }
}

# Extension-Liste definieren:
@ReplaceIn = split (/,/, $config{'ReplaceIn'});
@exclude = split (/,/, $config{'exclude'});

# Ersetzungs-Strings laden:
open(SR, "< $srDatei") 
  || die "\nkann Konfigurationsdatei \"$srDatei\" nicht oeffnen";
while(<SR>) {
  my ($bezeichner,$wert);
  ($bezeichner,$wert) = split (/\|/, $_);
  $wert =~ s/\n//;             	
  $sr{$bezeichner} = $wert;
}
close (SR);


# löschen der temporären Verzeichnisstruktur mirror.tmp
unlink ($mirrortmp);

#*********************************
# Einlesen der Originaldateidaten:
#*********************************
open(MIRRORDAT, "< $mirrordat") 
  || die "\nkann $mirrordat nicht oeffnen";
while(<MIRRORDAT>) {
  my ($Datei,$Laenge,$Datum);
  ($Datei,$Laenge,$Datum) = split (/\|/, $_);
  $Datum =~ s/\n//;           # das Return (\n) am Ende löschen
  $laenge{$Datei} = $Laenge;
  $datum {$Datei} = $Datum;
}
close(MIRRORDAT);

# ToDo-Listen erstellen:
&ToDo_Liste($config{'LocalDir'});
&Unlink_Liste;

if ($stop) { exit; }

# Spiegel starten
my $n_mirror=1;
while (! &mirror ) {
    if ($n_mirror++ > $max_tries) { 
	die "Probleme beim Spiegeln. Abbruch nach 3. Versuch\n"
	}
}

print "\n\nSpiegelvorgang abgeschlossen.\n";

# Wenn der Spiegelvorgang erfogreich war, temporäre lokale 
# Verzeichnisstruktur mirror.tmp in mirror.dat übernehmen
unlink ($mirrordat);
rename ($mirrortmp,$mirrordat);

# und Batch-Datei vorsichtshalber sichern
if (-s $batchfile) {
	my $date=`date +%Y%m%d_%H%M%S`;
	$date =~ s/\s*$//;
	rename ($batchfile,"$logdir/mirror.batch.$date");
} else {
	unlink $batchfile;
}

################################################################

# ToDo-Liste generieren
sub ToDo_Liste
  {
  my ($dir) = @_;
  my $dir_eintrag;
  my @dir_eintraege;  #das gesammte Verzeichnis

  # ggf. nur bestimmte eingeschlossene Dateien beachten
  if ($dir eq $config{"LocalDir"} and $config{"MirrorDirs"}) {
      my $mirrordirs = $config{"MirrorDirs"};
      @dir_eintraege = map {s/^$dir\///, $_} glob("$dir/$mirrordirs");

  } elsif ($include) {
      @dir_eintraege = map {s/^$dir\///, $_} glob("$dir/$include");
        
  } else {
     opendir (DIR, $dir) || die ("\nVerzeichnis $dir nicht gefunden");
     @dir_eintraege = readdir(DIR);
     closedir (DIR);
  }


 NAECHSTER_EINTRAG:
  foreach $dir_eintrag (@dir_eintraege)
    {
    next if $dir_eintrag eq ".";
    next if $dir_eintrag eq "..";
#    next if (-l "$dir$dir_eintrag"); # don't follow symlinks

    # Ausgeschlossene Dateien auslassen:
    for (@exclude) {
	my $eintrag = $dir_eintrag;
	# Dateien mit Dateierweiterungen, die in der mirror.cfg unter
	# exclude angegeben sind, werden nicht beachtet.
	# Die Verzeichniseinträge und die Ausschluß-Dateierweiterungen
	# werden beide klein geschrieben
	tr/A-Z/a-z/;
	$eintrag =~ tr/A-Z/a-z/;
	next NAECHSTER_EINTRAG 
	  if ( rightstr($eintrag,length($_)) eq "$_");
      }
		
    my $eintrag = "$dir$config{'slash'}$dir_eintrag";
    my ($size,$mtime) = (stat($eintrag))[7,9];

    # Wenn Datei verändert oder neu
    if ((-f _) && ( ($laenge{$eintrag} ne $size) 
		    || ($datum{$eintrag} != $mtime) )) {
      push (@mirror, "$eintrag");
    }
    if (-d _) {
      if ($laenge{$eintrag} ne "V") {
	push (@mirror_ver, "$eintrag");
      }
      ToDo_Liste("$eintrag");
    }
  }

  #******************************************************************
  # aktuelle Verzeichnisstruktur in die Datei mirror.tmp übernehmen *
  #******************************************************************
  open (MIRRORTMP, ">> $mirrortmp") 
    || die ("\nkann $mirrortmp nicht oeffnen!");
 NAECHSTER_EINTRAG2:
  foreach $dir_eintrag (@dir_eintraege) {
    next if $dir_eintrag eq ".";
    next if $dir_eintrag eq "..";
#    next if (-l "$dir$dir_eintrag"); # don't follow symlinks

    # Ausgeschlossene Dateien auslassen:
    for (@exclude)
      {
	my $eintrag = $dir_eintrag;
	tr/A-Z/a-z/;
	$eintrag =~ tr/A-Z/a-z/;
	next NAECHSTER_EINTRAG2 
	  if ( rightstr($eintrag,length($_)) eq "$_");
      }
    my ($size,$mtime) = 
      (stat("$dir$config{'slash'}$dir_eintrag"))[7,9];
    print MIRRORTMP 
      "$dir$config{'slash'}$dir_eintrag|$size|$mtime\n"  if (-f _);
    print MIRRORTMP 
      "$dir$config{'slash'}$dir_eintrag|V|$mtime\n"  if (-d _);
    }
  close(MIRRORTMP);
}

#*******************************************************
# Liste der gelöschten Dateien/Verzeichnisse erstellen *
#*******************************************************
sub Unlink_Liste {
  my $eintrag;
  foreach $eintrag (reverse sort keys(%laenge)) {
    if ( !(-e $eintrag) ) { # existiert Datei/Verzeichnis nicht?
      if ($laenge{$eintrag} eq "V") {
        push (@unlink_ver, "$eintrag");
      } else {
        push (@unlink, "$eintrag");
      }
    }
  }
}


#**********************************
# Dateien übertragen bzw. Löschen *
#**********************************
sub mirror {
  @error_mirror = ();
  @error_mirror_ver = ();
  @error_unlink = ();
  @error_unlink_ver = ();

  # Log-Datei öffnen:
  open(LOG, ">> $logdatei") 
    || die "\nkann Logdatei $logdatei nicht oeffnen";

#  print LOG "-" x 10, "Start um ", `date`, "-" x 10;

  # ISDN-Leitung aufmachen
#  `ping -qc5 -i1 $config{'RemoteServer'}`; 

  # beim ftp-Server anmelden:
#  print "\nkontaktiere $config{'RemoteServer'} ...";
#  if( &ftp::open( $config{'RemoteServer'}, 
#		  $ftp_port, $retry_call, $attempts ) != 1 ) {
#    print "\nkann $config{'RemoteServer'} nicht erreichen";
#    return 0;
#  }
#  print "\nuser login...";
#  if( ! &ftp::login( $config{'UserID'}, $config{'Passwd'} ) ) {
#    print "\nLogin fehlgeschlagen";
#    return 0;
#  }

  # Batchdatei öffnen
  open BATCH,">$batchfile" or die "Kann $batchfile nicht öffnen: $!\n";

  # alte Dateien vom Server löschen:
  my $n = 1;
  if (@unlink) {
    print "\n\nloesche alte Dateien...";
    for (@unlink) {
      my ($verzeichnis,$name,$rem_file);

      $verzeichnis = $config{'RemoteDir'} . Verzeichnis($_);
      $name = Name($_);
      # Namen unter DOS klein schreiben, 
      # da sie sonst komplett in Großbuchstaben übertragen werden
      $name =~ tr/A-Z/a-z/  if ($config{'slash'} eq "\\");     
      $rem_file = "$verzeichnis/$name";
      print "\n".$n++."/".($#unlink+1)." - $rem_file";
      
#      if( ! &ftp::delete( $rem_file ) ) {
#	print " - kann Datei nicht loeschen";
#	push (@error_unlink, $_);
#      } else {
#      	print LOG "unlink $config{'RemoteServer'}$rem_file\n";
#      }

      print BATCH "rm $rem_file\n";

    }
  } else {
    print "\n\nkeine alten Dateien zu loeschen";
  }

  # alte Verzeichnisse auf dem Server löschen:
  $n = 1;
  if (@unlink_ver) {
    print "\n\nloesche alte Verzeichnisse...";
    for (@unlink_ver) {
      my ($verzeichnis,$name,$rem_dir);
      $verzeichnis = $config{'RemoteDir'} . Verzeichnis($_);
      $name = Name($_);
      $rem_dir = "$verzeichnis/$name";
      print "\n".$n++."/".($#unlink_ver+1)." - $rem_dir";

#      if( ! &ftp::deldir( $rem_dir ) ) {
#	print " - kann Verzeichnis nicht loeschen";
#	push (@error_unlink_ver, $_);
#      } else {
#      	print LOG "rmdir $config{'RemoteServer'}$rem_dir\n";
#      }

      print BATCH "rmdir $rem_dir\n";

    }
  } else {
    print "\n\nkeine alten Verzeichnisse zu loeschen";
  }

  # neue Verzeichnisse auf dem Server erstellen:
  $n = 1;
  if (@mirror_ver) {
    print "\n\nerstelle neue Verzeichnisse...";
    for (@mirror_ver) {
      my ($verzeichnis,$name,$rem_dir);
      $verzeichnis = $config{'RemoteDir'} . Verzeichnis($_);
      $name = Name($_);
      $rem_dir = "$verzeichnis/$name";
      print "\n".$n++."/".($#mirror_ver+1)." - $rem_dir";
      
#      if( ! &ftp::mkdir( $rem_dir ) ) {
#	print " - kann Verzeichnis nicht erstellen";
#	push (@error_mirror_ver, $_);
#      } else {
#      	print LOG "mkdir $config{'RemoteServer'}$rem_dir\n";
#      }

      print BATCH "mkdir $rem_dir\n";

    }
  } else {
    print "\n\nkeine neuen Verzeichnisse zu erstellen";
  }

  # Dateien zum Server übertragen:
  $n = 1;
  if (@mirror) {
    print "\n\nuebertrage Dateien...";
    for (@mirror) {
      my ($verzeichnis,$name,$rem_file,$local_file,$put_file);
      my $replace = 0;
      
      $verzeichnis = $config{'RemoteDir'} . Verzeichnis($_);
      $name = Name($_);
      # Namen unter DOS klein schreiben
      $name =~ tr/A-Z/a-z/  if ($config{'slash'} eq "\\");     
      
      $rem_file = "$verzeichnis/$name";
      $local_file = $_;

      print "\n".$n++."/".($#mirror+1)." - $local_file";
      
      # muß eine Ersetzung vorgenommen werden?
      for (@ReplaceIn) {
	my $file = $local_file;
	# In Dateien mit Erweiterungen, die in der mirror.cfg unter
	# ReplaceIn angegeben sind, werden Ausdrücke ersetzt.
	# Die Dateinamen und die Erweiterungen werden beide klein 
	# geschrieben, damit ein groß-kleinschreibungs-unabhängiger
	# Vergleich möglich wird.
	tr/A-Z/a-z/;
	$file=~ tr/A-Z/a-z/;
	$replace = 1  if ( rightstr($file,length($_) + 1) eq ".$_");
      }

      if ($replace == 1) {
	&s_r($local_file);
	$put_file = $tempdatei;
	$text_mode = 1;	           # Dateien, in denen ersetzt wird, 
      }				   # werden in Textmodus übertragen.
      else {
	$put_file = $local_file;
	$text_mode = 0;
      }
      
#      &ftp::type( $text_mode ? 'A' : 'I' );
#      if( ! &ftp::put( $put_file, $rem_file ) ) {
#	print " - kann Datei nicht uebertragen";
#	push (@error_mirror, $_);
#      } else {
#      	# Logdatei ergänzen:
#      	print LOG "put ";
#      	print LOG "with search&replace " if ($replace == 1);
#      	print LOG "$local_file -> $config{'RemoteServer'}/$rem_file";


      print BATCH "put $put_file $rem_file\n";

      	# Rechte setzen, falls es ein CGI-Script war:
      	if ( substr(Verzeichnis($local_file),0,
		    length($config{'cgi-bin'})) eq $config{'cgi-bin'})
	  {
	    print "\nsetze Zugriffsrechte fuer $rem_file...";

#	    if( ! &ftp::chmod( $rem_file, 457 ) ) {	# chmod 711
#	      print " - Zugriffsrechte konnten nicht gesetzt werden";
#	      print LOG " - konnte Zugriffsrechte nicht setzten";
#	      push (@error_mirror, $_);
#	    } else {
#	      print LOG " - Zugriffsrecht auf Ausfuehrbar gesetzt";
#	      print " - o.k.";
#	    }

	    print BATCH "chmod 711 $rem_file\n";
	  }
#      	print LOG "\n";
#      }
    }
  } else {
    print "\n\nkeine Dateien zu uebertragen";
  }

# &ftp::close();
  close BATCH;

  print "\n";

  # Dateien per sftp übertragen
#  if (-s $batchfile) {	
#    open LOG1,"sftp -b $batchfile ".$config{'UserID'}."@".
#      $config{'RemoteServer'}."|";
#    while (<LOG1>) { print; };
#    close LOG1;
#  }

  # Dateien in tar-Archiv speichern
  if (-s $batchfile) {
      unlink($del_file);
      print "Fuege neue/geaenderte Dateien in Tar-Archiv $tar_file ein...\n";
      open BATCH, $batchfile or die "Konnte $batchfile nicht oeffnen: $!\n";
      open DEL, ">$del_file" or die "Konnte $del_file nicht anlegen: $!\n"; 
      my $line;
      while ($line=<BATCH>) {
#	  print "LINE: $line";
	  if ($line =~ /^put\s+([^ ]+)\s+([^ ]+)\s*$/) {
	      my $file = $2;
	      $file =~ s/^\///;
	      `$tar_cmd $file`;
	  } elsif ($line =~ /^rm\s+(.*?)\s*$/) {
	      my $file = $1;
	      $file =~ s/^\///;
#	      print "DELETE: $line";
	      print DEL "$file\n";
	  }
      }
      # add delete file to tar archiv
      close DEL;
      if (-s $del_file) {
	  print "$tar_del_file\n";
	  `$tar_del_file`;
      }
      print "Komprimiere Tar-Archiv...\n";
      print "$zip_cmd $tar_file\n";
      `$zip_cmd $tar_file`;
      print "$ren_tar_tgz\n";
      `$ren_tar_tgz`;
      close BATCH;
  }

  print LOG "-" x 10, "Ende um ", `date`, "-" x 10;  
  close (LOG);
#  if (($#error_mirror != -1) 
#      || ($#error_mirror_ver != -1) 
#      || ($#error_unlink != -1) 
#      || ($#error_unlink_ver != -1) ) {
#    print "\nEs sind bei der Uebertragung Fehler aufgetreten!";
#    @mirror     = @error_mirror;
#    @mirror_ver = @error_mirror_ver;
#    @unlink     = @error_unlink;
#    @unlink_ver = @error_unlink_ver;
#    return (0);
#  } else {
    return (1);
#  }
}


#***************************************************
# Suchen und erstzen in der zu übertragenden Datei *
#***************************************************
sub s_r(@_) {
  my ($quelldatei) = @_;
	
  open (QUELLE, "< $quelldatei") 
    || die "kann $quelldatei nicht oeffnen";
  open (ZIEL, "> $tempdatei") 
    || die "kann $tempdatei nicht ueberschreiben";;
	
  my $zeile;
  while ($zeile = <QUELLE>) {
    for (keys %sr) {
      $zeile =~ s/$_/$sr{$_}/g;
    }
    print ZIEL "$zeile";
  }

  close (QUELLE);
  close (ZIEL);
}


#*******************************************
# Dateinamen aus lokalem Pfad herausnehmen *
#*******************************************
sub Verzeichnis_Lokal(@_) {
  my ($pfad) = @_;

  $pfad = substr($pfad,0,rindex($pfad,$config{'slash'}));
  return $pfad;
}


#******************************************
# (DOS-) Pfad in relativen Pfad umwandeln *
#******************************************
sub Verzeichnis(@_) {
  my ($pfad) = @_;

  my ($localdir);

  $localdir = $config{'LocalDir'};
  $localdir =~ s#\\#/#g;        # bs -> sl
  $pfad     =~ s#\\#/#g;        # bs -> sl
  $pfad     =~ s#$localdir##g;  # lokalen Start-Pfad raus
  $pfad = substr($pfad,0,rindex($pfad,"/"));
  return $pfad;
}


#************************************************
# (DOS-) Pfad in relativen Pfad+Datei umwandeln *
#************************************************
sub Verzeichnis_Dat(@_) {
  my ($pfad) = @_;

  my ($localdir);

  $localdir = $config{'LocalDir'};
  $localdir =~ s#\\#/#g;        # bs -> sl
  $pfad     =~ s#\\#/#g;        # bs -> sl
  $pfad     =~ s#$localdir##g;  # lokalen Start-Pfad raus
  return $pfad;
}


#***************************************
# Datei aus relativen Pfad extrahieren *
#***************************************
sub Name(@_) {
  my ($verzeichnis) = @_;
  my ($name);

  $verzeichnis =~ s#\\#/#g;        # bs -> sl
  $name = substr($verzeichnis,rindex($verzeichnis,"/")+1,
		 length($verzeichnis));
  return $name;
}


#**************************************
# rechten Teil eines Strings ausgeben *
#**************************************
sub rightstr(@_) {
  my ($string,$anzahl_zeichen) = @_;

  $string = substr($string,length($string)-$anzahl_zeichen,
		   length($string));
  return $string;
}

