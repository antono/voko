#old xt: CLASSPATH=/usr/lib/xml/xp.jar:/usr/lib/xml/xt.jar:/usr/lib/xml/sax.jar

#XTPATH=/home/revo/xt-20020426a-src
#new xt: CLASSPATH=$XTPATH/xt.jar:$XTPATH/lib/xp.jar:$XTPATH/lib/xml-apis.jar
#export CLASSPATH

#/usr/lib/java/bin/java com.jclark.xsl.sax.Driver $1 $2

/usr/bin/xsltproc $2 $1

