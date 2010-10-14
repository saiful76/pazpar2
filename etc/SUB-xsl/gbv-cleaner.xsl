<?xml version="1.0" encoding="UTF-8"?>
<!--
	Slight cleanup for GBV Marc Data.

	2010-09/10 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->

<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
	xmlns:tmarc="http://www.indexdata.com/turbomarc">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>
	<xsl:strip-space elements="*" />
  
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
 

	<!-- remove s3 subfields -->
	<xsl:template match="tmarc:s3"></xsl:template>


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


	<!-- 
		GBV Online Contents (Swets data) have broken author information.
		Author information is in Pica field 028C (rather than 028A/B)
			and thus converted to Marc 700 without a $4 subfield.
		For Online Contents databases add a '$4 aut' subfield to
			ensure the author is displayed as such.
		We recognise GBV Online Contents data by the Marc 900 $a
			field containing 'OLC'.
	-->
	<xsl:template match="tmarc:d700">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>

			<xsl:if test="../tmarc:d920/tmarc:sa/text() = 'OLC'">
				<xsl:element name="tmarc:s4">aut</xsl:element>
			</xsl:if>
		</xsl:copy>
	</xsl:template>



	<!-- 
		Kill 900 and 954 fields with library information.
		There tend to be many of those and we don't use them.
	-->
	<xsl:template match="tmarc:d900|tmarc:d954"></xsl:template>


</xsl:stylesheet>
