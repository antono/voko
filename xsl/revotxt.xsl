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

<xsl:template match="ekz//tld">
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
  <xsl:apply-templates select="kap|gra|uzo|fnt|dif"/>
  <dl compact="">
  <xsl:apply-templates select="subdrv|snc"/>
  </dl>
  <xsl:apply-templates
    select="*[not(self::subdrv|self::snc|self::gra|self::uzo|self::fnt|self::kap|self::dif|self::mlg)]"/>
</xsl:template>  
	
<xsl:template match="subdrv">
  <dt><xsl:number format="A"/></dt>
  <dd>
  <xsl:apply-templates/>
  </dd>
</xsl:template>

<xsl:template match="drv/kap">
  <h2><xsl:apply-templates/><xsl:apply-templates select="../mlg"/></h2>  
</xsl:template>

<!-- sencoj -->

<xsl:template match="snc" mode="number-of-ref-snc">
  <xsl:number from="drv|subart" level="any" count="snc"/>
</xsl:template>

<xsl:template match="sncref">
  <i><xsl:apply-templates mode="number-of-ref-snc" select="id(@ref)"/></i>
</xsl:template>

<xsl:template match="snc">
  <dt>
    <xsl:choose>
      <xsl:when test="@ref">
        <xsl:apply-templates mode="number-of-ref-snc" select="id(@ref)"/>:
      </xsl:when>
      <xsl:when test="count(ancestor::node()[self::drv or self::subart][1]//snc)>1">
        <xsl:number from="drv|subart" level="any" count="snc" format="1."/>
      </xsl:when>
    </xsl:choose>
  </dt>
  <dd>
    <xsl:apply-templates select="gra|uzo|fnt|dif"/>
    <xsl:if test="subsnc">
      <dl compact="">
        <xsl:apply-templates select="subsnc"/>
      </dl>
    </xsl:if>
    <xsl:apply-templates
        select="*[not(self::gra|self::uzo|self::fnt|self::dif|self::subsnc)]"/>
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

<xsl:template name="reftip">
  <xsl:choose>
    <xsl:when test="@tip='vid'">
      <xsl:text>VD: </xsl:text>
    </xsl:when>
    <xsl:when test="@tip='dif'">
      <xsl:text>= </xsl:text>
    </xsl:when>
    <xsl:when test="@tip='sin'">
      <xsl:text>SIN: </xsl:text>
    </xsl:when>
    <xsl:when test="@tip='ant'">
      <xsl:text>ANT: </xsl:text>
    </xsl:when>
    <xsl:when test="@tip='super'">
      <xsl:text>SUP: </xsl:text>
    </xsl:when>
    <xsl:when test="@tip='sub'">
      <xsl:text>SUB: </xsl:text>
    </xsl:when>
    <xsl:when test="@tip='prt'">
      <xsl:text>ERO: </xsl:text>
    </xsl:when>
    <xsl:when test="@tip='malprt'">
      <xsl:text>UJO: </xsl:text>
    </xsl:when>
    <xsl:when test="@tip='hom'">
      <xsl:text>HOM: </xsl:text>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="refgrp">
  <xsl:call-template name="reftip"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="ref">
  <xsl:call-template name="reftip"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="dif/refgrp|dif/ref|rim/refgrp|rim/ref|ekz/refgrp|ekz/ref|klr/refgrp|klr/ref">
  <xsl:if test="@tip='dif'">
    <xsl:text>= </xsl:text>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tez"/>

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
  <xsl:apply-templates/><xsl:text> </xsl:text>
  <xsl:if test="drv/uzo">
    <br />
  </xsl:if>
</xsl:template>

<xsl:template match="mlg">
  (<xsl:apply-templates/>)
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
      select="//trd[@lng=$lng][not(parent::ekz|parent::bld)]
      | //trdgrp[@lng=$lng][not(parent::ekz|parent::bld)]"/>
    <xsl:apply-templates mode="tradukoj"
      select="//ekz/trd[@lng=$lng]|//ekz/trdgrp[@lng=$lng]"/>
  </xsl:if>
</xsl:template>  

<xsl:template match="art" mode="tradukoj">
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">en</xsl:with-param>
    <xsl:with-param name="lingvo">angle</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">be</xsl:with-param>
    <xsl:with-param name="lingvo">beloruse</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">br</xsl:with-param>
    <xsl:with-param name="lingvo">bretone</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">bg</xsl:with-param>
    <xsl:with-param name="lingvo">bulgare</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">cs</xsl:with-param>
    <xsl:with-param name="lingvo">&#x0109;e&#x0125;e</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">da</xsl:with-param>
    <xsl:with-param name="lingvo">dane</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">gd</xsl:with-param>
    <xsl:with-param name="lingvo">gaele</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">de</xsl:with-param>
    <xsl:with-param name="lingvo">germane</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">el</xsl:with-param>
    <xsl:with-param name="lingvo">greke</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">grc</xsl:with-param>
    <xsl:with-param name="lingvo">greke (klasike)</xsl:with-param>
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
    <xsl:with-param name="lng">is</xsl:with-param>
    <xsl:with-param name="lingvo">islande</xsl:with-param>
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
    <xsl:with-param name="lng">lv</xsl:with-param>
    <xsl:with-param name="lingvo">latve</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">lt</xsl:with-param>
    <xsl:with-param name="lingvo">litove</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">grc</xsl:with-param>
    <xsl:with-param name="lingvo">malnovgreke</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">lat</xsl:with-param>
    <xsl:with-param name="lingvo">malnovlatine</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">nl</xsl:with-param>
    <xsl:with-param name="lingvo">nederlande</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">no</xsl:with-param>
    <xsl:with-param name="lingvo">norvege</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">os</xsl:with-param>
    <xsl:with-param name="lingvo">osete</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">pl</xsl:with-param>
    <xsl:with-param name="lingvo">pole</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">sk</xsl:with-param>
    <xsl:with-param name="lingvo">slovake</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">sl</xsl:with-param>
    <xsl:with-param name="lingvo">slovene</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">sv</xsl:with-param>
    <xsl:with-param name="lingvo">svede</xsl:with-param>
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
      self::subdrv or self::subart or self::art or self::ekz][1]" mode="tradukoj"/>:
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

    <xsl:choose>
      <xsl:when test="@ref">
        <xsl:text> </xsl:text>
        <xsl:apply-templates mode="number-of-ref-snc" select="id(@ref)"/>
      </xsl:when>
      <xsl:when test="count(ancestor::node()[self::drv or
      self::subart][1]//snc)>1">
        <xsl:text> </xsl:text>
        <xsl:number from="drv|subart" level="any" count="snc" format="1"/>
      </xsl:when>
      <xsl:otherwise>
       <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="subsnc" mode="tradukoj">
  <xsl:apply-templates select="ancestor::snc" mode="tradukoj"/>
  <xsl:if test="@num">
    <xsl:value-of select="@num"/>
  </xsl:if>
  <xsl:number format="a"/>
</xsl:template>

<xsl:template match="subart" mode="tradukoj">
  <xsl:apply-templates select="ancestor::art/kap" mode="tradukoj"/>
  <xsl:text> </xsl:text>
  <xsl:number format="I"/>
</xsl:template>

<xsl:template match="ekz" mode="tradukoj">
  <xsl:apply-templates select="ind" mode="tradukoj"/>
</xsl:template>        

<xsl:template match="kap" mode="tradukoj">
  <xsl:apply-templates select="tld|rad|text()" mode="tradukoj"/>
</xsl:template>

<xsl:template match="ind" mode="tradukoj">
  <xsl:apply-templates mode="tradukoj"/>
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












