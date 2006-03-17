<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
  xmlns:redirect="http://xml.apache.org/xalan/redirect"
    extension-element-prefixes="redirect">


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->


<xsl:output method="xhtml" encoding="utf-8"/>

<xsl:variable name="lingvoj">../cfg/lingvoj.xml</xsl:variable>
<xsl:variable name="fakoj">../cfg/fakoj.xml</xsl:variable>
<xsl:variable name="enhavo">../cfg/enhavo.xml</xsl:variable>

<xsl:template match="/">
  <xsl:apply-template select="document($enhavo)/vortaro"/>

  <xsl:call-template name="eo"/>
  <xsl:call-template name="lng"/>
  <xsl:call-template name="fak"/>
  <xsl:call-template name="ktp"/>

  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="kap-oj|inv|trd-oj">
  <xsl:apply-templates select="litero[v]"/>
</xsl:template>


<xsl:template name="eo">
  <redirect:write select="'_eo.html'">
  <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
      <title><xsl:value-of select="$vortaronomo"/>-indekso: Esperanto</title>
      <link title="indekso-stilo" type="text/css" 
            rel="stylesheet" href="../stl/indeksoj.css"/>
    </head>
    <body>
      <table cellspacing="0">
        <xsl:call-template name="menuo-eo"/>
        <tr>
          <td colspan="4" class="enhavo">

            <h1>alfabeta indekso</h1>
 
            <p style="font-size: 120%">
            <xsl:call-template name="literoj">
               <xsl:with-param name="context" select="//kap-oj"/>
               <xsl:with-param name="lit" select="'xxx'"/>
               <xsl:with-param name="pref" select="'kap_'"/>
            </xsl:call-template>

            <br/><a href="mallong.html">mallongigoj</a>
            </p>
 
            <h1>&#x0109;efaj nocioj</h1>
              ...
 
          </td>
        </tr>
      </table>
    </body>
  </html>
  </redirect:write>
</xsl:template>


<xsl:template name="lng">
  <xsl:variable name="root" select="indekso"/>

  <redirect:write select="'_lng.html'">
  <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
      <title><xsl:value-of select="$vortaronomo"/>-indekso: lingvoj</title>
      <link title="indekso-stilo" type="text/css" 
            rel="stylesheet" href="../stl/indeksoj.css"/>
    </head>
    <body>
      <table cellspacing="0">
        <xsl:call-template name="menuo-lng"/>
        <tr>
          <td colspan="4" class="enhavo">

            <h1>nacilingvaj indeksoj</h1>
	    
            <xsl:for-each select="document($lingvoj)/lingvoj/lingvo">
              <xsl:sort lang="eo"/>

              <xsl:if test="$root/trd-oj[@lng=current()/@kodo]">
                <a>
                  <xsl:attribute name="href">
                    <xsl:value-of select="concat('lx_',@kodo,'_',
                      $root/trd-oj[@lng=current()/@kodo]/litero[v][1]/@name,
                      '.html')"/>
                  </xsl:attribute>
                  <xsl:value-of select="."/>
                </a><br/>
              </xsl:if>
            </xsl:for-each>
          </td>
        </tr>
      </table>
    </body>
  </html>
  </redirect:write>
</xsl:template>


<xsl:template name="fak">
  <xsl:variable name="root" select="indekso"/>

  <redirect:write select="'_fak.html'">
  <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
      <title><xsl:value-of select="$vortaronomo"/>-indekso: fakoj</title>
      <link title="indekso-stilo" type="text/css" 
            rel="stylesheet" href="../stl/indeksoj.css"/>
    </head>
    <body>
      <table cellspacing="0">
        <xsl:call-template name="menuo-fak"/>
        <tr>
          <td colspan="4" class="enhavo">

            <h1>fakindeksoj</h1>

            <xsl:for-each select="document($fakoj)/fakoj/fako">
              <xsl:sort lang="eo"/>

              <xsl:if test="$root/fako[@fak=current()/@kodo]">
                <a>
                  <xsl:attribute name="href">
                    <xsl:value-of select="concat('fx_',@kodo,'.html')"/>
                  </xsl:attribute>
                  <xsl:value-of select="."/>
                </a><br/>
              </xsl:if>
            </xsl:for-each>

          </td>
        </tr>
      </table>
    </body>
  </html>
  </redirect:write>
</xsl:template>


<xsl:template name="ktp">
  <redirect:write select="'_ktp.html'">
  <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
      <title><xsl:value-of select="$vortaronomo"/>-indekso: ktp.</title>
      <link title="indekso-stilo" type="text/css" 
            rel="stylesheet" href="../stl/indeksoj.css"/>
    </head>
    <body>
      <table cellspacing="0">
        <xsl:call-template name="menuo-eo"/>
        <tr>
          <td colspan="4" class="enhavo">

            <h1>gravaj pa&#x011d;oj</h1>
             ...
            <h1>diversaj indeksoj</h1>
            <a href="bildoj.html">bildoj</a><br/>
            <a href="mallong.html">mallongigoj</a><br/>
            <a href="inv_{//inv/litero[v][1]/@name}.html">inversa indekso</a><br/>
             ...
            <h1>redaktado</h1>
             ...
          </td>
        </tr>
      </table>
    </body>
  </html>
  </redirect:write>
