<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<xsl:output method="text" encoding="utf-8"/>

<xsl:template match="/">
  <xsl:text>&lt;?xml version="1.0" encoding="UTF-8"?&gt;</xsl:text>
  <xsl:apply-templates select="ordigo/lingvo[@kreu-regulojn='jes']"/>
</xsl:template>

<xsl:template match="lingvo">
  <xsl:text>
&lt;!ENTITY sort-</xsl:text><xsl:value-of select="@lng"/>
<xsl:text> "</xsl:text>
<xsl:apply-templates select="l"/>
<xsl:apply-templates select="r"/>
<xsl:text>"&gt;</xsl:text>
</xsl:template>

<xsl:template match="l">
  <xsl:text> &amp;lt; </xsl:text>
  <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="r">
  <xsl:text> &amp;amp; </xsl:text>
  <xsl:value-of select="."/>
</xsl:template>

</xsl:stylesheet>