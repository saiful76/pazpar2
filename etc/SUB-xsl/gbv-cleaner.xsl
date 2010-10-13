<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
	xmlns:tmarc="http://www.indexdata.com/turbomarc">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>
<!--
	2010-09-17 ssp: Slight cleanup for data from z3950.gbv.de:20012.
-->
  
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
 
	<!-- remove s3 subfields -->
	<xsl:template match="tmarc:s3">
	</xsl:template>


	<!-- journal stuff -->
	<!-- volume and pages of article in 773 $g -->
	<xsl:template match="tmarc:d773">
		<xsl:if test="tmarc:sg">
			<pz:metadata type="volumeandpages">
				<xsl:value-of select="." />
			</pz:metadata>
		</xsl:if>
		<xsl:if test="tmarc:st">
			<pz:metadata type="journal">
				<xsl:value-of select="." />
			</pz:metadata>
		</xsl:if>
	</xsl:template>

	
	<!-- Idea (but a bad one): change d700 elements into d100 elements
	<xsl:template match="tmarc:d700">
		<tmarc:d100>
			<xsl:apply-templates select="@*|node()"/>
		</tmarc:d100>
	</xsl:template>
	-->

	<!-- Kill 900 and 945 fields with library information.
			There tend to be many of those and we don't use them.
	-->
	<xsl:template match="tmarc:d900|tmarc:d945">
	</xsl:template>


</xsl:stylesheet>
