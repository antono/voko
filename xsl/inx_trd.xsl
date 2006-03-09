<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->


<xsl:output method="xml" encoding="utf-8"/>
<xsl:strip-space elements="trd"/>

<xsl:variable name="lngcfg">../cfg/lingvoj.xml</xsl:variable>
<xsl:key name="lingvoj" match="//trd[@lng]" use="@lng"/>

<!-- xsl:template match="/">
  <indekso>

  <xsl:variable name="dummy" select="."/>

  <xsl:for-each select="document($lngcfg)/lingvoj/lingvo">
   <xsl:variable name="lng" select="@kodo"/>


    <trd-oj lng="{$lng}">
      <xsl:apply-templates
       select="$dummy//trd[@lng=$lng]"/>
    </trd-oj>

  </xsl:for-each>
  </indekso>
</xsl:template -->

<!-- xsl:template match="/">
  <indekso>

  <!- por chiu lingvo elektu reprezentanton ->
  <xsl:for-each select="(//trd[@lng])
           [count(.|key('lingvoj',@lng)[1])=1]">
    <trd-oj lng="{@lng}">
      <xsl:apply-templates
       select="key('lingvoj',@lng)"/>
    </trd-oj>
  </xsl:for-each>
  </indekso>
</xsl:template -->

<!-- tiu varianto bezonas nur dekonon da tempo ol la aliaj du -->
<xsl:template match="/">
  <indekso>

  <xsl:variable name="root" select="."/>

  <xsl:for-each select="document($lngcfg)/lingvoj/lingvo">
   <xsl:variable name="lng" select="@kodo"/>
   <xsl:message>progreso: traktas tradukojn <xsl:value-of select="."/>jn...</xsl:message>
   <xsl:for-each select="$root">
    <trd-oj lng="{$lng}">
      <xsl:apply-templates select="key('lingvoj',$lng)"/>
    </trd-oj>
   </xsl:for-each>
  </xsl:for-each>
  </indekso>
</xsl:template>


<xsl:template match="trd">
  <v>
    <xsl:attribute name="mrk">
      <xsl:value-of select="ancestor::node()[@mrk][1]/@mrk"/>
    </xsl:attribute>
    <t>
      <xsl:apply-templates/>
    </t>
    <k>
     <xsl:apply-templates
  select="(ancestor::art|ancestor::drv)[last()]/kap"/>
    </k>
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







