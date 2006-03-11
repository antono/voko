<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->

<xsl:param name="verbose" select="false"/>

<xsl:output method="xml" encoding="utf-8"/>

<xsl:variable name="ordigo">../cfg/ordigo.xml</xsl:variable>

<xsl:template match="/">
  <indekso>
    <xsl:apply-templates/>
  </indekso>
</xsl:template>

<xsl:template match="trd-oj">
   <xsl:if test="$verbose='true'">
     <xsl:message>progreso: traktas lingvon "<xsl:value-of
      select="@lng"/>"...</xsl:message>
   </xsl:if>

   <!-- lau reguloj de kiu lingvo ordigi? -->
   <xsl:variable name="ordlng_1" 
     select="document($ordigo)/ordigo/lingvo[@lng=current()/@lng]/@kiel"/>

   <xsl:variable name="ordlng" select="($ordlng_1|@lng|'en')[1]"/>
   <xsl:variable name="chiuj_literoj"
     select="translate(normalize-space(document($ordigo)/ordigo/lingvo[@lng=$ordlng]),
' ','')"/>

  <xsl:if test="string-length($chiuj_literoj)>0">
  <trd-oj lng="{@lng}">
<xsl:text>
</xsl:text>
    <xsl:variable name="trdoj" select="."/>

    <xsl:for-each 
      select="document($ordigo)/ordigo/lingvo[@lng=$ordlng]/l">
      <xsl:variable name="n" select="substring(concat(@n,'1'),1,1)"/>

<!-- problemo estas ekz. en la hispana kaj kimra, kie ordighas "Ll" en
alian grupon ol "L", sed vortoj komencighantaj je "Ll" ne aperu ankau
sub "L" -->
      <xsl:variable name="minus" select="../l[@name=current()/@minus]"/>      
      <xsl:variable name="nminus"
      select="substring(concat(../l[@name=current()/@minus]/@n,'1'),1,1)"/>     

      <litero name="{@name}">
<xsl:text>
</xsl:text>

       <xsl:for-each
         select="$trdoj/v[contains(current(),substring(.,1,$n)) and not(contains($minus,substring(.,1,$nminus)))]">
         <xsl:sort lang="{$ordlng}" select="t"/>

         <v mrk="{@mrk}"> 
           <xsl:apply-templates/>
         </v>
<xsl:text>
</xsl:text>
      </xsl:for-each>
     </litero>
<xsl:text>
</xsl:text>
   </xsl:for-each>

   <!-- traktu chiujn erojn, kiuj ne komencighas per iu litero el la
   ordigoreguloj, (FIXME: problemo povus esti, ke ghi ne kaptas ekz. en
   la bretona vortojn kiel "cabdefg", char "c" jam aperas en la grupoj
   "ch" kaj "c'h") -->
   <litero name="?">
     <xsl:for-each select="$trdoj/v[not(contains($chiuj_literoj,substring(.,1,1)))]">
         <xsl:sort lang="{$ordlng}" select="t"/>

         <v mrk="{@mrk}"> 
           <xsl:apply-templates/>
         </v>
<xsl:text>
</xsl:text>
      </xsl:for-each>
   </litero>
<xsl:text>
</xsl:text>
  </trd-oj>
<xsl:text>
</xsl:text>
  </xsl:if>
</xsl:template>


<xsl:template match="kap-oj">
   <xsl:variable name="chiuj_literoj"
     select="translate(normalize-space(document($ordigo)/ordigo/lingvo['eo']),
' ','')"/>
 
   <xsl:variable name="kapoj" select="."/>
 
   <xsl:if test="string-length($chiuj_literoj)>0">
   <kap-oj lng="{@lng}">
    <xsl:for-each 
      select="document($ordigo)/ordigo/lingvo[@lng='eo']/l">

      <litero name="{@name}">
<xsl:text>
</xsl:text>
      <xsl:for-each select="$kapoj/v[contains(current(),substring(k,1,1))]">

         <xsl:sort lang="eo" select="k"/>

         <v mrk="{@mrk}"> 
           <xsl:apply-templates/>
         </v>
<xsl:text>
</xsl:text>
      </xsl:for-each>
     </litero>
<xsl:text>
</xsl:text>
    </xsl:for-each>

   <!-- traktu chiujn erojn, kiuj ne komencighas per iu litero el la
   ordigoreguloj -->
  <litero name="?">
     <xsl:for-each select="$kapoj/v[not(contains($chiuj_literoj,substring(k,1,1)))]">
         <xsl:sort lang="eo"/>

         <v mrk="{@mrk}"> 
           <xsl:apply-templates/>
         </v>
<xsl:text>
</xsl:text>
      </xsl:for-each>
   </litero>
<xsl:text>
</xsl:text>
  </kap-oj>
<xsl:text>
</xsl:text>

   <!-- inversa indekso -->

   <inv lng="{@lng}">

    <xsl:for-each 
      select="document($ordigo)/ordigo/lingvo[@lng='eo']/l">

      <litero name="{@name}">
<xsl:text>
</xsl:text>
      <xsl:for-each select="$kapoj/v[r and
         contains(current(),substring(r,1,1))]">

         <xsl:sort lang="eo" select="r"/> 

         <v mrk="{@mrk}"> 
           <xsl:apply-templates/>
         </v>
<xsl:text>
</xsl:text>
      </xsl:for-each>
     </litero>
<xsl:text>
</xsl:text>
    </xsl:for-each>
   
    </inv>

  </xsl:if>
</xsl:template>


<xsl:template match="fako">
   <xsl:if test="$verbose='true'">
     <xsl:message>progreso: traktas fakon "<xsl:value-of
        select="@fak"/>"...</xsl:message>
   </xsl:if>

   <fako fak="{@fak}">
<xsl:text>
</xsl:text>
      <xsl:for-each select="v">

         <xsl:sort lang="eo"/>

         <v mrk="{@mrk}"> 
           <xsl:apply-templates/>
         </v>
<xsl:text>
</xsl:text>
      </xsl:for-each>
  </fako>
<xsl:text>
</xsl:text>

</xsl:template>


<xsl:template match="k|t|r">
  <xsl:copy><xsl:apply-templates/></xsl:copy>
</xsl:template>



</xsl:stylesheet>



