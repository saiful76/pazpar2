<?xml version="1.0" encoding="UTF-8"?>
<!--
	Strip the 'physical-extent' pz:metadata field.
	In articles it can duplicate the information present in the 'journal-subpart' field.
	
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

	
	<xsl:template match="pz:metadata[@type='physical-extent']">
	</xsl:template>


</xsl:stylesheet>
