#!/usr/bin/perl
#########################################################
# Jen tre malgranda TTT-servileto
# Ghi estas farita nur por loka uzo de unusola uzanto.
# Principe ghi funkcias ankau en la reto, sed ghi
# nek estas sekura nek eltenas multajn uzantojn!
#
# voku ghin ekz. per
#
#    perl miniweb.pl 1080
# 
# 1080 estas la pordo (angle: port), kie
# ghi auskultas al klientoj, vi povas uzi alian numeron.
#
# La startpaghon vi ricevas per via
# TTT-legilo tajpante la linion:
#
#    http://localhost:1080/
#
# Anstatau localhost vi povas uzi
# ankau la IP-adreson de via komputilo.
##########################################################

########## kelkaj konstantoj ############

# se ne estas indikita la pordo, provu
# konektighi che la kutima TTT-pordo

($port) = @ARGV;
$port = 80 unless $port;

# diversaj necesajhoj por la TCP/IP-protokolo

$AF_INET = 2;
$SOCK_STREAM = 1;
$sockaddr = 'S n a4 x8';

# la baza pagho trovighas unu etaghon pli 
# alte kaj nomighas index.html

$doc_path='..';
$doc_inx='/index.html';

# la programetoj trovighas en la dosiero 'bin'

$exe_path='../bin';

# skribu signojn tuj

$|=1;

######### komenco de la programo ################

# ricevu la protokolon kaj la servnomon

($name, $aliases, $proto) = getprotobyname('tcp');
if ($port !~ /^\d+$/) {
    ($name, $aliases, $port) = getservbyport($port, 'tcp');
}

print "protokolo = $name\n";
print "pordo = $port\n";

# konstruu kontektilon (angle: socket)

$this = pack($sockaddr, $AF_INET, $port, "\0\0\0\0");
socket(S, $AF_INET, $SOCK_STREAM, $proto) || die "konektileraro: $!";
bind(S,$this) || die "ligeraro: $!";

# auskultu

listen(S,5) || die "konekteraro: $!";
print "atendas klienton ...\n";

# daure akceptu konektojn

while (1) {
  ($addr = accept(NS,S)) || die $!;

  print "akcepto en ordo\n";

  ($af,$port,$inetaddr) = unpack($sockaddr,$addr);
  @inetaddr = unpack('C4',$inetaddr);
  print "$af $port @inetaddr\n";

  # legu la deziron, analizu ghin kaj redonu dokumenton

  $line= <NS>;
     ($method,$doc,$param)=&Eval($line);
     if ($doc) {
	if ($method eq 'GET') {
          &SendDoc(NS,$doc,$param);
        } else {
          &SendDefaultDoc(NS);
        };
     } else {
        &SendDefaultDoc(NS);
     };

     # fermu la konekton
     close  NS;
}

# analizas deziron kaj redonas la
# ghustan dosiernomon

sub Eval {

  local $line=$_[0];
  local $doc_str;
  local $doc,$param,$method,$query_string;

  # $line havas la formon: GET dokumento aliaj_informoj
  print "deziro: $line\n";
  $line =~ /(GET|POST) ([^ ]*)/;
  $method = $1;
  $doc_str = $2;  

  # dispartigu $doc_str che la demandsigno 
  # en dosiernomon kaj demandsignaron
  $doc_str =~ /([^\?]*)\??(.*)/;
  $doc = $1;
  $query_string = $2;

  # forigu spacsignojn en $doc
  $doc =~ s/%20|\+/ /g;
  # dispartigu eblan komandon kaj parametrojn
  $doc =~ /([^ ]*) ?(.*)/;
  $doc = $1;
  $param = $2;

  $ENV{'QUERY_STRING'} = $query_string;
  $ENV{'REQUEST_METHOD'} = $method;
  return ($method,$doc,$param);
}

# sendas dokumenton

