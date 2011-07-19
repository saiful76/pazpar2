<?xml version="1.0" encoding="UTF-8"?>
<!--
	Some records only have a short journal title in Marc 773 $p while our 
	display logic only uses the full title from Marc 773 $t. This title copies
	the 773 $p subfield to a 773 $t subfield if no $t subfield exists.

	July 2011
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

	
	<xsl:template match="tmarc:d773">	
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:if test="not(tmarc:st)">
				<xsl:for-each select="tmarc:sp">
					<tmarc:st>
						<xsl:value-of select="."/>
					</tmarc:st>
				</xsl:for-each>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
