<!DOCTYPE xsl:transform>

<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  version="2.0"
  extension-element-prefixes="saxon" 
>

<!-- xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
  xmlns:redirect="http://xml.apache.org/xalan/redirect"
    extension-element-prefixes="redirect" -->


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->


<xsl:output method="xhtml" encoding="utf-8"/>
<xsl:strip-space elements="k"/>

<xsl:param name="verbose" select="'true'"/>

<xsl:variable name="fakoj">../cfg/fakoj.xml</xsl:variable>
<xsl:variable name="enhavo">../cfg/enhavo.xml</xsl:variable>
  <xsl:variable name="inx_paghoj" select="count(document($enhavo)//pagho[not(@kashita='jes')])"/>

<xsl:template match="//tez">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="n">
  <xsl:variable name="dosiero" select="concat('tz_',translate(@mrk,'.','_'),'.html')"/>

  <xsl:if test="$verbose='true'">
    <xsl:message>skribas al <xsl:value-of select="$dosiero"/></xsl:message>
  </xsl:if>

  <!-- redirect:write select="$dosiero" -->
  <xsl:result-document href="{$dosiero}" method="xhtml" encoding="utf-8" indent="no">
  <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
      <title><xsl:value-of select="concat('teza&#x016d;ro: ',k)"/></title>
      <link title="indekso-stilo" type="text/css" 
            rel="stylesheet" href="../stl/indeksoj.css"/>
    </head>
    <body>
      <table cellspacing="0">
        <xsl:call-template name="menuo-eo"/>
        <tr>
          <td colspan="{$inx_paghoj}" class="enhavo">
            <h1><xsl:call-template name="art-ref"/></h1>
            <xsl:apply-templates select="*[not(self::k)]"/>
          </td>
        </tr>
      </table>
    </body>
  </html>
  <!-- /redirect:write -->
  </xsl:result-document>
</xsl:template>


<xsl:template name="art-ref">
  <xsl:choose>
    <xsl:when test="contains(@mrk,'.')">
      <a href="../art/{substring-before(@mrk,'.')}.html#{@mrk}" 
        target="precipa">
        <xsl:apply-templates select="k"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <a href="../art/{@mrk}.html" target="precipa">
        <xsl:apply-templates select="k"/>
      </a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="art-ref2">
  <xsl:choose>
    <xsl:when test="contains(@c,'.')">
      <a href="../art/{substring-before(@c,'.')}.html#{@c}" 
        target="precipa">
        <xsl:apply-templates select="//tez/n[@mrk=current()/@c]/k"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <a href="../art/{@c}.html" target="precipa">
        <xsl:apply-templates select="//tez/n[@mrk=current()/@c]/k"/>
      </a>
    </xsl:otherwise>
  </xsl:choose>
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


<xsl:template name="menuo-eo">
  <xsl:for-each select="document($enhavo)//pagho[.//KAP-OJ][1]"> 
    <xsl:call-template name="menuo"/>
  </xsl:for-each>
</xsl:template>


<xsl:template name="menuo-fak">
  <xsl:for-each select="document($enhavo)//pagho[.//FAKOJ][1]"> 
    <xsl:call-template name="menuo"/>
  </xsl:for-each>
</xsl:template>


<xsl:template match="sin">
  <xsl:if test="r">
    <i class="griza">sinonimoj</i><br/>
    <xsl:call-template name="refs">
       <xsl:with-param name="smb" select="'sin.gif'"/>
       <xsl:with-param name="alt" select="'&#x21d2;'"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template match="super">
  <xsl:if test="r">
    <i class="griza">speco de</i><br/>
    <xsl:call-template name="refs">
       <xsl:with-param name="smb" select="'super.gif'"/>
       <xsl:with-param name="alt" select="'&#x2197;'"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template match="sub">
  <xsl:if test="r">
    <i class="griza">specoj</i><br/>
    <xsl:call-template name="refs">
       <xsl:with-param name="smb" select="'sub.gif'"/>
       <xsl:with-param name="alt" select="'&#x2199;'"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template match="vid">
  <xsl:if test="r">
    <i class="griza">vidu</i><br/>
    <xsl:call-template name="refs">
       <xsl:with-param name="smb" select="'vid.gif'"/>
       <xsl:with-param name="alt" select="'&#x2192;'"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template name="refs">
  <xsl:param name="smb"/>
  <xsl:param name="alt"/>
  <xsl:for-each select="r">
    <a href="{concat('tz_',translate(@c,'.','_'),'.html')}">
      <img src="{concat('../smb/',$smb)}" alt="{$alt}" border="0"/>
    </a>
    <xsl:call-template name="art-ref2"/>
    <br/>
  </xsl:for-each>
</xsl:template>


<!-- /xsl:stylesheet -->
</xsl:transform>









