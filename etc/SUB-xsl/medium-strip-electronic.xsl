<?xml version="1.0" encoding="UTF-8"?>
<!--
	Strip a trailing ' (electronic)' from pz:metadata medium fields.
	These are automatically inserted by tmarc.xsl but we don’t want to use them.
	
	July 2011
	Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
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

	
	<xsl:template match="pz:metadata[@type='medium']">
		<pz:metadata type="medium">
			<xsl:choose>
				<xsl:when test="contains(., ' (electronic)')">
					<xsl:value-of select="substring-before(., ' (electronic)')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</pz:metadata>
	</xsl:template>


</xsl:stylesheet>
