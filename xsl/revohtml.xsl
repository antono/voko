<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xt="http://www.jclark.com/xt"
		version="1.0"
                extension-element-prefixes="xt">

<xsl:output method="html" version="4.0" encoding="utf-8"/>

<xsl:strip-space elements="trdgrp"/>

<!--

origine kreita de Donald Rogers
modifita de Bertil Wennergren
pluevoluigita de Wolfram Diestel

-->

<!-- kelkaj variabloj -->

<xsl:variable name="smbdir">../smb</xsl:variable>
<xsl:variable name="xmldir">../xml</xsl:variable> 
<xsl:variable name="cssdir">../stl</xsl:variable>
<xsl:variable name="redcgi">/cgi-bin/vokomail.pl?art=</xsl:variable>
<xsl:variable name="bibliografio">../dok/bibliogr.xml</xsl:variable>

<!-- kruda artikolstrukturo -->

<xsl:template match="/">
  <html>
  <head>
  <link title="artikolo-stilo" type="text/css" rel="stylesheet"
  href="{$cssdir}/artikolo.css" />
  <title><xsl:value-of select="/vortaro/art/kap/rad"/></title>
  </head>
  <body>
    <xsl:apply-templates/>
  </body>
  </html>
</xsl:template>

<!-- art, subart -->

<xsl:template match="art">
  <xsl:call-template name="flagoj"/>
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
  <xsl:if test="//fnt[bib|aut|vrk|lok]">
    <hr />
    <h2>fontoj</h2>
    <xsl:apply-templates select="//fnt[bib|aut|vrk|lok]" mode="fontoj"/>
  </xsl:if>
  <xsl:if test="//adm">
    <hr />
    <h2>administraj notoj</h2>
    <xsl:apply-templates select="//adm" mode="admin"/>
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

<xsl:template name="flagoj">
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">en</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">be</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">br</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">bg</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">cs</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">da</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">fi</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">fr</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">gd</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">de</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">el</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">es</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">hu</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">is</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">it</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">ja</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">hr</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">la</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">lv</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">lt</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">grc</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">lat</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">nl</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">no</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">os</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">pl</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">pt</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">ru</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">sk</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">sl</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">sv</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flago">
    <xsl:with-param name="lng">tr</xsl:with-param>
  </xsl:call-template>

</xsl:template>

<xsl:template name="flago">
  <xsl:param name="lng"/>
  <xsl:if test="//trd[@lng=$lng]|//trdgrp[@lng=$lng]">
    <xsl:text> </xsl:text>
    <a href="#lng_{$lng}">
    <img src="{$smbdir}/{$lng}.png" alt="{$lng}" 
      border="0" hspace="3" width="21" height="15"/>
    </a>
  </xsl:if>
</xsl:template>

<!-- derivajhoj -->

<xsl:template match="drv">
  <a name="{@mrk}"></a>
  <xsl:apply-templates select="kap|gra|uzo|fnt|dif"/>
  <dl>
  <xsl:apply-templates select="subdrv|snc"/>
  </dl>
  <xsl:apply-templates
    select="*[not(self::subdrv|self::snc|self::gra|self::uzo|self::fnt|self::kap|self::dif|self::mlg)]"/>
</xsl:template>  
	
<xsl:template match="subdrv">
  <dt>
    <xsl:number format="A."/>
    <xsl:comment>[[
      ref="<xsl:value-of select="ancestor::drv/@mrk"/><xsl:number format="A"/>"
    ]]</xsl:comment>

  </dt>
  <dd>
    <xsl:apply-templates select="dif|gra|uzo|fnt"/>
    <dl>
    <xsl:apply-templates select="snc"/>
    </dl>
    <xsl:apply-templates
      select="*[not(self::snc|self::gra|self::uzo|self::fnt|self::dif)]"/>    
  </dd>
</xsl:template>

<xsl:template match="drv/kap">
  <h2>
    <xsl:apply-templates/>
    <xsl:apply-templates select="../mlg"/>
    <xsl:comment>[[
      ref="<xsl:value-of select="ancestor::drv/@mrk"/>"
    ]]</xsl:comment>
  </h2>  
</xsl:template>

<!-- sencoj -->

