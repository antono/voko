<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
  xmlns:redirect="http://xml.apache.org/xalan/redirect"
    extension-element-prefixes="redirect">


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->


<xsl:output method="html" version="4.0" encoding="utf-8"/>

<xsl:variable name="ordigo">../cfg/ordigo.xml</xsl:variable>

<xsl:template match="/">
  <html>
    <head>
      <title>alfabeta indekso</title>
      <link title="indekso-stilo" type="text/css" 
            rel="stylesheet" href="../stl/indeksoj.css"/>
    </head>
    <body>
      <table cellspacing="0">
        <tr>
          <td class="aktiva"><a href="../inx/_eo.html">Esperanto</a></td>
          <td class="fona"><a href="../inx/_lng.html">Lingvoj</a></td>
          <td class="fona"><a href="../inx/_fak.html">Fakoj</a></td>
          <td class="fona"><a href="../inx/_ktp.html">ktp.</a></td>
        </tr>
        <tr>
          <td colspan="4" class="enhavo">
            <h1>alfabeta indekso</h1>
           
            <b style="font-size: 120%">
            <xsl:call-template name="literoj">
              <xsl:with-param name="lit" select="xxx"/>
            </xsl:call-template>
            </b>
 
            <xsl:apply-templates select="//kap-oj"/>
          </td>
        </tr>
      </table>
    </body>
  </html>
</xsl:template>

<xsl:template match="litero">

  <xsl:variable name="lit" select="@name"/>
  <redirect:write select="concat('kap_',$lit,'.html')">

  <html>
    <head>
      <title>alfabeta indekso</title>
      <link title="indekso-stilo" type="text/css" 
            rel="stylesheet" href="../stl/indeksoj.css"/>
    </head>
    <body>
      <table cellspacing="0">
        <tr>
          <td class="aktiva"><a href="../inx/_eo.html">Esperanto</a></td>
          <td class="fona"><a href="../inx/_lng.html">Lingvoj</a></td>
          <td class="fona"><a href="../inx/_fak.html">Fakoj</a></td>
          <td class="fona"><a href="../inx/_ktp.html">ktp.</a></td>
        </tr>
        <tr>
          <td colspan="4" class="enhavo">

            <xsl:call-template name="literoj">
              <xsl:with-param name="lit" select="$lit"/>
            </xsl:call-template>

  <h1>esperanta <xsl:value-of 
      select="substring(document($ordigo)/ordigo/lingvo[@lng='eo']/l[@name=$lit],1,1)"/>...
  </h1>

  <xsl:apply-templates/>

      </td>
        </tr>
      </table>
    </body>
  </html>
  </redirect:write>

</xsl:template>

<xsl:template match="v">
  <xsl:choose>
    <xsl:when test="contains(@mrk,'.')">
      <a href="../art/{substring-before(@mrk,'.')}.html#{@mrk}" 
        target="precipa">
        <xsl:apply-templates select="k"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <a href="../art/{@mrk}.html" target="precipa">
        <b><xsl:apply-templates select="k"/></b>
      </a>
    </xsl:otherwise>
  </xsl:choose>
  <br/>
</xsl:template>

<xsl:template match="k">
  <xsl:value-of select="translate(.,'/','')"/>
</xsl:template>

<xsl:template name="literoj">
  <xsl:param name="lit"/>
  <xsl:for-each select="document($ordigo)/ordigo/lingvo[@lng='eo']/l">
    <xsl:choose>
      <xsl:when test="$lit=@name">
        <b class="elektita">
          <xsl:value-of select="substring(.,1,1)"/>
        </b><xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <a href="kap_{@name}.html">
          <xsl:value-of select="substring(.,1,1)"/>
        </a><xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>






