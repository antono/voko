<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->


<xsl:output method="xml" encoding="utf-8"/>
<xsl:strip-space elements="kap uzo trd"/>

<xsl:variable name="fakcfg">../cfg/fakoj.xml</xsl:variable>
<xsl:variable name="lngcfg">../cfg/lingvoj.xml</xsl:variable>

<xsl:key name="fakoj" match="//uzo" use="."/>
<xsl:key name="lingvoj" match="//trd[@lng]" use="@lng"/>

<xsl:template match="/">
  <indekso>

    <!-- kapvortoj -->

    <kap-oj lng="eo">
      <xsl:apply-templates select="//kap" mode="kapvortoj"/>
    </kap-oj>

    <xsl:variable name="root" select="."/>

    <!-- fakoj -->

    <xsl:for-each select="document($fakcfg)/fakoj/fako">
      <xsl:variable name="fak" select="@kodo"/>
      <xsl:message>progreso: traktas fakon <xsl:value-of select="$fak"/>...</xsl:message>
   
      <xsl:for-each select="$root">
        <fako fak="{$fak}">
          <xsl:apply-templates select="key('fakoj',$fak)"/>
        </fako>
      </xsl:for-each>
    </xsl:for-each>

    <!-- tradukoj -->

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

<xsl:template match="kap" mode="kapvortoj">
  <v>
    <xsl:attribute name="mrk">
      <xsl:value-of select="ancestor::node()[@mrk][1]/@mrk"/>
    </xsl:attribute>
    <xsl:apply-templates/>
  </v>
</xsl:template>

<xsl:template match="drv/kap" mode="kapvortoj">
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

<xsl:template match="kap/text()" mode="kapvortoj">
  <xsl:value-of select="translate(normalize-space(.),'/','')"/>
</xsl:template>

<!-- xsl:template match="ofc|fnt"/ -->

<xsl:template match="kap">
    <xsl:apply-templates/>
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


</xsl:stylesheet>











