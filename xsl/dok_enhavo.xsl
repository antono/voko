<!DOCTYPE xsl:transform>

<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  version="2.0"
  extension-element-prefixes="saxon" 
>

<!-- faras la chefajn paghojn index.html kaj titolo.html el voko/cfg/enhavo.xml -->

<!-- xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
    xmlns:redirect="http://xml.apache.org/xalan/redirect"
    extension-element-prefixes="redirect" -->


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->


<xsl:output method="xhtml" encoding="utf-8"/>
<xsl:variable name="inx" select="'inx/'"/>

<xsl:template match="/vortaro">

  <html>
    <head>
      <!-- meta http-equiv="content-type" content="text/html; charset=utf-8" -->
      <title><xsl:value-of select="@nomo"/></title>
      <xsl:if test="@piktogramo">
         <link rel="SHORTCUT ICON" href="{@piktogramo}"/>
      </xsl:if>
    </head>

    <frameset cols="33%,*">
      <frame name="indekso" src="{concat($inx,pagho[not(kashita='jes')][1]/@dosiero)}"/>
      <frame scrolling="yes" name="precipa" src="titolo.html"/>

      <noframes>
        <h1><xsl:value-of select="@nomo"/></h1>
        <xsl:for-each select="pagho">
          <a href="{concat($inx,@dosiero)}"><xsl:value-of select="@titolo"/></a><br/>
        </xsl:for-each>
      </noframes>
    </frameset>
  </html>

  <xsl:call-template name="titolo"/>
</xsl:template>


<xsl:template name="titolo">
  <xsl:result-document href="titolo.html" method="xhtml" encoding="utf-8">
  <!-- redirect:write select="'titolo.html'" -->
  <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
      <title><xsl:value-of select="@nomo"/></title>
      <link title="artikolo-stilo" type="text/css" 
            rel="stylesheet" href="stl/artikolo.css"/>

      <xsl:if test="bonveno/sercho">
        <xsl:call-template name="script-literoj"/>
      </xsl:if>
    </head>
    <body>

      <h1 align="center" style="color:black; font-size: xx-large"><xsl:value-of select="@nomo"/></h1>

      <xsl:apply-templates/>

    </body>
  </html>
  <!-- /redirect:write -->
  </xsl:result-document>
</xsl:template>


<xsl:template name="script-literoj">
  <script type="text/javascript">
  <xsl:comment>
    function xAlUtf8(t) {
     if (document.getElementById("x").checked) {
        t = t.replace(/c[xX]/g, "\u0109");
        t = t.replace(/g[xX]/g, "\u011d");
        t = t.replace(/h[xX]/g, "\u0125");
        t = t.replace(/j[xX]/g, "\u0135");
        t = t.replace(/s[xX]/g, "\u015d");
        t = t.replace(/u[xX]/g, "\u016d");
        t = t.replace(/C[xX]/g, "\u0108");
        t = t.replace(/G[xX]/g, "\u011c");
        t = t.replace(/H[xX]/g, "\u0124");
        t = t.replace(/J[xX]/g, "\u0134");
        t = t.replace(/S[xX]/g, "\u015c");
        t = t.replace(/U[xX]/g, "\u016c");
        if (t != document.getElementById("q").value) {
           document.getElementById("q").value = t;
        }
     }
   }
//</xsl:comment>
  </script>
</xsl:template>


<xsl:template match="sercho[@tipo='google']">
   <div align="center">
     <form method="get" action="http://www.google.be/search" style="text-align: center">
     <p>
       <img src="http://www.google.com/logos/Logo_25wht.gif" border="0" alt="Google" align="absmiddle"/>
       <input type="text" id="q" name="q" onKeyUp="xAlUtf8(this.value)" size="31" maxlength="255" value=""/>
       <input type="submit" name="btnG" value="trovu"/>
       <input type="checkbox" accesskey="x" id="x" checked="checked"/>
       <xsl:text>anstata&#x016d;igu&#xa0;cx,&#xa0;gx,&#xa0;...,&#xa0;ux</xsl:text><br/>
     </p>
     <input type="hidden" name="hl" value="eo"/>
     <input type="hidden" name="ie" value="utf-8"/>
     <input type="hidden" name="oe" value="utf-8"/>
     <input type="hidden" name="sitesearch" value="www.uni-leipzig.de"/>
     <input type="hidden" name="hq" value="inurl:esperanto/voko/revo/art"/>
     </form>
   </div>
</xsl:template>


<xsl:template match="alineo">
  <p style="width: 80%; margin-left: 10%">
    <xsl:apply-templates/>
  </p>
</xsl:template>


<xsl:template match="bildo">
  <img src="{@loko}" align="center" alt="titolbildo"/>
</xsl:template>


<xsl:template match="url">
  <a href="{@ref}"><xsl:apply-templates/></a>
</xsl:template>



<!-- /xsl:stylesheet -->
</xsl:transform>



