<?xml version="1.0" encoding="UTF-8"?>
<!--
	Stylesheet for interpreting Marc records from PIO’s Z39.50 server.

	* Rewrite their 035 $a field to 001, so we have an ID.
	* Clean up the misplaced page number
	* Fake a date
	
	December 2010
	Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tmarc="http://www.indexdata.com/turbomarc">

	<xsl:output indent="yes" method="xml" version="1.0" 	encoding="UTF-8"/>


	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	
	<!-- 	Use PIO’s system control number as pazpar2 ID for the record 
			by placing it in field 001.
			
			Also extract the publication year from the record’s ID and which 
			seems to be of the form ****-YYYY-***-**-*******.
			(Dodgy but seems to work.)
	-->
	<xsl:template match="tmarc:d035">
		<tmarc:c001>
			<xsl:value-of select="tmarc:sa"/>
		</tmarc:c001>
		
		<xsl:variable name="year" select="substring(tmarc:sa, 6, 4)"/>
		<xsl:if test="translate($year, '0123456789', 'AAAAAAAAAA') = 'AAAA'">
			<tmarc:d260>
				<tmarc:sc>
					<xsl:value-of select="$year"/>
				</tmarc:sc>
			</tmarc:d260>
		</xsl:if>
	</xsl:template>
	
	
	<!--	PIO records erroneously contain page information in 773 $p (the short title field).
			Clean that up by:
				a) adding the information to 773 $g and
				b) moving it to 773 $q
	-->
	<xsl:template match="tmarc:d773/tmarc:sg">
		<tmarc:sg>
			<xsl:value-of select="."/>
			<xsl:if test="../tmarc:sp">
				<xsl:text> p. </xsl:text>
				<xsl:value-of select="../tmarc:sp"/>
			</xsl:if>
		</tmarc:sg>
	</xsl:template>
	
	<xsl:template match="tmarc:d773/tmarc:sp">
		<tmarc:sq>
			<xsl:text>&lt;</xsl:text>
			<xsl:value-of select="."/>
		</tmarc:sq>
	</xsl:template>


</xsl:stylesheet>
