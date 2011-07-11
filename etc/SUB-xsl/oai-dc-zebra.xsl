<?xml version="1.0" encoding="UTF-8"?>
<!--

	This stylesheet expects oai/dc records
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/">
	
	<xsl:import href="metadata-splitter.xsl"/>
	<xsl:import href="iso-639-1-to-639-2b.xsl"/>
	
	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<xsl:template match="/record/metadata/oai_dc:dc">
		<pz:record>
			<pz:metadata type="id">
				<xsl:value-of select="../../header/identifier"/>
			</pz:metadata>

			<xsl:for-each select="dc:title">
				<pz:metadata type="title">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:date">
				<pz:metadata type="date">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:subject">
				<xsl:call-template name="splitter">
					<xsl:with-param name="list" select="."/>
					<xsl:with-param name="separator">; </xsl:with-param>
					<xsl:with-param name="metadataType">subject</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>

			<xsl:for-each select="dc:creator">
				<pz:metadata type="author">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:description">
				<pz:metadata type="description">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:publisher">
				<pz:metadata type="publication-name">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dc:identifier">
				<xsl:if test="substring(., 1, 4) = 'http' or substring(., 1, 3) = 'ftp'">
					<pz:metadata type="electronic-url">
						<xsl:value-of select="."/>
					</pz:metadata>
				</xsl:if>
			</xsl:for-each>

			<xsl:for-each select="dc:language">
				<pz:metadata type="language">
					<xsl:call-template name="languageCodeConverter">
						<xsl:with-param name="languageCode" select="."/>
					</xsl:call-template>
				</pz:metadata>
			</xsl:for-each>

			<!-- 
				Try to normalise media types to our standard set.
			-->
			<xsl:for-each select="dc:type">
				<pz:metadata type="medium">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>

			<xsl:for-each select="dcterms:bibliographicCitation">
				<pz:metadata type="citation">
					<xsl:value-of select="."/>
				</pz:metadata>
			</xsl:for-each>
		</pz:record>
	</xsl:template>

	<xsl:template match="text()"/>

</xsl:stylesheet>
