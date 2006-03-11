<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->

<xsl:param name="verbose" select="false"/>

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
   
      <xsl:if test="$verbose='true'">
        <xsl:message>progreso: traktas fakon <xsl:value-of select="$fak"/>...</xsl:message>
      </xsl:if>
   
      <xsl:for-each select="$root">
        <fako fak="{$fak}">
          <xsl:apply-templates select="key('fakoj',$fak)"/>
        </fako>
      </xsl:for-each>
    </xsl:for-each>

    <!-- tradukoj -->

    <xsl:for-each select="document($lngcfg)/lingvoj/lingvo">
      <xsl:variable name="lng" select="@kodo"/>
  
      <xsl:if test="$verbose='true'">
        <xsl:message>progreso: traktas tradukojn <xsl:value-of select="."/>jn...</xsl:message>
      </xsl:if>

      <xsl:for-each select="$root">
        <trd-oj lng="{$lng}">
          <xsl:apply-templates select="key('lingvoj',$lng)"/>
        </trd-oj>
      </xsl:for-each>
    </xsl:for-each>

    <!-- bildoj -->

    <bld-oj>
      <xsl:apply-templates select="//bld"/>
    </bld-oj>

    <!-- mallongigoj -->

    <mlg-oj>
      <xsl:apply-templates select="//mlg"/>
    </mlg-oj>

  </indekso>
</xsl:template>

<xsl:template match="kap" mode="kapvortoj">
  <v>
    <xsl:attribute name="mrk">
      <xsl:value-of select="ancestor::node()[@mrk][1]/@mrk"/>
    </xsl:attribute>
    <r>
      <xsl:call-template name="reverse">
        <xsl:with-param name="string" select="rad"/>
      </xsl:call-template>
    </r>
    <k>
      <xsl:apply-templates/>
    </k>
  </v>
</xsl:template>

<xsl:template name="reverse"> 
   <xsl:param name="string"/> 
   <xsl:choose> 
     <xsl:when test="string-length($string) = 0 or string-length($string) = 
 1"> 
       <xsl:value-of select="$string"/> 
     </xsl:when> 
     <xsl:otherwise> 
       <xsl:value-of select="substring($string,string-length($string), 1)"/> 
       <xsl:call-template name="reverse"> 
         <xsl:with-param name="string" select="substring($string, 1, 
           string-length($string) - 1)"/> 
       </xsl:call-template> 
    </xsl:otherwise> 
  </xsl:choose> 
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
          <k>
            <xsl:apply-templates/>
          </k>
        </v>
      </xsl:if>
</xsl:template>

<xsl:template name="kap-komparo">
   <xsl:variable name="kap"><xsl:apply-templates/></xsl:variable>
   <xsl:value-of select="translate($kap,'/','')"/>
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
  <xsl:value-of select="normalize-space(.)"/>
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

<xsl:template match="trd|mlg|bld">
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











