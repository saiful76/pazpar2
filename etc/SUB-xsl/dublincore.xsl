<?xml version="1.0" encoding="UTF-8"?>
<!--

    This stylesheet expects oai/dc records
-->
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/">

 <xsl:output indent="yes"
        method="xml"
        version="1.0"
        encoding="UTF-8"/>



  <xsl:template match="/record/metadata/oai_dc:dc">
    <pz:record>

      <xsl:attribute name="mergekey">
        <xsl:text>title </xsl:text>
	<xsl:value-of select="dc:title[1]"/>
	<xsl:text> author </xsl:text>
	<xsl:value-of select="dc:creator[1]"/>
      </xsl:attribute>

      <pz:metadata type="id">
        <xsl:value-of select="/record/header/identifier"/>
      </pz:metadata>

      <xsl:for-each select="dc:title">
        <pz:metadata type="title">
          <xsl:value-of select="."/>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="dc:date">
        <pz:metadata type="date">
	  <xsl:value-of select="."/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="dc:subject">
        <pz:metadata type="subject">
	  <xsl:value-of select="."/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="dc:creator">
	<pz:metadata type="author">
          <xsl:value-of select="."/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="dc:description">
        <pz:metadata type="description">
	  <xsl:value-of select="."/>
	</pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="dc:identifier.url">
          <pz:metadata type="electronic-url">
	  <xsl:value-of select="."/>
	</pz:metadata>
     </xsl:for-each>
  <pz:metadata type="holding">
	<xsl:text>ArXiv</xsl:text>
      </pz:metadata>
    </pz:record>
  </xsl:template>


  <xsl:template match="text()"/>

</xsl:stylesheet>
