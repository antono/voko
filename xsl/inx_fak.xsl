<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->


<xsl:output method="xml" encoding="utf-8"/>
<xsl:strip-space elements="uzo"/>

<xsl:variable name="fakcfg">../cfg/fakoj.xml</xsl:variable>
<xsl:key name="fakoj" match="//uzo" use="."/>

<xsl:template match="/">
  <indekso>

  <xsl:variable name="root" select="."/>

  <xsl:for-each select="document($fakcfg)/fakoj/fako">
   <xsl:variable name="fak" select="@kodo"/>
   <xsl:message>progreso: traktas fakon <xsl:value-of select="$fak"/>...</xsl:message>
   <xsl:for-each select="$root">
    <fako fak="{$fak}">
      <xsl:apply-templates select="key('fakoj',$fak)"/>
    </fako>
   </xsl:for-each>
  </xsl:for-each>
  </indekso>
</xsl:template>


<xsl:template match="uzo">
  <v>
    <xsl:attribute name="mrk">
      <xsl:value-of select="ancestor::node()[@mrk][1]/@mrk"/>
    </xsl:attribute>

     <xsl:apply-templates
  select="(ancestor::art|ancestor::drv)[last()]/kap"/>

  </v>
</xsl:template>

<xsl:template match="kap">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tld">
  <xsl:choose>

    <xsl:when test="@lit">
      <xsl:value-of select="concat(@lit,substring(ancestor::art/kap/rad,2))"/>
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select="ancestor::art/kap/rad"/>
    </xsl:otherwise>

  </xsl:choose>
</xsl:template>

</xsl:stylesheet>