sub SendDoc {
  local ($SOCK,$doc,$param)=@_;
  local $size;
	
  # sendu la kapliniojn
  print $SOCK "HTTP/1.0 200 OK\n";
  print $SOCK "MIME-Version: 1.0\n";

  # analizu la dosiervoston
  if ($doc eq '/') {
    # radiko -> sendu la bazan paghon ...
    print "sendas: $doc_path"."/index.html\n";
    print $SOCK "Content-type: text/html\n\n";
    #sendu la dosieron
    open FILE,$doc_path."/index.html";
    while (<FILE>) { print $SOCK $_ };
    close FILE;

  } elsif ($doc =~ /\.html$|\.htm$/) {
    # html-dokumento...
    print "sendas: $doc_path$doc\n";
    print $SOCK "Content-type: text/html\n\n";
    #sendu la dosieron
    open FILE,$doc_path.$doc;
    while (<FILE>) { print $SOCK $_ };
    close FILE;

  } elsif ($doc =~ /\.gif$/) {
    # gif-bildeto
    print "sendas: $doc_path$doc\n";
    print $SOCK "Content-Type: image/gif\n";
    $size = -s $doc_path.$doc;
    print "grandeco: $size\n";
    print $SOCK "Content-Length: $size\n\n";
    #sendu la dosieron
    open FILE,$doc_path.$doc;
    raw_copy(FILE,$SOCK);
    close FILE;

  } elsif ($doc =~ /\.jpg$/) {
    # jpeg-bildeto
    print "sendas: $doc_path$doc\n";
    print $SOCK "Content-Type: image/jpeg\n";
    $size = -s $doc_path.$doc;
    print "grandeco: $size\n";
    print $SOCK "Content-Length: $size\n\n";
    #sendu la dosieron
    open FILE,$doc_path.$doc;
    raw_copy(FILE,$SOCK);
    close FILE;

  } elsif ($doc =~ /\.exe$/) {
    # la dosieron produktas programo -> startu ghin
    print "startas: $exe_path$doc $param\n";
    print $SOCK `$exe_path$doc $param`; 

  } elsif ($doc =~ /\.pl$/) {
    # perl-programeto produktas la dosieron -> startu ghin
    print "startas: perl $exe_path$doc $param\n";
    print $SOCK `perl $exe_path$doc $param`;

  } else {
    # en chiu alia kazo sendu kiel simpla teksto
    print "sendas: $doc_path$doc\n";
    print $SOCK "Content-type: text/plain\n\n";
    # sendu la dosieron
    open FILE,$doc_path.$doc;
    while (<FILE>) { print $SOCK $_ };
    close FILE;
  }
}

# sendas erarmesaghon

sub SendDefaultDoc {
  local $SOCK=$_[0];

  select $SOCK;
  print "HTTP-Version 1.0\n";
  print "MIME-Version 1.0\n";
  print "Content-type: text/html \n \n";
  print "<html>\n<head>\n<title>erarmesagho</title>\n</head>\n";
  print "<body>\n<h1>Eraro: Ne traktebla deziro!</h1>\n";
  print "La dezirita dokumento ne povis esti sendata.\n";
  print "</body>\n</html>\n";
  select STDOUT;
};

# kopias binaran dosieron

sub raw_copy {
    local($FROM, $TO) = @_;
    local($len, $buf, $written, $offset, $sum);

    # deklaru la dosierojn binaraj
    # tio estas nepre necesa sub Windows
    binmode $FROM;
    binmode $TO;

    while (($len = sysread($FROM, $buf, 4096)) != 0) {
	&main'set_timeout() if defined &main'set_timeout;
        if (!defined $len) {
            next if $! =~ /^Interrupted/;
            print "legeraro: $!";
	}
	$offset = 0;
	while ($len) {
	    $written = syswrite($TO, $buf, $len, $offset);
	    print "skriberaro: $!"
	        unless defined $written;
	    $len -= $written;
	    $offset += $written;
	}
    }
}