</xsl:template>

<xsl:template name="menuo-eo">
  <tr>
    <td class="aktiva"><a href="../inx/_eo.html">Esperanto</a></td>
    <td class="fona"><a href="../inx/_lng.html">Lingvoj</a></td>
    <td class="fona"><a href="../inx/_fak.html">Fakoj</a></td>
    <td class="fona"><a href="../inx/_ktp.html">ktp.</a></td>
  </tr>
</xsl:template>

<xsl:template name="menuo-lng">
  <tr>
    <td class="fona"><a href="../inx/_eo.html">Esperanto</a></td>
    <td class="aktiva"><a href="../inx/_lng.html">Lingvoj</a></td>
    <td class="fona"><a href="../inx/_fak.html">Fakoj</a></td>
    <td class="fona"><a href="../inx/_ktp.html">ktp.</a></td>
  </tr>
</xsl:template>

<xsl:template name="menuo-fak">
  <tr>
    <td class="fona"><a href="../inx/_eo.html">Esperanto</a></td>
    <td class="fona"><a href="../inx/_lng.html">Lingvoj</a></td>
    <td class="aktiva"><a href="../inx/_fak.html">Fakoj</a></td>
    <td class="fona"><a href="../inx/_ktp.html">ktp.</a></td>
  </tr>
</xsl:template>

<xsl:template name="menuo-ktp">
  <tr>
    <td class="fona"><a href="../inx/_eo.html">Esperanto</a></td>
    <td class="fona"><a href="../inx/_lng.html">Lingvoj</a></td>
    <td class="fona"><a href="../inx/_fak.html">Fakoj</a></td>
    <td class="aktiva"><a href="../inx/_ktp.html">ktp.</a></td>
  </tr>
</xsl:template>


<xsl:template match="litero|fako|bld-oj|mlg-oj">

   <xsl:variable name="lit" select="@name"/>
   <xsl:variable name="pref">
     <xsl:choose>
       <xsl:when test="parent::node()[self::kap-oj]">
         <xsl:text>kap_</xsl:text>
       </xsl:when>
       <xsl:when test="parent::node()[self::trd-oj]">
         <xsl:value-of select="concat('lx_',../@lng,'_')"/>
       </xsl:when>
       <xsl:when test="self::fako">
         <xsl:value-of select="concat('fx_',@fak)"/>
       </xsl:when>
       <xsl:when test="self::bld-oj">
         <xsl:text>bildoj</xsl:text>
       </xsl:when>
       <xsl:when test="self::mlg-oj">
         <xsl:text>mallong</xsl:text>
       </xsl:when>
       <xsl:when test="parent::node()[self::inv]">
         <xsl:text>inv_</xsl:text>
       </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <redirect:write select="concat($pref,$lit,'.html')">

  <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
          <xsl:choose>
             <xsl:when test="parent::node()[self::kap-oj]">
       <title>esperanta indekso</title>
             </xsl:when>
             <xsl:when test="parent::node()[self::trd-oj]">
       <title><xsl:value-of 
                   select="document($lingvoj)/lingvoj/lingvo[@kodo=current()/../@lng]"/> 
              <xsl:text> indekso</xsl:text>
       </title>
             </xsl:when>
             <xsl:when test="self::fako">
       <title>fakindekso: <xsl:value-of 
            select="document($fakoj)/fakoj/fako[@kodo=../@fak]"/>
       </title>
             </xsl:when>
             <xsl:when test="parent::node()[self::inv]">
       <title>inversa indekso</title>
            </xsl:when>
            <xsl:when test="self::bld-oj">
       <title>bildo-indekso</title>
            </xsl:when>
            <xsl:when test="self::mlg-oj">
       <title>mallongigo-indekso</title>
            </xsl:when>
          </xsl:choose>
      <link title="indekso-stilo" type="text/css" 
            rel="stylesheet" href="../stl/indeksoj.css"/>
    </head>
    <body>
      <table cellspacing="0">
        <xsl:choose>
          <xsl:when test="parent::node()[self::kap-oj]">
            <xsl:call-template name="menuo-eo"/>
          </xsl:when>
          <xsl:when test="parent::node()[self::trd-oj]">
            <xsl:call-template name="menuo-lng"/>
          </xsl:when>
          <xsl:when test="self::fako">
            <xsl:call-template name="menuo-fak"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="menuo-ktp"/>
          </xsl:otherwise>
        </xsl:choose>
        <tr>
          <td colspan="4" class="enhavo">

          <xsl:choose>
            <xsl:when test="self::fako">
              <h1><xsl:value-of 
                  select="document($fakoj)/fakoj/fako[@kodo=../@fak]"/>
              </h1>
            </xsl:when>
            <xsl:when test="self::bld-oj">
              <h1>bildoj</h1>
            </xsl:when>
            <xsl:when test="self::mlg-oj">
              <h1>mallongigoj</h1>
            </xsl:when>
            <xsl:otherwise>

              <xsl:call-template name="literoj">
                 <xsl:with-param name="context" select=".."/>
                 <xsl:with-param name="lit" select="$lit"/>
                 <xsl:with-param name="pref" select="$pref"/>
              </xsl:call-template>

              <h1>
                <xsl:choose>
                   <xsl:when test="parent::node()[self::inv]">
                     <xsl:text>inversa </xsl:text>
                   </xsl:when>
                   <xsl:otherwise>
                     <xsl:value-of 
                       select="document($lingvoj)/lingvoj/lingvo[@kodo=current()/../@lng]"/>
                     <xsl:text> </xsl:text>
                   </xsl:otherwise>
                 </xsl:choose>
                 <xsl:value-of select="@min"/>
                 <xsl:text>...</xsl:text>
               </h1>
            </xsl:otherwise>

         </xsl:choose>

         <xsl:choose>
           <xsl:when test="self::mlg-oj">
             <dl compact="compact">
               <xsl:apply-templates/>
             </dl>
           </xsl:when>
           <xsl:when test="self::bld-oj">
             <dl>
               <xsl:apply-templates/>
             </dl>
           </xsl:when>
            <xsl:otherwise>
             <xsl:apply-templates/>
           </xsl:otherwise>
        </xsl:choose>

      </td>
        </tr>
      </table>
    </body>
  </html>
  </redirect:write>

