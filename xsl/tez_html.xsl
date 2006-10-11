<!DOCTYPE xsl:transform>

<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  version="2.0"
  extension-element-prefixes="saxon" 
>

<!-- xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
  xmlns:redirect="http://xml.apache.org/xalan/redirect"
    extension-element-prefixes="redirect" -->


<!-- (c) 2006 che Wolfram Diestel
     licenco GPL 2.0
-->


<xsl:output method="@format@" encoding="utf-8"/>
<xsl:strip-space elements="k"/>

<xsl:param name="verbose" select="'false'"/>
<xsl:param name="warn-about-dead-refs" select="'true'"/>


<!-- xsl:variable name="fakoj">../cfg/fakoj.xml</xsl:variable -->
<xsl:variable name="enhavo">../cfg/enhavo.xml</xsl:variable>
  <xsl:variable name="inx_paghoj" select="count(document($enhavo)//pagho[not(@kashita='jes')])"/>

<xsl:variable name="root" select="/"/>


<xsl:template match="//tez">
  <xsl:apply-templates/>

  <!-- xsl:call-template name="fakoj"/ -->
</xsl:template>


<xsl:template match="nod">
  <xsl:variable name="dosiero" select="concat('tz_',translate(@mrk,'.','_'),'.html')"/>

  <xsl:if test="$verbose='true'">
    <xsl:message>skribas al <xsl:value-of select="$dosiero"/></xsl:message>
  </xsl:if>

  <!-- redirect:write select="$dosiero" -->
  <xsl:result-document href="{$dosiero}" method="@format@" encoding="utf-8" indent="yes">
  <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
      <title><xsl:value-of select="concat('teza&#x016d;ro: ',k)"/></title>
      <link title="indekso-stilo" type="text/css" 
            rel="stylesheet" href="../stl/indeksoj.css"/>
    </head>
    <body>
      <table cellspacing="0">
        <xsl:call-template name="menuo-eo"/>
        <tr>
          <td colspan="{$inx_paghoj}" class="enhavo">
            <xsl:for-each select="uzo">
              <xsl:call-template name="fak-ref">
                <xsl:with-param name="fak" select="."/>
              </xsl:call-template>
            </xsl:for-each>

            <h1><xsl:call-template name="art-ref"/></h1>
            <xsl:apply-templates select="*[not(self::k) and not(self::uzo)]"/>
          </td>
        </tr>
      </table>
    </body>
  </html>
  <!-- /redirect:write -->
  </xsl:result-document>
</xsl:template>


<!-- xsl:template name="fakoj">
  <xsl:for-each select="document($fakoj)/fakoj/fako">

    <xsl:variable name="fak" select="@kodo"/>
    <xsl:variable name="dosiero" select="concat('fxs_',$fak,'.html')"/>

    <xsl:if test="$verbose='true'">
      <xsl:message>skribas al <xsl:value-of select="$dosiero"/></xsl:message>
    </xsl:if>

    !- redirect:write select="$dosiero" -
    <xsl:result-document href="{$dosiero}" method="@format@" encoding="utf-8" indent="yes">
    <html>
      <head>
         <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
         <title><xsl:value-of select="concat('teza&#x016d;ro - fako: ',$fak)"/></title>
         <link title="indekso-stilo" type="text/css" 
            rel="stylesheet" href="../stl/indeksoj.css"/>
      </head>
      <body>
        <table cellspacing="0">
          <xsl:call-template name="menuo-fak"/>
          <tr>
             <td colspan="{$inx_paghoj}" class="enhavo">

               <a href="../inx/fx_{$fak}.html">alfabete</a><xsl:text> </xsl:text>
               <b class="elektita">strukture</b><xsl:text> </xsl:text>

               <h1><xsl:value-of 
                   select="."/>
               </h1>

               <xsl:for-each select="$root">
                 <xsl:call-template name="fak-radikoj">
                    <xsl:with-param name="fako" select="$fak"/>
                 </xsl:call-template>
               </xsl:for-each>
             </td>
          </tr>
        </table>
      </body>
    </html>
    !- /redirect:write -
    </xsl:result-document>
  </xsl:for-each>
</xsl:template -->


<!-- xsl:template name="fak-radikoj">
  <xsl:param name="fako"/>

  <xsl:for-each select="tez/nod[tezrad[@fak=$fako] or
     (uzo=$fako and not(super/r) and not(malprt/r) and (sub/r or prt/r))]">

     <a href="{concat('tz_',translate(@mrk,'.','_'),'.html')}">
      <img src="../smb/vid.gif" alt="&#x2192;" border="0"/>
     </a>
     <b><xsl:call-template name="art-ref"/></b><br/>
  </xsl:for-each>
</xsl:template -->


<!-- xsl:template name="fak-ref">
  <xsl:param name="fak"/>

  <a href="{concat('fxs_',$fak,'.html')}">
    <img src="{concat('../smb/',$fak,'.gif')}" alt="{$fak}" border="0"/>
  </a>
