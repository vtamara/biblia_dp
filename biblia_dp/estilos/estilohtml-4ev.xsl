<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet [

<!ENTITY % confv SYSTEM "confv.ent">
%confv;
]>
<!-- Detalles de estilo. Dominio p�blico -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version='1.0'
        xmlns="http://www.w3.org/TR/xhtml1/transitional"
	exclude-result-prefixes="#default"> 

	<xsl:import href="&DOCBOOK-XSL;/html/&DOCBOOK-XSL-HTML;"/>

<!-- No table of contents -->
<xsl:param name="generate.toc">
	set toc
</xsl:param> 
<xsl:include href="&REPASA-DOCBOOK-XSL-HTML;"/>

<!-- Chapters are not numerated -->
<xsl:variable name="chapter.autolabel">0</xsl:variable>
	
<xsl:template match="article/title" mode="titlepage.mode" priority="2">
  <hr/>
  <xsl:call-template name="component.title">
    <xsl:with-param name="node" select="ancestor::article[1]"/>
  </xsl:call-template>
</xsl:template>

<!-- <xsl:variable name="html.stylesheet">evangelios_dp.css</xsl:variable>

<xsl:variable name="css.decoration">1</xsl:variable> 

<xsl:variable name="emphasis.propagates.style">1</xsl:variable>  -->


<!-- <xsl:variable name="toc.section.depth">3</xsl:variable> -->
<xsl:variable name="use.id.as.filename">1</xsl:variable>
<xsl:variable name="root.filename">index</xsl:variable>
<!-- <xsl:variable name="section.autolabel">1</xsl:variable> -->
<xsl:variable name="citerefentry.link">1</xsl:variable>
		
</xsl:stylesheet>

