<?xml version="1.0" encoding="UTF-8"?>
<!--
	Converts arXiv Dublin Core records for pazpar2.
	
	December 2010
	Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->

<xsl:stylesheet
		version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
		xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
		xmlns:dc="http://purl.org/dc/elements/1.1/">

	<xsl:import href="metadata-splitter.xsl"/>
	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<xsl:template match="/record/metadata/oai_dc:dc">
		<pz:record>

			<pz:metadata type="id">
				<xsl:value-of select="/record/header/identifier"/>
			</pz:metadata>

			<pz:metadata type="medium">
				<xsl:text>electronic</xsl:text>
			</pz:metadata>
			
			<xsl:for-each select="dc:title">
				<pz:metadata type="title">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:creator">
				<pz:metadata type="author">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<!-- There are two types of subjects in the data:
					1. Subject strings like 'Mathematics - Algebraic Geometry'
					2. MSC identifiers like '18E30, 13D15, 18G40'
				Pass 1. on unchanged. Split 2. at the ', '.
			-->
			<xsl:for-each select="dc:subject">
				<xsl:choose>
					<xsl:when test="translate(substring(., 1, 1), '0123456789', '**********') = '*'">
						<xsl:call-template name="splitter">
							<xsl:with-param name="separator" select="', '"/>
							<xsl:with-param name="list" select="." />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<pz:metadata type="subject">
							<xsl:value-of select="."/>
						</pz:metadata>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			
			<xsl:for-each select="dc:date">
				<pz:metadata type="date">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:description">
				<pz:metadata type="description">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:identifier|dc:identifier.url">
				<pz:metadata type="catalogue-url">
					<xsl:value-of select="."/>
				</pz:metadata>
				<xsl:if test="starts-with(., 'http://arxiv.org/abs')">
					<pz:metadata type="electronic-url" fulltextfile="yes">
						<xsl:text>http://arxiv.org/pdf</xsl:text>
						<xsl:value-of select="substring-after(., 'http://arxiv.org/abs')"/>
					</pz:metadata>
				</xsl:if>
			</xsl:for-each>

		</pz:record>
	</xsl:template>

	<!-- Kill stray text -->
	<xsl:template match="text()"/>

</xsl:stylesheet>
