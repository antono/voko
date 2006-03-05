<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->


<xsl:output method="xml" encoding="utf-8"/>
<xsl:strip-space elements="kap"/>

<xsl:template match="/">
  <indekso>
    <kap-oj lng="eo">
      <xsl:apply-templates select="//kap"/>
    </kap-oj>
  </indekso>
</xsl:template>

<xsl:template match="kap">
  <v>
    <xsl:attribute name="mrk">
      <xsl:value-of select="ancestor::node()[@mrk][1]/@mrk"/>
    </xsl:attribute>
    <xsl:apply-templates/>
  </v>
</xsl:template>

<xsl:template match="drv/kap">
  <!-- ellasu la derivajhon kun sama kapvorto kiel la artikolo -->
      <xsl:variable name="art-kap"><xsl:for-each
        select="ancestor::node()[self::art]/kap"
        ><xsl:call-template name="kap-komparo"
        /></xsl:for-each></xsl:variable>
      <xsl:variable name="drv-kap"><xsl:call-template name="kap-komparo"
        /></xsl:variable>
      <xsl:if test="$art-kap != $drv-kap">
        <v>
          <xsl:attribute name="mrk">
            <xsl:value-of select="ancestor::node()[@mrk][1]/@mrk"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </v>
      </xsl:if>
</xsl:template>

<xsl:template name="kap-komparo">
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

<xsl:template match="kap/text()">
  <xsl:value-of select="translate(normalize-space(.),'/','')"/>
</xsl:template>

<!-- xsl:template match="ofc|fnt"/ -->

</xsl:stylesheet>




