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
  <xsl:apply-templates select="kap|drv|snc"/>
  </art>
</xsl:template>

<xsl:template match="drv">
  <xsl:copy>
  <xsl:apply-templates select="@mrk|kap|snc"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="snc">
  <xsl:copy>
  <xsl:apply-templates select="@mrk|kap"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="kap|rad|tld|@mrk">
  <xsl:copy> <xsl:apply-templates/> </xsl:copy>
</xsl:template>


</xsl:stylesheet>




