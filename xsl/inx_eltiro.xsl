<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->


<xsl:output method="xml" encoding="utf-8"/>
<xsl:strip-space elements="kap"/>

<xsl:template match="/">
  <xsl:apply-templates/>
</xsl:template>

<!-- <xsl:template match="art|drv|snc|kap|rad|tld|@mrk">
  <xsl:copy> <xsl:apply-templates/> </xsl:copy>
</xsl:template> -->

<xsl:template match="art">
  <art mrk="{substring-after(substring-before(@mrk,'.xml'),'Id: ')}">
  <xsl:apply-templates select="kap|subart|drv|snc|trdgrp|trd|uzo|bld"/>
  </art>
</xsl:template>

<xsl:template match="subart|drv|subdrv|snc|subsnc">
  <xsl:copy>
  <xsl:apply-templates select="@mrk|kap|drv|subdrv|snc|subsnc|trdgrp|trd|uzo|bld|mlg"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="trdgrp">
  <xsl:variable name="lng" select="@lng"/>
  <xsl:for-each select="trd">
    <trd lng="{$lng}">
      <xsl:apply-templates/>
    </trd>
  </xsl:for-each>
</xsl:template>

<xsl:template match="trd[@lng]">
  <xsl:copy>
  <xsl:apply-templates select="@lng|text()|*"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="kap|rad|tld|@mrk|@lng|uzo[@tip='fak']|bld|mlg">
  <xsl:copy><xsl:apply-templates/></xsl:copy>
</xsl:template>

<xsl:template match="kap/ofc|kap/fnt"/>

</xsl:stylesheet>










