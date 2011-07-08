<?xml version="1.0" encoding="UTF-8"?>
<!--
	Creates the pz:metadata field of type 'catalogue-url' by concatenating the
		$catalogueURLHint parameter with the 'id' pz:metadata field.

	July 2011
	Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

	<xsl:param name="catalogueURLHint"/>


	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	
	<xsl:template match="pz:metadata[@type='id']">

		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>

		<pz:metadata type="catalogue-url">
			<xsl:value-of select="$catalogueURLHint"/>
			<xsl:value-of select="."/>
		</pz:metadata>
		
	</xsl:template>

</xsl:stylesheet>
