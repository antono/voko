<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">


<!-- (c) 2002 che Wolfram Diestel

  transformi la lingvolisto al HTML

-->


<xsl:output method="html" version="4.0" encoding="utf-8"/>

<xsl:template match="lingvoj">
  <html>
    <head>
      <title>mallongigoj de lingvoj</title>
      <link title="indekso-stilo" type="text/css" 
            rel="stylesheet" href="../stl/indeksoj.css"/>
    </head>
    <body>
    <h1>mallongigoj de lingvoj</h1>
    <p>
    La lingvoj kun flagoj estas rekte uzeblaj en la vortaro. Por
    ekuzi alian lingvon necesas flageto en grandeco 21x15 kiel
    PNG aŭ GIF kaj informoj pri alfabeto kaj ordigado.
    </p>

    <table align="center">
    <tr><th>kodo</th><th></th><th>lingvo</th></tr>
    <xsl:for-each select="lingvo">
      <tr>
        <td><code><xsl:value-of select="@kodo"/></code></td>
        <td>
          <xsl:if test="@flago">
            <img class="flago" src="{@flago}" alt=""/>
          </xsl:if>
        </td>
        <td>
          <xsl:value-of select="."/>
        </td>
      </tr>
    </xsl:for-each>
    </table>
  </body>
  </html>
</xsl:template>

</xsl:stylesheet>
    





