<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="1.0">

<!-- (c) 199-2003 che Wolfram Diestel

reguloj por prezentado de la administraj notoj 

-->

<!-- vokata por prezenti la administrajn notojn fine de la artikolo -->

<xsl:template name="admin">
  <xsl:if test="//adm">
    <hr />
    <h2>administraj notoj</h2>
    <xsl:apply-templates select="//adm" mode="admin"/>
  </xsl:if>
  <hr />
  <xsl:call-template name="redakto"/>
</xsl:template>

<!-- ne montru administrajn notojn rekte en la teksto -->

<xsl:template match="adm"/>

<!-- administraj notoj -->

<xsl:template match="adm" mode="admin">

  <!-- eltrovu la kapvorton de la administra noto -->
  <b>pri 
  <a href="#{ancestor::node()[@mrk][1]/@mrk}">
    <xsl:apply-templates 
      select="ancestor::node()[
        self::drv or 
        self::snc or 
        self::subsnc or
        self::subdrv or 
        self::subart or 
        self::art][1]"
      mode="kapvorto"/>
  </a>
  <xsl:text>: </xsl:text>
  </b>

  <!-- la administra noto mem -->
  <pre>
    <xsl:apply-templates mode="admin"/>
  </pre>
</xsl:template>


<!-- la autoro de la redakta noto -->

<xsl:template match="aut" mode="admin">
  <xsl:text>[</xsl:text>
    <xsl:apply-templates/>
  <xsl:text>]</xsl:text>
</xsl:template>

<!-- redakto-ligo fine de la pagxo  -->

<xsl:template name="redakto">
  <span class="redakto">

    <xsl:if test="$aspekto='ilustrite'">
      <xsl:variable name="xml"
        select="substring-before(substring-after(@mrk,'$Id: '),',v')"/>

        [<a class="redakto" 
            href="{$xmldir}/{$xml}"><xsl:value-of select="$xml"/></a>]
        [<a class="redakto" 
            href="{$redcgi}{substring-before($xml,'.xml')}">redakti...</a>]
    </xsl:if>

    versio: <xsl:value-of 
      select="substring-before(substring-after(@mrk,',v'),'revo')"/>
  </span>
  <br />
</xsl:template>

</xsl:stylesheet>











