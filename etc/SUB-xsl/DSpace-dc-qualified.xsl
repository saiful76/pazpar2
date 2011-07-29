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
	xmlns:srw_dc="info:srw/schema/1/dc-v1.1">

	<xsl:import href="metadata-splitter.xsl"/>
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

			<xsl:for-each select="dc:date.issued">
				<pz:metadata type="date">
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

			<xsl:if test="dc:relation.ispartofseries">
				<pz:metadata type="journal-title">
					<xsl:value-of select="dc:relation.ispartofseries"/>
				</pz:metadata>
				
				<pz:metadata type="journal-subpart">
					<xsl:if test="dc:bibliographicCitation.volume">
						<xsl:text>Vol. </xsl:text>
						<xsl:value-of select="dc:bibliographicCitation.volume"/>
					</xsl:if>
					<xsl:if test="dc:bibliographicCitation.issue">
						<xsl:text>, No. </xsl:text>
						<xsl:value-of select="dc:bibliographicCitation.issue"/>
					</xsl:if>
					<xsl:if test="dc:date.issued">
						<xsl:text> (</xsl:text>
						<xsl:value-of select="dc:date.issued"/>
						<xsl:text>)</xsl:text>
					</xsl:if>
					<xsl:if test="dc:bibliographicCitation.firstPage">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="dc:bibliographicCitation.firstPage"/>
						<xsl:if test="dc:bibliographicCitation.lastPage">
							<xsl:text>-</xsl:text>
							<xsl:value-of select="dc:bibliographicCitation.lastPage"/>
						</xsl:if>
					</xsl:if>
				</pz:metadata>
			</xsl:if>

			<xsl:for-each select="dc:bibliographicCitation.volume">
				<pz:metadata type="journal-volume">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:bibliographicCitation.issue">
				<pz:metadata type="journal-issue">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:if test="dc:bibliographicCitation.firstPage | dc:bibliographicCitation.lastPage">
				<pz:metadata type="journal-pages">
					<xsl:value-of select="dc:bibliographicCitation.firstPage"/>
					<xsl:text>-</xsl:text>
					<xsl:value-of select="dc:bibliographicCitation.lastPage"/>
				</pz:metadata>
			</xsl:if>

			<xsl:for-each select="dc:identifier.uri">
				<pz:metadata type="catalogue-url">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:identifier.doi">
				<pz:metadata type="doi">
					<xsl:value-of select="."/>
				</pz:metadata>
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

			<xsl:for-each select="dc:type.version">
				<pz:metadata type="description">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:description.abstract">
				<pz:metadata type="abstract">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<!--
				Determine the main filename from the last dc:description.provenance field à la:

					Made available in DSpace on 2010-10-28T18:46:49Z (GMT). No. of bitstreams: 1
					1.pdf: 933573 bytes, checksum: f2161ec553cdba3f3c91cffaaa885f74 (MD5)
					0306.pdf: 4862284 bytes, checksum: 969cf5ee5ece8f44148f15d629b6c758 (MD5)
					Previous issue date: 2003
				
				* recognise file lines by '(MD5)' at their end
				* assume file names do not contain a colon and use everything before the first ': ' as the file name 

				Emit the file names in the pz:metadata fields of type dspace-filename for postprocessing
					where the URL to the document is assembled based on the server used.
			-->
			<xsl:for-each select="dc:description.provenance">
				<xsl:if test="position()=last()">
				 	<xsl:call-template name="fileinfolines">
						<xsl:with-param name="str" select="."/>
 					</xsl:call-template>
				</xsl:if>
			</xsl:for-each>


			<xsl:for-each select="dc:language.iso">
				<pz:metadata type="language">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:type">
				<pz:metadata type="medium">
					<xsl:choose>
						<xsl:when test=".='book' or .='bookPart' or .='doctoralThesis'">
							<xsl:text>book</xsl:text>
						</xsl:when>
						<xsl:when test=".='article' or .='lecture' or .='workingPaper'">
							<xsl:text>article</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>electronic</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:subject">
				<xsl:call-template name="splitter">
					<xsl:with-param name="list" select="."/>
					<xsl:with-param name="separator" select="'; '"/>
					<xsl:with-param name="metadataType">subject</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>

		</pz:record>
	</xsl:template>

	
	<!--
		Template for:
		1. splitting up text into its lines,
		2. keeping the ones that end in (MD5)
		3. an wrapping them in a pz:metadata tag of type dspace-filename
		Used from the template for dc:description.provenance to find the lines with the file names.
	-->
	<xsl:template name="fileinfolines">
		<xsl:param name="str"/>
		<xsl:if test="substring($str, string-length(substring-before($str, '&#xa;')) - 4, 5) = '(MD5)'">
			<pz:metadata type="dspace-filename">
				<xsl:value-of select="substring-before(substring-before($str, '&#xa;'), ':')"/>
			</pz:metadata>
		</xsl:if>
		<xsl:if test="contains($str, '&#xa;')">
			<xsl:call-template name="fileinfolines">
				<xsl:with-param name="str" select="substring-after($str,'&#xa;')"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	
	
	<!-- Kill stray text -->
	<xsl:template match="text()"/>

</xsl:stylesheet>
