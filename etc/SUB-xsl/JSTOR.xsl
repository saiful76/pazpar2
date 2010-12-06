<?xml version="1.0" encoding="UTF-8"?>
<!--
	Stylesheet for interpreting JSTOR records from the Z39.50 server
		z3950.uvt.nl:9997/jstor
		
	December 2010
	Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0">

<xsl:output indent="yes" method="xml" version="1.0" 	encoding="UTF-8"/>


	<xsl:template match="JSTOR">
		<pz:record>

			<pz:metadata type="id">
				<xsl:value-of select="URL"/>
			</pz:metadata>

			<xsl:for-each select="AUTHOR">
				<pz:metadata type="author">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="TITLE">
				<pz:metadata type="title">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="YEAR">
				<pz:metadata type="date">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="URL">
				<pz:metadata type="electronic-url">
					<xsl:value-of select="."/>
				</pz:metadata>
		 	</xsl:for-each>

			<xsl:for-each select="DOCTYPE">
				<pz:metadata type="medium">
					<xsl:choose>
						<xsl:when test=".='Review'">review</xsl:when>
						<xsl:when test=".='Editorial'">editorial</xsl:when>
						<xsl:when test=".='Pamphlet'">pamphlet</xsl:when>
						<xsl:otherwise test=".='Article'">article</xsl:otherwise>
					</xsl:choose>
				</pz:metadata>
		 	</xsl:for-each>
			
			<xsl:for-each select="JOURNAL_NAME">
				<pz:metadata type="journal-title">
					<xsl:value-of select="."/>
				</pz:metadata>
		 	</xsl:for-each>
			
			<xsl:for-each select="VOLUME">
				<pz:metadata type="journal-volume">
					<xsl:value-of select="."/>
				</pz:metadata>
		 	</xsl:for-each>

			<xsl:for-each select="NUMBER">
				<pz:metadata type="journal-issue">
					<xsl:value-of select="."/>
				</pz:metadata>
		 	</xsl:for-each>
		 	
			<xsl:for-each select="PAGES">
				<pz:metadata type="journal-pages">
					<xsl:value-of select="."/>
				</pz:metadata>
		 	</xsl:for-each>

			<xsl:for-each select="HOST_ITEM_ENTRY">
				<pz:metadata type="journal-subpart">
					<xsl:value-of select="."/>
				</pz:metadata>
		 	</xsl:for-each>

		</pz:record>
	</xsl:template>

</xsl:stylesheet>
