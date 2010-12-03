<?xml version="1.0" encoding="UTF-8"?>
<!--
	Converts DC Qualified metadata coming from Goescholar’s DSpace SRU interface.
	This contains a few non-standard fields.
		
	December 2010
	Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:srw_dc="info:srw/schema/1/dc-v1.1">

<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

	<xsl:template match="srw_dc:dc">
		<pz:record>

			<pz:metadata type="id">
				<xsl:value-of select="dc:identifier.uri"/>
			</pz:metadata>

			<xsl:for-each select="dc:title">
				<pz:metadata type="title">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:date.issued">
				<pz:metadata type="date">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:subject">
				<pz:metadata type="subject">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:contributor.author">
				<pz:metadata type="author">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:contributor.editor">
				<pz:metadata type="other-person" role="editor">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:description.abstract | dc:type.version">
				<pz:metadata type="description">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:identifier.uri">
				<pz:metadata type="electronic-url">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:type">
				<pz:metadata type="medium">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:identifier.bibliographicCitation">
				<pz:metadata type="citation">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:publisher">
				<pz:metadata type="publication-name">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:identifier.doi">
				<pz:metadata type="doi">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:relation.ispartofseries">
				<xsl:element name="pz:metadata">
					<xsl:attribute name="type">journal-title</xsl:attribute>
					<xsl:if test="../dc:bibliographicCitation.volume">
						<xsl:attribute name="volume">
							<xsl:value-of select="../dc:bibliographicCitation.volume" />
						</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="."/>
				</xsl:element>
			</xsl:for-each>

			<xsl:for-each select="dc:relation.pISSN">
				<pz:metadata type="pissn">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:relation.eISSN">
				<pz:metadata type="eissn">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:identifier.isbn">
				<pz:metadata type="isbn">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:language.iso">
				<pz:metadata type="language">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

		</pz:record>
	</xsl:template>

	<xsl:template match="text()"/>

</xsl:stylesheet>
