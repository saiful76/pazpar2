<?xml version="1.0" encoding="UTF-8"?>
<!--
	Convert	language information in ELibM data from ISO 639-1 to ISO 639-2/B
	
	December 2010
	Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->

<xsl:stylesheet
		version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="iso-639-1-to-639-2b.xsl"/>
	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="la">
		<la>
			<xsl:call-template name="languageCodeConverter">
				<xsl:with-param name="languageCode" select="."/>
			</xsl:call-template>
		</la>
	</xsl:template>

</xsl:stylesheet>
