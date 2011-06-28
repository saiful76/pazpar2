<?xml version="1.0" encoding="UTF-8"?>
<!--
	Processes the pz:metadata fields of type dspace-filename to the complete
		document URL for GeoLeo-edocs.
		
	June 2011
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


	<xsl:template match="pz:record">
		<pz:record>
			<!-- 
				Variable setup
				baseURL: URL of the document server prepended to handles when building the URL to access the PDF		
				handleServerURL: URL of the handle server, removed from dc.identifier.uri to get the handle
			-->
			<xsl:variable name="baseURL">
				<xsl:text>http://134.76.21.59/gldocs/bitstream/handle/</xsl:text>
			</xsl:variable>
	
			<xsl:variable name="handleServerURL">
				<xsl:text>http://hdl.handle.net/</xsl:text>
			</xsl:variable>
	

			<!--
				Get the handle by removing the initial $handleServerURL from the dspace-handle field.
			-->
			<xsl:variable name="handle">
				<xsl:value-of select="substring-after(pz:metadata[@type='dspace-handle'], $handleServerURL)"/>
			</xsl:variable>
	

			<!--
				Process pz:metadata fields of type dspace-filename.
				Create a pz:metadata field of type electronic-url for each of them.
				Set the fulltextfile attribute on the pz:metadata field as well.
			-->
			<xsl:for-each select="pz:metadata[@type='dspace-filename']">
				<pz:metadata type="electronic-url" fulltextfile="true">
					<xsl:value-of select="$baseURL"/>
					<xsl:value-of select="$handle"/>
					<xsl:text>/</xsl:text>
					<xsl:value-of select="."/>
					<xsl:text>?sequence=1</xsl:text>
				</pz:metadata>
			</xsl:for-each>
		
	
			<!-- 
				Process the remaining pz:metadata tags.
			-->
			<xsl:apply-templates select="pz:metadata[@type!='dspace-filename' and @type!='dspace-handle']"/>
	
		</pz:record>
	</xsl:template>

</xsl:stylesheet>
