<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->


<xsl:output method="xml" encoding="utf-8"/>

<xsl:key name="literoj" match="//kap-oj/v" use="substring(.,1,1)"/>

<xsl:variable name="ordigo">../cfg/ordigo.xml</xsl:variable>

<xsl:template match="/">
  <indekso>
    <xsl:apply-templates/>
  </indekso>
</xsl:template>

<!-- xsl:template match="trd-oj">
  <trd-oj lng="{@lng}">
    <xsl:for-each select="v">
       <xsl:sort lang="{@lng}" select="t"/>

       <v mrk="{@mrk}"> 
         <xsl:apply-templates/>
       </v><xsl:text>
</xsl:text>
    </xsl:for-each>
  </trd-oj><xsl:text>
</xsl:text>
</xsl:template -->



<xsl:template match="trd-oj">
   <xsl:variable name="chiuj_literoj"
     select="translate(normalize-space(document($ordigo)/ordigo/lingvo[@lng=current()/@lng]),
' ','')"/>

  <xsl:if test="string-length($chiuj_literoj)>0">
  <trd-oj lng="{@lng}">
<xsl:text>
</xsl:text>
    <xsl:variable name="trdoj" select="."/>

    <xsl:for-each 
      select="document($ordigo)/ordigo/lingvo[@lng=current()/@lng]/l">
      <xsl:variable name="n" select="substring(concat(@n,'1'),1,1)"/>
      <litero name="{@name}">
<xsl:text>
</xsl:text>
       <xsl:for-each select="$trdoj/v[contains(current(),substring(.,1,$n))]">
         <xsl:sort lang="{@lng}" select="t"/>

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
         <xsl:sort lang="{@lng}" select="t"/>

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

<!-- xsl:template match="kap-oj">
  <kap-oj lng="{@lng}">
    <xsl:for-each select="v">
       <xsl:sort lang="{@lng}" select="."/>

       <v mrk="{@mrk}" lit="{substring(.,1,1)}"> 
         <xsl:apply-templates/>
       </v><xsl:text>
</xsl:text>
    </xsl:for-each>
  </kap-oj><xsl:text>
</xsl:text>
</xsl:template -->

<!--xsl:template match="kap-oj">
  <kap-oj lng="{@lng}">
    <xsl:for-each select="//kap-oj/v
           [count(.|key('literoj',substring(.,1,1))[1])=1]">
     <litero lit="{substring(.,1,1)}">
      <xsl:for-each select="key('literoj',substring(.,1,1))">
         <xsl:sort lang="{@lng}" select="."/>

         <v mrk="{@mrk}"> 
           <xsl:apply-templates/>
         </v><xsl:text>
</xsl:text>
      </xsl:for-each>
     </litero>
    </xsl:for-each>

  </kap-oj><xsl:text>
</xsl:text>
</xsl:template-->



<xsl:template match="kap-oj">
   <xsl:variable name="chiuj_literoj"
     select="translate(normalize-space(document($ordigo)/ordigo/lingvo['eo']),
' ','')"/>
 
   <xsl:if test="string-length($chiuj_literoj)>0">
   <kap-oj lng="{@lng}">
    <xsl:variable name="kapoj" select="."/>
    <xsl:for-each 
      select="document($ordigo)/ordigo/lingvo[@lng='eo']/l">

      <litero name="{@name}">
<xsl:text>
</xsl:text>
      <xsl:for-each select="$kapoj/v[contains(current(),substring(.,1,1))]">

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
    </xsl:for-each>

   <!-- traktu chiujn erojn, kiuj ne komencighas per iu litero el la
   ordigoreguloj -->
  <litero name="?">
     <xsl:for-each select="$kapoj/v[not(contains($chiuj_literoj,substring(.,1,1)))]">
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
  </xsl:if>
</xsl:template>


<xsl:template match="k|t">
  <xsl:copy><xsl:apply-templates/></xsl:copy>
</xsl:template>


</xsl:stylesheet>



