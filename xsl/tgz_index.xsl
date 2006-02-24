<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="1.0">

<!-- (c) 2006 che Wolfram Diestel 

-->

<xsl:variable name="dosieroj">dosieroj.xml</xsl:variable>


<!-- kopii chion ... -->

<xsl:template match="*|@*">
  <xsl:copy> <xsl:apply-templates/> </xsl:copy>
</xsl:template>


<!-- ... krom la sekvajn -->
<xsl:template match="if">
  <xsl:if
  test="document($dosieroj)/dir/file[starts-with(@name,current()/@test)]">  
    <xsl:apply-templates/>
  </xsl:if>
</xsl:template>

<xsl:template match="revoxml|revobld|revohtml|revodict|voko|reveto">
  <xsl:apply-templates select="document($dosieroj)/dir/file[starts-with(@name,local-name(current()))]"/>  
</xsl:template>

<xsl:template match="revonov">
  <xsl:for-each
  select="document($dosieroj)/dir/file[starts-with(@name,local-name(current()))]">  
    <xsl:apply-templates/><br/>  
  </xsl:for-each>
</xsl:template>

<xsl:template match="file">
  <a href="{@name}"><xsl:value-of select="@name"/></a> 
  (<xsl:value-of select="@size"/>)
</xsl:template>

</xsl:stylesheet>














