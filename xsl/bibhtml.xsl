<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xt="http://www.jclark.com/xt"
		version="1.0"
                extension-element-prefixes="xt">

<!-- xsl:output method="html" version="3.2"/ -->
<xsl:strip-space elements="trdgrp"/>

<!--

kreita de Wolfram Diestel

-->

<xsl:variable name="cssdir">../stl</xsl:variable> 

<xsl:template match="/">
  <html>
  <head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <link title="artikolo-stilo" type="text/css" rel="stylesheet"
  href="{$cssdir}/indeksoj.css" />
  <title>Revo - bibliografio</title>
  </head>
  <body>
      <script src="../smb/butonoj.js"></script>
      <a href="../inx/_eo.html" onMouseOver="highlight(0)" 
         onMouseOut="normalize(0)"><img src="../smb/nav_eo1.png" 
         alt="[Esperanto]" border="0" /></a>
      <xsl:text> </xsl:text>
      <a href="../inx/_lng.html" onMouseOver="highlight(1)" 
         onMouseOut="normalize(1)"><img src="../smb/nav_lng1.png" 
         alt="[Lingvoj]" border="0" /></a>
      <xsl:text> </xsl:text>
      <a href="../inx/_fak.html" onMouseOver="highlight(2)" 
         onMouseOut="normalize(2)"><img src="../smb/nav_fak1.png" 
         alt="[Fakoj]" border="0" /></a>
      <xsl:text> </xsl:text>
      <a href="../inx/_ktp.html" onMouseOver="highlight(3)" 
         onMouseOut="normalize(3)"><img src="../smb/nav_ktp1.png" 
         alt="[ktp.]" border="0" /></a>
      <br />
    <h1>bibliografio</h1>
  
    <xsl:apply-templates/>
  
  </body>
  </html>
</xsl:template>

<!-- art, subart -->

<xsl:template match="bibliografio">
  <dl>
  <!-- ordigu lau mll, alia ebleco estus lau autoro, titolo...  -->
  <xsl:apply-templates select="vrk">
    <xsl:sort select="@mll"/>
  </xsl:apply-templates>
  </dl>
</xsl:template>

<xsl:template match="vrk">
  <dt><a name="{@mll}"></a>
    <xsl:choose>
      <xsl:when test="url">
        <a href="{url}" target="_new">
        <b><xsl:value-of select="@mll"/></b>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <b><xsl:value-of select="@mll"/></b>
      </xsl:otherwise>
    </xsl:choose>
  </dt>
  <dd>
    <xsl:apply-templates/>
  </dd>
</xsl:template>

<xsl:template match="url"/>


<xsl:template match="aut">
  <xsl:apply-templates/>
  <xsl:choose>
    <xsl:when test="following-sibling::*[1][self::aut]">
      <xsl:text>; </xsl:text>
    </xsl:when>
    <xsl:when test="following-sibling::*[1][self::trd]">
      <xsl:text>, </xsl:text><br/>
    </xsl:when>
    <xsl:when test="following-sibling::*[1][self::tit]">
      <xsl:text>: </xsl:text><br/>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="trd">
  <xsl:text>trad. </xsl:text>
  <xsl:apply-templates/>
  <xsl:if test="following-sibling::*[1][self::tit]">
      <xsl:text>: </xsl:text><br/>
  </xsl:if>
</xsl:template>

<xsl:template match="tit">
  <b><xsl:apply-templates/></b>
  <xsl:if test="following-sibling::*[1][self::eld|self::isbn]">
      <xsl:text>, </xsl:text><br/>
  </xsl:if>
</xsl:template>

<xsl:template match="isbn">
  <xsl:text>ISBN: </xsl:text>
  <xsl:apply-templates/>
  <xsl:if test="following-sibling::*[1][self::eld|self::ald]">
      <xsl:text>, </xsl:text><br/>
  </xsl:if>
</xsl:template>

<xsl:template match="ald">
  (<xsl:apply-templates/>)
  <xsl:if test="following-sibling::*">
      <xsl:text>, </xsl:text><br/>
  </xsl:if>
</xsl:template>

<xsl:template match="eld">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="nom">
  <xsl:apply-templates/>
  <xsl:if test="following-sibling::*">
      <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>  

<xsl:template match="lok">
  <xsl:apply-templates/>
  <xsl:if test="following-sibling::*">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="dat">
  <xsl:apply-templates/>
</xsl:template>


</xsl:stylesheet>











