<?xml version="1.0" encoding="UTF-8"?>
<!--
	Post-processes solr records coming from the ssgfi1 server after
	they are processed by solr-pz2.xsl.
	
	2011 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->

<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0">
	
	<xsl:import href="iso-639-1-to-639-2b.xsl"/>
	
	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<!-- Set media type to website for all records -->
	<xsl:template match="pz:record">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<pz:metadata type="medium">website</pz:metadata>
		</xsl:copy>
	</xsl:template>


	<!--
		Possibly 3 fields in our Solr data:
			1. Author: site owner -> author
			2. Editor: -> other-person
			2. Publisher: (institutional site owner) -> title-responsibility
			3. Distributor: (only in old records) -> ignored
			4. Autor: metadata author -> ignored
	-->
	<xsl:template match="pz:metadata[@type='Author']">
		<pz:metadata type="author">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='Publisher']">
		<pz:metadata type="title-responsibility">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='Editor']">
		<pz:metadata type="other-person">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>



	<!--
		Site information, all mapped to description. Use data from fields:
			1. Description
			2. Notes
	-->
	<xsl:template match="pz:metadata[@type='Description']">
		<pz:metadata type="description">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='Notes']">
		<pz:metadata type="description">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>


	<xsl:template match="pz:metadata[@type='MSCverbal']">
		<pz:metadata type="subject">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='Title']">
		<pz:metadata type="title">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='URL']">
		<pz:metadata type="electronic-url">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='DDC']">
		<pz:metadata type="ddc">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='Keywords']">
		<pz:metadata type="subject">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='LCSH']">
		<pz:metadata type="subject">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<!-- 
		Call languageCodeConverter template from iso-639-1-to-639-2b.xsl.
		Use the first two characters of the field content only.
	-->
	<xsl:template match="pz:metadata[@type='Language']">
		<pz:metadata type="language">
			<xsl:call-template name="languageCodeConverter">
				<xsl:with-param name="languageCode" select="substring(., 1, 2)"/>
			</xsl:call-template>
		</pz:metadata>
	</xsl:template>
	
	
</xsl:stylesheet>