<xsl:template match="snc" mode="number-of-ref-snc">
  <xsl:number from="drv|subart" level="any" count="snc"/>
</xsl:template>

<xsl:template match="subsnc" mode="number-of-ref-snc">
  <xsl:number format="a"/> 
</xsl:template>

<xsl:template match="sncref">
  <i><xsl:apply-templates mode="number-of-ref-snc" select="id(@ref)"/></i>
</xsl:template>

<xsl:template match="snc">
  <xsl:if test="@mrk">
    <a name="{@mrk}"></a>
  </xsl:if>
  <dt>
    <xsl:choose>
      <xsl:when test="@ref">
        <xsl:apply-templates mode="number-of-ref-snc" select="id(@ref)"/>:
      </xsl:when>
      <xsl:when test="count(ancestor::node()[self::drv or self::subart][1]//snc)>1">
        <xsl:number from="drv|subart" level="any" count="snc" format="1."/>
        <xsl:choose>
          <xsl:when test="@mrk">			       
            <xsl:comment>[[ref="<xsl:value-of select="@mrk"/>"]]</xsl:comment>
          </xsl:when>
          <xsl:otherwise>
            <xsl:comment>[[
              ref="<xsl:value-of select="ancestor::drv/@mrk"/>
              <xsl:number from="drv|subart" level="any" count="snc" format=".1"/>"
            ]]</xsl:comment>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </dt>
  <dd>
    <xsl:apply-templates select="gra|uzo|fnt|dif"/>
    <xsl:if test="subsnc">
      <dl>
        <xsl:apply-templates select="subsnc"/>
      </dl>
    </xsl:if>
    <xsl:apply-templates
        select="*[not(self::gra|self::uzo|self::fnt|self::dif|self::subsnc)]"/>
  </dd>
</xsl:template>  

<xsl:template match="subsnc">
  <xsl:if test="@mrk">
    <a name="{@mrk}"></a>
  </xsl:if>
  <dt>
    <xsl:number format="a)"/>
    <xsl:choose>
      <xsl:when test="@mrk">			       
        <xsl:comment>[[ref="<xsl:value-of select="@mrk"/>"]]</xsl:comment>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment>[[
          ref="<xsl:value-of select="ancestor::drv/@mrk"/>
          <xsl:number format="a"/>"
        ]]</xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
  </dt>
  <dd>
  <xsl:apply-templates/>
  </dd>
</xsl:template>

<!-- priskribaj elementoj -->

<xsl:template match="gra">
  (<xsl:apply-templates/>)<br />
</xsl:template>

<xsl:template match="dif">
  <span class="dif"><xsl:apply-templates/></span>
</xsl:template>

<xsl:template match="ekz">
  <cite class="ekz"><xsl:apply-templates/></cite>
</xsl:template>

<xsl:template match="ekz/tld|ind/tld">
  <span class="ekztld">
  <xsl:choose>
    <xsl:when test="@lit">
      <xsl:value-of select="concat(@lit,substring(ancestor::art/kap/rad,2))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="ancestor::art/kap/rad"/>
    </xsl:otherwise>
  </xsl:choose>
  </span>
</xsl:template>

<xsl:template match="rim/ekz">
  <cite class="rimekz"><xsl:apply-templates/></cite>
</xsl:template>

<xsl:template match="rim" name="rim">
  <span class="rim">
    <b>
    <xsl:text>Rim.</xsl:text>
    <xsl:if test="@num"> 
      <xsl:text> </xsl:text>
      <xsl:value-of select="@num"/>
    </xsl:if>
    <xsl:text>:</xsl:text>
    </b>
    <xsl:apply-templates/></span>
</xsl:template>

