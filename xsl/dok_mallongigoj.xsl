<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">


<!-- (c) 2002 che Wolfram Diestel

  transformi la mallongigoliston al HTML

-->


<xsl:output method="html" version="4.0" encoding="utf-8"/>

<xsl:template match="mallongigoj">
  <html>
    <head>
      <title>mallongigoj</title>
      <link title="indekso-stilo" type="text/css" 
            rel="stylesheet" href="../stl/indeksoj.css"/>
    </head>
    <body>
    <script type="text/javascript" src="../smb/butonoj.js"/>
    <a href="../inx/_eo.html" onMouseOver="highlight(0)" 
                              onMouseOut="normalize(0)"><img 
       src="../smb/nav_eo1.png" alt="[Esperanto]" border="0"/></a>
    <a href="../inx/_lng.html" onMouseOver="highlight(1)" 
                               onMouseOut="normalize(1)"><img 
       src="../smb/nav_lng1.png" alt="[Lingvoj]" border="0"/></a>
    <a href="../inx/_fak.html" onMouseOver="highlight(2)" 
                               onMouseOut="normalize(2)"><img 
       src="../smb/nav_fak1.png" alt="[Fakoj]" border="0"/></a>
    <a href="../inx/_ktp.html" onMouseOver="highlight(3)" 
                               onMouseOut="normalize(3)"><img 
       src="../smb/nav_ktp1.png" alt="[ktp.]" border="0"/></a>
    <br/>

    <h1>mallongigoj</h1>

    <dl compact="compact">
    <xsl:for-each select="mallongigo">
      <a name="{@mll}"/>
      <dt><xsl:value-of select="@mll"/></dt>
      <dd><xsl:value-of select="."/></dd>
    </xsl:for-each>
    </dl>
  </body>
  </html>
</xsl:template>

</xsl:stylesheet>
    





