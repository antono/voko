<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="1.0">

<!-- (c) 1999-2003 che Wolfram Diestel 

reguloj por prezentado de la tradukoj

-->

<!-- lingvo-informojn memoru en variablo por pli facila aliro -->
<xsl:variable name="lingvoj" select="document($lingvoj_cfg)/lingvoj"/>

<!-- tradukoj -->

<!-- ne montru tradukojn en la teksto, sed malsupre en propra alineo -->

<xsl:template match="trdgrp|trd"/>


<!-- nur tradukojn ene de difino kaj bildo 
montru tie, cxar ili estas esenca parto de la tiuj --> 

<xsl:template match="dif/trd|bld/trd">
  <i><xsl:apply-templates/></i>
</xsl:template>

<!-- la lingvoj, kiuj aperas en la artikolo -->

<xsl:key name="lingvoj" match="//trdgrp[@lng]|//trd[@lng]" use="@lng"/>

<!-- montru flagojn supre de la pagxo pri ekzistantaj lingvoj -->

<xsl:template name="flagoj">
  <!-- por chiu lingvo elektu reprezentanton -->
  <xsl:for-each select="(//trdgrp[@lng]|//trd[@lng])
       [count(.|key('lingvoj',@lng)[1])=1]">

    <!-- montru la flagon de la lingvo -->
    <xsl:call-template name="flago">
      <xsl:with-param name="lng"><xsl:value-of select="@lng"/></xsl:with-param>
    </xsl:call-template>

  </xsl:for-each>
</xsl:template>


<xsl:template name="flago">
  <xsl:param name="lng"/>

  <!-- eltrovu la flagon de la lingvo, se lingvo au flago ne ekzistas,
  ellasu ghin -->
  <xsl:for-each select="$lingvoj/lingvo[(@kodo=$lng) and @flago]">

    <xsl:text> </xsl:text>
    <xsl:if test="$aspekto='ilustrite'">
      <a href="#lng_{$lng}">
        <img src="{@flago}" alt="{$lng}" 
          border="0" hspace="3" width="21" height="15" class="flago"/>
      </a>
    </xsl:if>

  </xsl:for-each>
</xsl:template>

<!-- traktu chiujn lingvojn de la artikolo -->

<xsl:template name="tradukoj">
  <xsl:if test="//trd">
    <hr />
    <h2>tradukoj</h2>
    <xsl:apply-templates select="//art" mode="tradukoj"/>
  </xsl:if>
</xsl:template>


<xsl:template match="art" mode="tradukoj">
  <!-- elektu por chiu lingvo unu reprezentanton -->
  <xsl:for-each select="(//trdgrp[@lng]|//trd[@lng])
    [count(.|key('lingvoj',@lng)[1])=1]">

    <xsl:sort lang="eo" select="$lingvoj/lingvo[@kodo=current()/@lng]"/>
       
    <xsl:call-template name="lingvo">
      <xsl:with-param name="lng">
        <xsl:value-of select="@lng"/>
      </xsl:with-param>
    </xsl:call-template>

  </xsl:for-each>
</xsl:template>

<!-- traktas unuopan lingvon -->

<xsl:template name="lingvo">
  <xsl:param name="lng"/>

  <!-- se la lingvo ne estas registrita ignoru ghin -->
  <xsl:for-each select="$lingvoj/lingvo[@kodo=$lng]">

    <a name="lng_{$lng}"></a>
    <h3>
      <xsl:if test="$aspekto='ilustrite'">
        <img src="{@flago}" width="21" height="15"
             alt="[{$lng}]" class="flago"/>
      </xsl:if>
      <xsl:text> </xsl:text>
      <!-- la nomo de la lingvo, anstatauigu a per e -->
      <xsl:value-of select="concat(substring(.,1,string-length(.)-1),'e')"/>
    </h3>

  </xsl:for-each>

<!-- "xt" traktas la tradukojn en inversa ordo :-( 
  <xsl:apply-templates mode="tradukoj"
    select="key('lingvoj',$lng)[not(parent::ekz|parent::bld)]"/>
  <xsl:apply-templates mode="tradukoj"
    select="key('lingvoj',$lng)[parent::ekz|parent::bld]"/> 


  do uzu malpli efikan alternativon...:
-->

  <xsl:apply-templates mode="tradukoj"
    select="//trdgrp[@lng=$lng and not(parent::ekz|parent::bld)]|
            //trd[@lng=$lng and not(parent::ekz|parent::bld)]"/>
  <xsl:apply-templates mode="tradukoj"
    select="//trdgrp[@lng=$lng and (parent::ekz|parent::bld)]|
            //trd[@lng=$lng and (parent::ekz|parent::bld)]"/>
</xsl:template>  


<!-- xsl:template name="lingvo">
  <a name="lng_{@kodo}"></a>
  <h3>
    <xsl:if test="$aspekto='ilustrite'">
      <img src="{@flago}" width="21" height="15"
           alt="[{@kodo}]" class="flago"/>
    </xsl:if>
    <xsl:text> </xsl:text>
    - la nomo de la lingvo, anstatauigu a per e -
    <xsl:value-of select="concat(substring(.,1,string-length(.)-1),'e')"/>
  </h3>

  - kolektu chiujn tradukojn de tiu lingvo -
  <xsl:for-each select="//art">
  <xsl:apply-templates mode="tradukoj"
    select="key('lingvoj',@kodo)[not(parent::ekz|parent::bld)]"/>
  <xsl:apply-templates mode="tradukoj"
    select="key('lingvoj',@kodo)[parent::ekz|parent::bld]"/>
  </xsl:for-each>
</xsl:template-->  

<!-- traktas unuopan tradukon au tradukgrupon -->

<xsl:template match="trd[@lng]|trdgrp" mode="tradukoj">
  <span class="trdeo">

    <!-- rigardu, al kiu subarbo apartenas la traduko kaj skribu la
    tradukitan vorton/sencon -->
    <a class="trdeo" href="#{ancestor::node()[@mrk][1]/@mrk}">
      <xsl:apply-templates 
        select="ancestor::node()[
          self::drv or 
          self::snc or 
          self::subsnc or
          self::subdrv or 
          self::subart or 
          self::art or 
          self::ekz or
          self::bld][1]" mode="kapvorto"/>:
    </a>
  </span>

  <!-- skribu la tradukon mem --> 
  <xsl:text> </xsl:text>
  <span class="trdnac">
    <xsl:choose>
      <xsl:when test="trd">
        <xsl:apply-templates select="trd" mode="tradukoj"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="tradukoj"/>
      </xsl:otherwise>
    </xsl:choose>
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

<xsl:template match="trdgrp/trd" mode="tradukoj">
  <xsl:apply-templates mode="tradukoj"/>
  <xsl:if test="following-sibling::trd">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="klr[@tip='ind']" mode="tradukoj"/>
   <!-- ne skribu indeksajn klarigojn tie cxi -->


</xsl:stylesheet>













