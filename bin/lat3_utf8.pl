#!/usr/bin/perl

# konvertas de lat3 al utf8
# inklude de la linio charset = ... 
# voku: lat3_utf8.pl < lat3.html > utf8.html

while (<>) {

    # konverti la indikon charset=...
    s/charset=iso-8859-3/charset=utf-8/i;

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

    print;
};