</xsl:template -->


<xsl:template name="fak-ref">
  <xsl:param name="fak"/>

  <a href="{concat('../inx/fx_',$fak,'.html')}">
    <img src="{concat('../smb/',$fak,'.gif')}" alt="{$fak}" border="0"/>
  </a>
</xsl:template>


<xsl:template name="art-ref">
  <xsl:choose>
    <xsl:when test="contains(@mrk,'.')">
      <a href="../art/{substring-before(@mrk,'.')}.html#{@mrk}" 
        target="precipa">
        <xsl:apply-templates select="k"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <a href="../art/{@mrk}.html" target="precipa">
        <xsl:apply-templates select="k"/>
      </a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>



<xsl:template name="menuo">
  <xsl:variable name="aktiva" select="@dosiero"/>
  <tr>
    <xsl:for-each select="../pagho[not(@kashita='jes')]">
      <xsl:choose>
        <xsl:when test="@dosiero=$aktiva">
          <td class="aktiva">
            <a href="../inx/{@dosiero}">
              <xsl:value-of select="@titolo"/>
            </a>
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td class="fona">
            <a href="../inx/{@dosiero}">
              <xsl:value-of select="@titolo"/>
            </a>
          </td>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>     
  </tr>
</xsl:template>


<xsl:template name="menuo-eo">
  <xsl:for-each select="document($enhavo)//pagho[.//KAP-OJ][1]"> 
    <xsl:call-template name="menuo"/>
  </xsl:for-each>
</xsl:template>


<!-- xsl:template name="menuo-fak">
  <xsl:for-each select="document($enhavo)//pagho[.//FAKOJ][1]"> 
    <xsl:call-template name="menuo"/>
  </xsl:for-each>
</xsl:template --> 


<xsl:template match="k">
  <xsl:apply-templates/>
  <xsl:if test="@n"><sup><xsl:value-of select="@n"/></sup></xsl:if>
</xsl:template>

<xsl:template match="sin">
  <xsl:if test="r">
    <i class="griza">sinonimoj</i><br/>
    <xsl:call-template name="refs">
       <xsl:with-param name="smb" select="'sin.gif'"/>
       <xsl:with-param name="alt" select="'&#x21d2;'"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template match="super">
  <xsl:if test="r">
    <i class="griza">speco de</i><br/>
    <xsl:call-template name="refs">
       <xsl:with-param name="smb" select="'super.gif'"/>
       <xsl:with-param name="alt" select="'&#x2197;'"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template match="sub">
  <xsl:if test="r">
    <i class="griza">specoj</i><br/>
    <xsl:call-template name="refs">
       <xsl:with-param name="smb" select="'sub.gif'"/>
       <xsl:with-param name="alt" select="'&#x2199;'"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template match="vid">
  <xsl:if test="r">
    <i class="griza">vidu</i><br/>
    <xsl:call-template name="refs">
       <xsl:with-param name="smb" select="'vid.gif'"/>
       <xsl:with-param name="alt" select="'&#x2192;'"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template name="refs">
  <xsl:param name="smb"/>
  <xsl:param name="alt"/>
  <xsl:for-each select="r">
    <xsl:if test="not(following-sibling::r[@c=current()/@c])"> <!-- evitu duoblajhojn -->

      <xsl:variable name="nod" select="//tez/nod[@mrk=current()/@c or @mrk2=current()/@c]"/>
      <xsl:choose>
        <xsl:when test="$nod">

          <a href="{concat('tz_',translate($nod/@mrk,'.','_'),'.html')}">
            <img src="{concat('../smb/',$smb)}" alt="{$alt}" border="0"/>
          </a>
          <xsl:call-template name="art-ref2">
            <xsl:with-param name="nod" select="$nod"/>
          </xsl:call-template>
          <br/>
        </xsl:when>
        <xsl:when test="$warn-about-dead-refs='true'">
           <xsl:message> <!-- eble skribu tion en eraro-dosieron por prezenti al redaktantoj -->
             <xsl:text>nesolvita referenco de </xsl:text>
             <xsl:value-of select="../../@mrk"/>
             <xsl:text> al </xsl:text>
             <xsl:value-of select="@c"/>
           </xsl:message>
        </xsl:when>
      </xsl:choose>

    </xsl:if>
  </xsl:for-each>
</xsl:template>


<xsl:template name="art-ref2">
  <xsl:param name="nod"/>

  <a target="precipa">
    <xsl:attribute name="href">
      <xsl:choose>
        <xsl:when test="contains(@c,'.')">
          <xsl:value-of select="concat('../art/',substring-before(@c,'.'),'.html#',@c)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('../art/',@c,'.html')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>

    <xsl:apply-templates select="$nod/k"/>
  </a>
</xsl:template>



<!-- /xsl:stylesheet -->
</xsl:transform>








