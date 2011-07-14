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
 

	<!-- remove $3 subfields -->
	<xsl:template match="tmarc:s3"></xsl:template>

	
	<!-- remove 245 $h subfields
			We want to use the controlled media types from tmarc.xsl only
			and skip the free-text entered in the records.
	-->
	<xsl:template match="tmarc:d245/tmarc:sh"></xsl:template>



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
		GBV Marc-Records reliably use the i1 field of field 856 to indicate
			http (4) and ftp (1) links. 856 fields with a blank i1 field can
			be URNs which are not linkable in the browser.
		Thus remove all 856 fields whose i1 is not 4 or 1.
	-->
	<xsl:template match="tmarc:d856[@i1!='4' and @i1!='1']">
	</xsl:template>
	
	
	<!--
		All GBV Records have all-numeric IDs (PPN).
		However, to ensure uniqueness of the Marc 001 field across records from
		different databases, a capital letter alphabetic prefix is prepended to 
		the PPN. This rule removes all capital letters to restore the PPN.
	-->	
	<xsl:template match="tmarc:c001">
		<tmarc:c001>
			<xsl:value-of select="translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', '')"/>
		</tmarc:c001>
	</xsl:template>
	

	<!-- 
		Kill 900 and 954 fields with library information.
		There tend to be many of those and we don't use them.
	-->
	<xsl:template match="tmarc:d900|tmarc:d954"></xsl:template>


</xsl:stylesheet>