<xsl:template match="rim/aut">
  <xsl:text>[</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template
  match="art/rim|subart/rim|drv/rim|subdrv/rim|snc/rim|subsnc/rim">
  <br/>
  <xsl:call-template name="rim"/>
</xsl:template>

<xsl:template name="reftip">
  <xsl:choose>
    <xsl:when test="@tip='vid'">
      <xsl:text>VD:</xsl:text>
    </xsl:when>
    <xsl:when test="@tip='dif'">
      <xsl:text>=</xsl:text>
    </xsl:when>
    <xsl:when test="@tip='sin'">
      <xsl:text>SIN:</xsl:text>
    </xsl:when>
    <xsl:when test="@tip='ant'">
      <xsl:text>ANT:</xsl:text>
    </xsl:when>
    <xsl:when test="@tip='super'">
      <xsl:text>SUP:</xsl:text>
    </xsl:when>
    <xsl:when test="@tip='sub'">
      <xsl:text>SUB:</xsl:text>
    </xsl:when>
    <xsl:when test="@tip='prt'">
      <xsl:text>PRT:</xsl:text>
    </xsl:when>
    <xsl:when test="@tip='malprt'">
      <xsl:text>TUT:</xsl:text>
    </xsl:when>
    <xsl:when test="@tip='hom'">
      <xsl:text>HOM:</xsl:text>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="refgrp">
  <img src="{$smbdir}/{@tip}.gif">
    <xsl:attribute name="alt">
      <xsl:call-template name="reftip"/>
    </xsl:attribute>
  </img>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="ref">
  <xsl:if test="@tip">
    <img src="{$smbdir}/{@tip}.gif">
      <xsl:attribute name="alt">
        <xsl:call-template name="reftip"/>
      </xsl:attribute>
    </img> 
  </xsl:if>
  <xsl:variable name="file" select="substring-before(@cel,'.')"/>
  <span class="ref">
  <xsl:choose>
    <xsl:when test="$file">
      <a class="ref" href="{$file}.html#{$file}.{substring-after(@cel,'.')}">
      <xsl:apply-templates/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <a class="ref" href="{@cel}.html">
      <xsl:apply-templates/>
      </a>
    </xsl:otherwise>
  </xsl:choose>
  </span>
</xsl:template>

<xsl:template match="tez">
  <br/>
  <a name="{@mrk}"/>
  <xsl:comment>[[
      ref="<xsl:value-of select="@mrk"/>"
    ]]</xsl:comment>
  <span class="tez">
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="dif/refgrp|dif/ref|rim/refgrp|rim/ref|ekz/refgrp|ekz/ref|klr/refgrp|klr/ref">
  <!-- 
  <xsl:if test="@tip='dif'">
    <img src="{$smbdir}/{@tip}.gif">
      <xsl:attribute name="alt">
        <xsl:call-template name="reftip"/>
      </xsl:attribute>
    </img> 
  </xsl:if>
  -->
  <xsl:variable name="file" select="substring-before(@cel,'.')"/>
  <xsl:choose>
    <xsl:when test="$file">
      <a class="{local-name((ancestor::rim|ancestor::ekz|ancestor::dif)[last()])}" 
         href="{$file}.html#{$file}.{substring-after(@cel,'.')}">
      <xsl:apply-templates/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <a class="{local-name((ancestor::rim|ancestor::ekz|ancestor::dif)[last()])}" href="{@cel}.html">
      <xsl:apply-templates/>
      </a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="sup|fnt|ofc">
  <sup class="{local-name()}"><xsl:value-of select="."/></sup>
</xsl:template>

<xsl:template match="fnt[bib|aut|vrk|lok]">
  <xsl:variable name="n">
    <xsl:number level="any" count="fnt[bib|aut|vrk|lok]"/>
  </xsl:variable>
  <span class="fnt">
    <a name="ekz_{$n}"></a>
    <xsl:text>[</xsl:text>
    <a class="{local-name((ancestor::rim|ancestor::ekz|ancestor::bld|self::node())[1])}" 
	href="#fnt_{$n}"><xsl:value-of select="$n"/></a>
    <xsl:text>]</xsl:text>
  </span>
</xsl:template>

<xsl:template match="klr">
  <span class="klr"><xsl:apply-templates/></span>
</xsl:template>

<xsl:template match="bld">
  <br/>
  <center>
  <img src="{@lok}"/>
  <br/>
  <i>
  <xsl:apply-templates select="text()|tld|ind|klr|fnt"/>
  </i>
  <br/>
  </center>
</xsl:template>

<xsl:template match="bld/trd">
  <i><xsl:apply-templates/></i>
</xsl:template>

<xsl:template match="uzo[@tip='fak']">
  <img src="{$smbdir}/{.}.gif" alt="{.}" align="absmiddle" />
  <xsl:if test="drv/uzo">
    <br />
  </xsl:if>
</xsl:template>

<xsl:template match="uzo[@tip='stl']">
  <xsl:choose>
    <xsl:when test=".='KOMUNE'">
      <xsl:text>(komune) </xsl:text>
    </xsl:when>
    <xsl:when test=".='FIG'">
      <xsl:text>(f) </xsl:text>
    </xsl:when>
    <xsl:when test=".='ARK'">
      <xsl:text>(ark.) </xsl:text>
    </xsl:when>
    <xsl:when test=".='EVI'">
      <xsl:text>(Ev.) </xsl:text>
    </xsl:when>
    <xsl:when test=".='FRAZ'">
      <xsl:text>(fraza&#x0135;o) </xsl:text>
    </xsl:when>
    <xsl:when test=".='VULG'">
      <xsl:text>(vulgare) </xsl:text>
    </xsl:when>
    <xsl:when test=".='RAR'">
      <xsl:text>(malofte) </xsl:text>
    </xsl:when>
    <xsl:when test=".='POE'">
      <xsl:text>(poezie) </xsl:text>
    </xsl:when>
    <xsl:when test=".='NEO'">
      <xsl:text>(neologismo) </xsl:text>
    </xsl:when>    
  </xsl:choose>
  <xsl:if test="drv/uzo">
    <br />
  </xsl:if>
</xsl:template>

<xsl:template match="uzo">
  <xsl:apply-templates/>
  <xsl:if test="drv/uzo">
    <br />
  </xsl:if>
</xsl:template>

<xsl:template match="mlg">
  (<xsl:apply-templates/>)
</xsl:template>

<xsl:template match="url">
  <br />
  <img src="{$smbdir}/url.gif" alt="URL:" />
  <a class="url" href="{@ref}" target="_new">
  <xsl:apply-templates/>
  </a>
</xsl:template>

<xsl:template match="sub">
  <sub>
  <xsl:apply-templates/>
  </sub>
</xsl:template>

<xsl:template match="em">
  <strong>
  <xsl:apply-templates/>
  </strong>
</xsl:template>

<xsl:template match="ctl">
  <xsl:text>&#x201e;</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>&#x201c;</xsl:text>
</xsl:template>

<xsl:template match="trdgrp|trd">
</xsl:template>

<xsl:template match="dif/trd">
  <i><xsl:apply-templates/></i>
</xsl:template>

<xsl:template match="adm"/>

<!-- teksto -->

<xsl:template match="text()">
  <xsl:value-of select="."/>
</xsl:template>

<!-- tradukoj -->

<xsl:template name="lingvo">
  <xsl:param name="lng"/>
  <xsl:param name="lingvo"/>
  <xsl:if test="//trd[@lng=$lng and not(ancestor::bld)]|//trdgrp[@lng=$lng]">
    <a name="lng_{$lng}"></a>
    <h3>
      <img src="{$smbdir}/{$lng}.png" width="21" height="15" alt="[{$lng}]"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$lingvo"/>
    </h3>
    <xsl:apply-templates mode="tradukoj"
      select="//trd[@lng=$lng][not(parent::ekz|parent::bld)]
      | //trdgrp[@lng=$lng][not(parent::ekz|parent::bld)]"/>
    <xsl:apply-templates mode="tradukoj"
      select="//ekz/trd[@lng=$lng]|//ekz/trdgrp[@lng=$lng]
	|//bld/trd[@lng=$lng]|//bld/trdgrp[@lng=$lng]"/>
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
    <xsl:with-param name="lng">fi</xsl:with-param>
    <xsl:with-param name="lingvo">finne</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">fr</xsl:with-param>
    <xsl:with-param name="lingvo">france</xsl:with-param>
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
    <xsl:with-param name="lng">es</xsl:with-param>
    <xsl:with-param name="lingvo">hispane</xsl:with-param>
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
    <xsl:with-param name="lng">ja</xsl:with-param>
    <xsl:with-param name="lingvo">japane</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">hr</xsl:with-param>
    <xsl:with-param name="lingvo">kroate</xsl:with-param>
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
    <xsl:with-param name="lng">pt</xsl:with-param>
    <xsl:with-param name="lingvo">portugale</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lingvo">
    <xsl:with-param name="lng">ru</xsl:with-param>
    <xsl:with-param name="lingvo">ruse</xsl:with-param>
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
    <xsl:with-param name="lng">tr</xsl:with-param>
    <xsl:with-param name="lingvo">turke</xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="trd[@lng]|trdgrp" mode="tradukoj">
  <span class="trdeo">
  <!-- rigardu, al kiu subarbo apartenas la traduko,
    KOREKTU: se la traduko apartenas rekte al art okazas
             reeniro de la antaua sxablono -->
  <a class="trdeo" href="#{ancestor::node()[@mrk][1]/@mrk}">
  <xsl:apply-templates 
    select="ancestor::node()[self::drv or self::snc or self::subsnc or
      self::subdrv or self::subart or self::art or self::ekz or self::bld][1]" mode="tradukoj"/>:</a>
  </span>
  <xsl:text> </xsl:text>
  <span class="trdnac">
	<!-- xsl:value-of select="normalize-space(.)"/ -->
    <xsl:apply-templates mode="tradukoj"/>
  </span>
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

<xsl:template match="subdrv" mode="tradukoj">
  <xsl:apply-templates select="ancestor::drv/kap" mode="tradukoj"/>
  <xsl:text> </xsl:text>
  <xsl:number format="A"/>
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

<xsl:template match="ekz|bld" mode="tradukoj">
  <xsl:apply-templates select="ind" mode="tradukoj"/>
</xsl:template>

<xsl:template match="kap" mode="tradukoj">
  <xsl:apply-templates select="tld|rad|text()" mode="tradukoj"/>
</xsl:template>

<xsl:template match="ind" mode="tradukoj">
  <xsl:choose>
    <xsl:when test="mll">
      <xsl:apply-templates select="mll" mode="tradukoj"/>	
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="tradukoj"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="ind/mll" mode="tradukoj">
  <xsl:if test="@tip='fin' or @tip='mez'">
    <xsl:text>...</xsl:text>
  </xsl:if>
  <xsl:apply-templates mode="tradukoj"/>
  <xsl:if test="@tip='kom' or @tip='mez'">
    <xsl:text>...</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="trdgrp/trd" mode="tradukoj">
  <xsl:apply-templates mode="tradukoj"/>
</xsl:template>

<xsl:template match="tld" mode="tradukoj">
  <xsl:value-of select="@lit"/>
  <xsl:text>~</xsl:text>
</xsl:template>

<xsl:template match="klr[@tip='ind']" mode="tradukoj"/>

<!-- ######################### fontoj ########################## -->

<xsl:template match="fnt" mode="fontoj">
  <xsl:variable name="n">
    <xsl:number level="any" count="fnt[bib|aut|vrk|lok]"/>
  </xsl:variable>
  <span class="fontoj">
  <a name="fnt_{$n}"></a>
  <a class="fnt" href="#ekz_{$n}"><xsl:value-of select="$n"/></a>.
  <xsl:apply-templates mode="fontoj" select="bib|aut|vrk|lok"/>
  </span>
  <br />
</xsl:template>

<xsl:template match="bib" mode="fontoj">
  <xsl:variable name="mll" select="."/>
  <a class="fnt" href="../dok/bibliogr.html#{$mll}" target="indekso">
  <xsl:apply-templates mode="bibliogr"
    select="document($bibliografio)//vrk[@mll=$mll]"/>
  </a>
  <xsl:if test="following-sibling::lok">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="vrk" mode="bibliogr">
  <xsl:apply-templates mode="bibliogr" select="aut|trd|tit"/>
</xsl:template>

<xsl:template match="aut" mode="bibliogr">
  <xsl:apply-templates mode="bibliogr"/>
  <xsl:choose>
    <xsl:when test="following-sibling::trd">
      <xsl:text>, </xsl:text>
    </xsl:when>
    <xsl:when test="following-sibling::tit">
      <xsl:text>: </xsl:text>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="trd" mode="bibliogr">
  <xsl:text>trad. </xsl:text>
  <xsl:apply-templates mode="bibliogr"/>
  <xsl:if test="following-sibling::tit">
      <xsl:text>: </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="tit" mode="bibliogr">
  <xsl:apply-templates mode="bibliogr"/>
</xsl:template>

<xsl:template match="aut" mode="fontoj">
  <xsl:apply-templates mode="fontoj"/>
  <xsl:if test="following-sibling::vrk|following-sibling::lok">
    <xsl:text>: </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="vrk" mode="fontoj">
  <xsl:apply-templates mode="fontoj"/>
  <xsl:if test="following-sibling::lok">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>  

<xsl:template match="lok" mode="fontoj">
  <xsl:apply-templates mode="fontoj"/>
</xsl:template>

<xsl:template match="url" mode="fontoj">
  <a class="fnturl" href="{@ref}" target="_new">
  <xsl:apply-templates/>
  </a>
</xsl:template>

<!-- administraj notoj -->

<xsl:template match="adm" mode="admin">
  <b>pri <xsl:apply-templates 
    select="ancestor::node()[self::drv or self::snc or self::subsnc or
      self::subdrv or self::subart or self::art][1]"
    mode="admin"/>
  <xsl:text>:
