<?xml version="1.0" encoding="UTF-8"?>
<!--
	Post-processing SUB Guide records for data from 
		ssgfi1.sub.uni-goettingen.de:2020/

	2010-11 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->

<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>
  
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
 

	<!-- Mark all records as medium: website -->
	<xsl:template match="pz:metadata[@type='medium']">
		<xsl:element name="pz:metadata">
			<xsl:attribute name="type">medium</xsl:attribute>
			<xsl:text>website</xsl:text>
		</xsl:element>
	</xsl:template>


</xsl:stylesheet>
