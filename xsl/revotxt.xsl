<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xt="http://www.jclark.com/xt"
		version="1.0"
                extension-element-prefixes="xt">

<!-- XSL-difino produktanta simplan HTMLon, kiun per "lynx -dump"
    oni povas plutransformi al simpla teksto -->

<xsl:strip-space elements="kap trd trdgrp"/>

<!-- kruda artikolstrukturo -->

<xsl:template match="/">
  <html>
  <head>
  <title>
  <xsl:apply-templates select="//art/kap" mode="kapvorto"/>
  </title>
  </head>
  <xsl:apply-templates/>
  </html>
</xsl:template>

<xsl:template match="art/kap" mode="kapvorto">
  <xsl:apply-templates select="rad|text()"/>
</xsl:template>

<!-- art, subart -->

<xsl:template match="art">
  <xsl:choose>
    <xsl:when test="subart|snc">
      <xsl:apply-templates select="kap"/>
      <dl>
      <xsl:apply-templates select="*[not(self::kap)]"/>
      </dl>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="//trd">
    <hr />
    <h2>tradukoj</h2>
    <xsl:apply-templates select="//art" mode="tradukoj"/>
  </xsl:if>
  <xsl:if test="//fnt[aut|vrk|lok]">
    <hr />
    <h2>fontoj</h2>
    <xsl:apply-templates select="//fnt[aut|vrk|lok]" mode="fontoj"/>
  </xsl:if>
  <hr />
  <xsl:call-template name="redakto"/>
</xsl:template>

<xsl:template match="art/kap">
  <h1><xsl:apply-templates/></h1>
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

<xsl:template match="ekz/tld">
  <xsl:value-of select="@lit"/>
  <xsl:text>~</xsl:text>
</xsl:template>

<xsl:template match="subart">
  <dt><xsl:number format="I."/></dt>
  <dd>
  <xsl:choose>
    <xsl:when test="snc">
      <xsl:apply-templates select="kap"/>
      <dl>
      <xsl:apply-templates select="*[not(self::kap)]"/>
      </dl>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
  </dd>
</xsl:template> 

<!-- derivajhoj -->

<xsl:template match="drv">
  <xsl:apply-templates
    select="*[not(self::subdrv|self::snc|self::trd|self::trdgrp|self::url)]"/>
  <dl>
  <xsl:apply-templates select="subdrv|snc"/>
  </dl>
  <xsl:apply-templates select="trd|trdgrp|url"/>
</xsl:template>  
	
<xsl:template match="subdrv">
  <dt><xsl:number format="A"/></dt>
  <dd>
  <xsl:apply-templates/>
  </dd>
</xsl:template>

<xsl:template match="drv/kap">
  <h2><xsl:apply-templates/></h2>  
</xsl:template>

<!-- sencoj -->

<xsl:template match="snc">
  <dt><xsl:value-of select="@num"/>
    <xsl:if test="@num">.</xsl:if></dt>
  <dd>
  <xsl:choose>
    <xsl:when test="subsnc">
      <xsl:apply-templates 
        select="*[not(self::subsnc|self::trd|self::trdgrp|url)]"/>   
      <dl>
      <xsl:apply-templates select="subsnc"/>
      </dl>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates />
    </xsl:otherwise>
  </xsl:choose>
  <xsl:apply-templates select="trd|trdgrp|url"/>
  </dd>
</xsl:template>  

<xsl:template match="subsnc">
  <dt><xsl:number format="a"/></dt>
  <dd>
  <xsl:apply-templates/>
  </dd>
</xsl:template>

<!-- priskribaj elementoj -->

<xsl:template match="gra">
  (<xsl:apply-templates/>)<br />
</xsl:template>

<xsl:template match="dif">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="ekz">
  <cite><xsl:apply-templates/></cite>
</xsl:template>

<xsl:template match="rim/ekz">
  <cite><xsl:apply-templates/></cite>
</xsl:template>

<xsl:template match="rim">
  <xsl:text>RIM.</xsl:text>
  <xsl:if test="@num"> 
    <xsl:text> </xsl:text>
    <xsl:value-of select="@num"/>
  </xsl:if>
  <xsl:text>:</xsl:text>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="refgrp">
  <xsl:text>=&gt; </xsl:text>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="ref">
  <xsl:if test="@tip">
    <xsl:text>=&gt; </xsl:text>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="dif/refgrp|dif/ref">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="sup|ofc">
  <sup><xsl:value-of select="."/></sup>
</xsl:template>

<xsl:template match="fnt">
  <sup> (<xsl:value-of select="."/>)</sup>
</xsl:template>

<xsl:template match="fnt[aut|vrk|lok]">
  [<xsl:number level="any" count="fnt[aut|vrk|lok]"/>]
</xsl:template>

