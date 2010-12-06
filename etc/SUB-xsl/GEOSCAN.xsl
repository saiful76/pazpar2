<?xml version="1.0" encoding="UTF-8"?>
<!--
	Extracts the ID of a GEOSCAN Marc record from field 008 $a
		and places it into field 001 $a, so we have a proper ID
		when working in pazpar2 later on.
		
	December 2010
	Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tmarc="http://www.indexdata.com/turbomarc">

<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="tmarc:d024">
		<xsl:if test="(tmarc:sa) and (tmarc:s2 = 'GEOSCAN ID')">
			<tmarc:c001>
				<xsl:value-of select="tmarc:sa"/>
			</tmarc:c001>
		</xsl:if>
	</xsl:template>


</xsl:stylesheet>
