<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->


<xsl:output method="xml" encoding="utf-8"/>

<xsl:key name="literoj" match="//kap-oj/v" use="substring(.,1,1)"/>


<xsl:template match="/">
  <indekso>
    <xsl:apply-templates/>
  </indekso>
</xsl:template>

<xsl:template match="trd-oj">
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

<xsl:template match="kap-oj">
  <kap-oj lng="{@lng}">
    <xsl:for-each select="//kap-oj/v
           [count(.|key('literoj',substring(.,1,1))[1])=1]">
     <!-- :<xsl:value-of select="@mrk"/>: -->
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
</xsl:template>


<xsl:template match="k|t">
  <xsl:copy><xsl:apply-templates/></xsl:copy>
</xsl:template>


</xsl:stylesheet>