<xsl:template match="klr">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="uzo">
  <xsl:apply-templates/>
  <xsl:if test="drv/uzo">
    <br />
  </xsl:if>
</xsl:template>

<xsl:template match="url">
  <xsl:apply-templates/>
  (<xsl:value-of select="@ref"/>)
</xsl:template>

<xsl:template match="sub">
  <sub><xsl:apply-templates/></sub>
</xsl:template>

<xsl:template match="em">
  <strong>_<xsl:apply-templates/>_</strong>
</xsl:template>

<xsl:template match="trdgrp|trd">
</xsl:template>

<xsl:template match="dif/trd">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="bld"/>

<!-- teksto -->

<xsl:template match="text()">
  <xsl:value-of select="."/>
</xsl:template>

<!-- tradukoj -->

<xsl:template name="lingvo">
  <xsl:param name="lng"/>
  <xsl:param name="lingvo"/>
  <xsl:if test="//trd[@lng=$lng]|//trdgrp[@lng=$lng]">
    <h3>
      <xsl:value-of select="$lingvo"/>
    </h3>
    <xsl:apply-templates mode="tradukoj"
      select="//trd[@lng=$lng]|//trdgrp[@lng=$lng]"/>
  </xsl:if>
</xsl:template>  

<xsl:template match="art" mode="tradukoj">
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">bg</xsl:with-param>
    <xsl:with-param name="lingvo">bulgare</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">cs</xsl:with-param>
    <xsl:with-param name="lingvo">&#x0109;e&#x0125;e</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">de</xsl:with-param>
    <xsl:with-param name="lingvo">germane</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">en</xsl:with-param>
    <xsl:with-param name="lingvo">angle</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">es</xsl:with-param>
    <xsl:with-param name="lingvo">hispane</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">fr</xsl:with-param>
    <xsl:with-param name="lingvo">france</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">hu</xsl:with-param>
    <xsl:with-param name="lingvo">hungare</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">it</xsl:with-param>
    <xsl:with-param name="lingvo">itale</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">la</xsl:with-param>
    <xsl:with-param name="lingvo">latine</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">nl</xsl:with-param>
    <xsl:with-param name="lingvo">nederlande</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">pl</xsl:with-param>
    <xsl:with-param name="lingvo">pole</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">ru</xsl:with-param>
    <xsl:with-param name="lingvo">ruse</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">tr</xsl:with-param>
    <xsl:with-param name="lingvo">turke</xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="trd[@lng]|trdgrp" mode="tradukoj">
  <strong>
  <xsl:apply-templates 
    select="ancestor::node()[self::drv or self::snc or self::subsnc or
      self::subdrv or self::subart or self::art][1]" mode="tradukoj"/>:
  </strong>
  <xsl:text> </xsl:text>
  <xsl:apply-templates mode="tradukoj"/>
  <xsl:choose>
    <xsl:when test="not(position()=last())">
      <xsl:text>; </xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>. </xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="drv" mode="tradukoj">
  <xsl:apply-templates select="kap" mode="tradukoj"/>
</xsl:template>

<xsl:template match="snc" mode="tradukoj">
  <xsl:apply-templates select="ancestor::node()[self::drv or
    self::art][1]/kap" mode="tradukoj"/>
  <xsl:if test="@num">
    <xsl:text> </xsl:text>
    <xsl:value-of select="@num"/>
  </xsl:if>
</xsl:template>

<xsl:template match="subart" mode="tradukoj">
  <xsl:apply-templates select="ancestor::art/kap" mode="tradukoj"/>
  <xsl:text> </xsl:text>
  <xsl:number format="I"/>
</xsl:template>

<xsl:template match="kap" mode="tradukoj">
  <xsl:apply-templates select="tld|rad|text()" mode="tradukoj"/>
</xsl:template>

<xsl:template match="trdgrp/trd" mode="tradukoj">
  <xsl:apply-templates mode="tradukoj"/>
</xsl:template>

<xsl:template match="tld" mode="tradukoj">
  <xsl:value-of select="@lit"/>
  <xsl:text>~</xsl:text>
</xsl:template> 


<!-- fontoj -->

<xsl:template match="fnt" mode="fontoj">
  <xsl:number level="any" count="fnt[aut|vrk|lok]"/>.

  <xsl:variable name="fnt" select="normalize-space(.)"/>
  <xsl:choose>
    <xsl:when test="starts-with($fnt,'(')">
      <xsl:value-of 
        select="substring($fnt,2,string-length($fnt)-2)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$fnt"/>
    </xsl:otherwise>
  </xsl:choose>
  <br />
</xsl:template>

<!-- redakto -->

<xsl:template name="redakto">
  versio: <xsl:value-of 
    select="substring-before(substring-after(@mrk,',v'),'revo')"/>
  <br />
</xsl:template>

</xsl:stylesheet>