</xsl:text>
  </b>
  <pre>
  <xsl:apply-templates mode="admin"/>
  </pre>
</xsl:template>

<xsl:template match="art|drv" mode="admin">
  <a href="#{@mrk}"><xsl:apply-templates select="kap" mode="admin"/></a>
</xsl:template>

<xsl:template match="snc" mode="admin">
  <a href="#{ancestor::node()[@mrk][1]/@mrk}">
  <xsl:apply-templates select="ancestor::node()[self::drv or
    self::art][1]/kap" mode="admin"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@ref">
        <xsl:apply-templates mode="number-of-ref-snc" select="id(@ref)"/>:
      </xsl:when>
      <xsl:when test="count(ancestor::node()[self::drv or self::subart][1]//snc)>1">
        <xsl:number from="drv|subart" level="any" count="snc" format="1."/>
      </xsl:when>
    </xsl:choose>
  </a>
</xsl:template>

<xsl:template match="subsnc" mode="admin">
  <a href="#{ancestor::node()[@mrk][1]/@mrk}">
  <xsl:apply-templates select="ancestor::node()[self::drv or
    self::art][1]/kap" mode="admin"/>
  <xsl:if test="@num">
    <xsl:text> </xsl:text>
    <xsl:value-of select="@num"/>
  </xsl:if>
  <xsl:text> </xsl:text>
  <xsl:number format="a"/>
  </a>