</xsl:template>


<xsl:template match="kap-oj/litero/v">
  <xsl:choose>
    <xsl:when test="contains(@mrk,'.')">
      <a href="../art/{substring-before(@mrk,'.')}.html#{@mrk}" 
        target="precipa">
        <xsl:apply-templates select="k"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <a href="../art/{@mrk}.html" target="precipa">
        <b><xsl:apply-templates select="k"/></b>
      </a>
    </xsl:otherwise>
  </xsl:choose>
  <br/>
</xsl:template>


<xsl:template match="trd-oj/litero/v">
  <xsl:apply-templates select="t"/><xsl:text>: </xsl:text>
  <a target="precipa">
    <xsl:attribute name="href">
      <xsl:choose>
        <xsl:when test="contains(@mrk,'.')">
          <xsl:value-of select="concat('../art/',
             substring-before(@mrk,'.'),'.html#',@mrk)"/> 
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('../art/',@mrk,'.html')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:apply-templates select="k"/>
  </a>
  <br/>
</xsl:template>


<xsl:template match="inv/litero/v">
  <a target="precipa">
    <xsl:attribute name="href">
      <xsl:choose>
        <xsl:when test="contains(@mrk,'.')">
          <xsl:value-of select="concat('../art/',
             substring-before(@mrk,'.'),'.html#',@mrk)"/> 
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('../art/',@mrk,'.html')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:value-of select="k"/>
  </a>
  <br/>
</xsl:template>

<xsl:template match="fako/v">
  <a target="precipa">
    <xsl:attribute name="href">
      <xsl:choose>
        <xsl:when test="contains(@mrk,'.')">
          <xsl:value-of select="concat('../art/',
             substring-before(@mrk,'.'),'.html#',@mrk)"/> 
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('../art/',@mrk,'.html')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:apply-templates/>
  </a>
  <br/>
</xsl:template>


<xsl:template match="mlg-oj/v">
  <dt><b><xsl:apply-templates select="t"/></b></dt>
  <dd>
  <a target="precipa">
    <xsl:attribute name="href">
      <xsl:choose>
        <xsl:when test="contains(@mrk,'.')">
          <xsl:value-of select="concat('../art/',
             substring-before(@mrk,'.'),'.html#',@mrk)"/> 
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('../art/',@mrk,'.html')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:apply-templates select="k"/>
  </a>
  </dd>
</xsl:template>

<xsl:template match="bld-oj/v">
  <dt><a target="precipa">
    <xsl:attribute name="href">
      <xsl:choose>
        <xsl:when test="contains(@mrk,'.')">
          <xsl:value-of select="concat('../art/',
             substring-before(@mrk,'.'),'.html#',@mrk)"/> 
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('../art/',@mrk,'.html')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:apply-templates select="k"/>
  </a></dt>
  <dd><xsl:apply-templates select="t"/></dd>
</xsl:template>


<xsl:template match="k">
  <xsl:value-of select="translate(.,'/','')"/>
</xsl:template>



<xsl:template name="literoj">
  <xsl:param name="context"/>
  <xsl:param name="lit"/>
  <xsl:param name="pref"/>

<!-- <xsl:message><xsl:value-of select="$context/@lng"/></xsl:message> -->

  <xsl:variable name="lng" select="string($context/@lng)"/>
  <xsl:for-each select="$context/litero[v]">

    <xsl:choose>
      <xsl:when test="$lit=@name">
        <b class="elektita">
          <xsl:value-of select="@min"/>
        </b><xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <a href="{$pref}{@name}.html">
          <xsl:value-of select="@min"/>
        </a><xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>









