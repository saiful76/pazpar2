<?xml version="1.0" encoding="UTF-8"?>
<!--
	Some records (e.g. those from NAL) have the information about an article’s pages
	in the Marc 300 $a field, rather than as part of the 773 $g (or 773 $q) field.
	
	If there is a single 300 $a and a single 773 field, take the content of 
	the 300 $a field and attach it after a space to the 773 $g field.	

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

	
	<xsl:template match="tmarc:d773/tmarc:sg">	
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:if test="count(../../tmarc:d773) = 1 and count(../../tmarc:d300/tmarc:sa) = 1">
				<xsl:for-each select="../../tmarc:d300/tmarc:sa">
					<xsl:text> </xsl:text>
					<xsl:value-of select="."/>
				</xsl:for-each>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