</xsl:template>

<xsl:template match="subart" mode="admin">
  <a href="#{ancestor::node()[@mrk][1]/@mrk}">
  <xsl:apply-templates select="ancestor::art/kap" mode="admin"/>
  <xsl:text> </xsl:text>
  <xsl:number format="I"/>
  </a>
</xsl:template>

<xsl:template match="subdrv" mode="admin">
  <a href="#{ancestor::node()[@mrk][1]/@mrk}">
  <xsl:apply-templates select="ancestor::drv/kap" mode="admin"/>
  <xsl:text> </xsl:text>
  <xsl:number format="A"/>
  </a>
</xsl:template>

<xsl:template match="kap" mode="admin">
  <xsl:apply-templates select="tld|rad|text()" mode="admin"/>
</xsl:template>

<xsl:template match="tld" mode="admin">
  <xsl:value-of select="@lit"/>
  <xsl:text>~</xsl:text>
</xsl:template>

<xsl:template match="aut" mode="admin">
  <xsl:text>[</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>]</xsl:text>
</xsl:template>

<!-- redakto -->

<xsl:template name="redakto">
  <xsl:variable name="xml"
    select="substring-before(substring-after(@mrk,'$Id: '),',v')"/>
  <span class="redakto">
  [<a class="redakto" href="{$xmldir}/{$xml}"><xsl:value-of select="$xml"/></a>]
  [<a class="redakto" href="{$redcgi}{substring-before($xml,'.xml')}">redakti...</a>]
  versio: <xsl:value-of 
    select="substring-before(substring-after(@mrk,',v'),'revo')"/>
  </span>
  <br />
</xsl:template>

</xsl:stylesheet>












