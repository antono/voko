<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->

<xsl:output method="xhtml" encoding="utf-8"/>
<xsl:strip-space elements="kap uzo trd"/>

<xsl:variable name="enhavo">../cfg/enhavo.xml</xsl:variable>

<xsl:key name="autoroj" match="//entry" use="substring-before(msg,':')"/>

<xsl:template match="/">
  <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
      <title>laste &#x015d;an&#x011d;itaj artikoloj</title>
      <link title="indekso-stilo" type="text/css" 
            rel="stylesheet" href="../stl/indeksoj.css"/>
    </head>
    <body>
      <table cellspacing="0">
        <xsl:call-template name="menuo-ktp"/>
        <tr>
          <td colspan="{count(document($enhavo)//pagho[not(@kashita='jes')])}" 
              class="enhavo">
            <h1>laste &#x015d;an&#x011d;itaj</h1>
            <ul>
              <xsl:for-each select="//entry[count(.
                |key('autoroj',substring-before(msg,':'))[1])=1]">

                <xsl:sort select="substring-before(msg,':')"/>

                <li>
                  <a>
                    <xsl:attribute name="href">
                      <xsl:text>#</xsl:text>
                      <xsl:call-template name="autoro">
                        <xsl:with-param name="spaco" select="'_'"/>
                      </xsl:call-template>
                    </xsl:attribute>
                    <xsl:call-template name="autoro">
                      <xsl:with-param name="spaco" select="' '"/>
                    </xsl:call-template>
                  </a>
                </li>
              
              </xsl:for-each>
            </ul>

            <xsl:for-each select="//entry[count(.
                |key('autoroj',substring-before(msg,':'))[1])=1]">

                <xsl:sort select="substring-before(msg,':')"/>
                <hr/>
                <a>
                  <xsl:attribute name="name">
                    <xsl:call-template name="autoro">
                      <xsl:with-param name="spaco" select="'_'"/>
                    </xsl:call-template>
                  </xsl:attribute>
                </a>
                <h2>
                  <xsl:call-template name="autoro">
                    <xsl:with-param name="spaco" select="' '"/>
                  </xsl:call-template>
                </h2>
                <dl>
                  <xsl:apply-templates select="key('autoroj',substring-before(msg,':'))"/>
                </dl>
              
            </xsl:for-each>

          </td>
        </tr>
      </table>
    </body>
  </html>
</xsl:template>

<xsl:template name="autoro">
  <xsl:param name="spaco"/>
  <xsl:choose>
    <xsl:when test="substring-before(msg,':')">
      <xsl:value-of select="translate(substring-before(msg,':'),' ',$spaco)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>revo</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="menuo-ktp">
  <xsl:for-each select="document($enhavo)//pagho[.//BLD-OJ][1]"> 
    <xsl:call-template name="menuo"/>
  </xsl:for-each>
</xsl:template>

<xsl:template name="menuo">
  <xsl:variable name="aktiva" select="@dosiero"/>
  <tr>
    <xsl:for-each select="../pagho[not(@kashita='jes')]">
      <xsl:choose>
        <xsl:when test="@dosiero=$aktiva">
          <td class="aktiva">
            <a href="../inx/{@dosiero}">
              <xsl:value-of select="@titolo"/>
            </a>
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td class="fona">
            <a href="../inx/{@dosiero}">
              <xsl:value-of select="@titolo"/>
            </a>
          </td>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>     
  </tr>
</xsl:template>

<xsl:template match="entry">
  <dt>
    <a target="precipa">
     <xsl:attribute name="href">
       <xsl:text>../art/</xsl:text>
       <xsl:value-of select="substring-before(file/name,'.xml')"/>
       <xsl:text>.html</xsl:text>
     </xsl:attribute>
     <b><xsl:value-of select="substring-before(file/name,'.xml')"/></b>
    </a> 
    <xsl:text> </xsl:text>
    <span class="dato"><xsl:value-of select="date"/></span>
  </dt>
  <dd>
    <xsl:choose>
      <xsl:when test="substring-after(msg,':')">
        <xsl:value-of select="substring-after(msg,':')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="msg"/>
      </xsl:otherwise>
    </xsl:choose>
  </dd>
</xsl:template>

</xsl:stylesheet>



