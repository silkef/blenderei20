<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs"
  xmlns="http://www.w3.org/1999/xhtml"
  version="3.0">
  
  <xsl:output html-version="5.0" method="xhtml" omit-xml-declaration="true" include-content-type="no"
    indent="no"/>
  
  <xsl:mode on-no-match="shallow-copy" default-mode="fix" name="fix"/>
  
  <xsl:param name="dir" as="xs:string"/>
  
  <xsl:template name="fix-pages">
    <xsl:variable name="uri" as="xs:anyURI" select="resolve-uri($dir)"/>
    <xsl:for-each select="collection($uri || '?select=*.html')">
      <xsl:variable name="out-uri" select="replace($uri, '[^/]+/?$', 'out/') || replace(base-uri(), '^.+/', '')"/>
      <xsl:result-document href="{$out-uri}">
        <xsl:apply-templates mode="fix"/>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="body/@onload" mode="fix"/>
  
  <xsl:template match="body/@class" mode="fix">
    <xsl:next-match/>
    <xsl:attribute name="onclick" select="'document.querySelector(''#nav'').removeAttribute(''open'')'"/>
  </xsl:template>
  
  <xsl:template match="body/@onclick" mode="fix"/>

  <xsl:template match="body/script[@src = 'Tobi/js/tobi.js']" mode="fix">
    <xsl:copy>
      <xsl:text expand-text="false">const tobi = new Tobi({'zoom':false});</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="head[../body/script[@src = 'Tobi/js/tobi.js']]/*[last()]" mode="fix">
    <xsl:next-match/>
    <xsl:copy-of select="preceding::text()[1], ../../body/script[@src = 'Tobi/js/tobi.js']"/>
  </xsl:template>
  
  <xsl:variable name="details" as="element(details)">
    <details id="nav" aria-label="navigation" xml:space="preserve">
        <summary onclick="event.stopPropagation()"></summary>
        <ul>
          <li><b><a href="index.html">Blenderei</a></b>
            <ul>
              <li><a href="modeling_rigging.html">Modeling and Rigging</a></li>
              <li><a href="animation.html">Animation</a></li>
              <li><a href="VR_VFX.html">VR and VFX</a></li>
              <li><a href="illustration.html">Illustration</a></li>
              <li><a href="architecture_exhibition-design.html">Architecture and Exhibition Design</a></li>
              <li><a href="environment.html">Environment</a></li>
              <li><a href="about.html">About/Imprint</a></li>
            </ul>
          </li>
        </ul>
    </details>
  </xsl:variable>
  
  <xsl:template match="main/*[1]" mode="fix" priority="1">
    <xsl:apply-templates select="$details" mode="fix">
      <xsl:with-param name="page-name" as="xs:string" select="replace(base-uri(), '^.+/', '')" tunnel="yes"/>
    </xsl:apply-templates>
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="main[not(h1 = 'Blenderei')]/h1" mode="fix"/>

  <xsl:template match="main/details" mode="fix"/>
  
  <xsl:template match="details/@xml:space" mode="fix"/>
  
  <xsl:template match="details//a[@href]" mode="fix">
    <xsl:param name="page-name" as="xs:string" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="@href = $page-name">
        <xsl:sequence select="node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:variable name="fineprint" as="element(p)">
    <p class="fineprint">© 2019 <a href="about.html">Silke Fischer-Imsieke</a></p>
  </xsl:variable>
  
  <xsl:template match="p[tokenize(@class) = 'fineprint']" mode="fix">
    <xsl:copy-of select="$fineprint"/>
  </xsl:template>

</xsl:stylesheet>