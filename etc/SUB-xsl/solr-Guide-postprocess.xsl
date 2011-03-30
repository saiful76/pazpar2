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

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='Author']">
		<pz:metadata type="author">
			<xsl:value-of select="." />
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='Description']">
		<pz:metadata type="description">
			<xsl:value-of select="." />
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='Language']">
		<pz:metadata type="language">
			<xsl:value-of select="." />
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='Level']">
		<pz:metadata type="description">
			<xsl:value-of select="." />
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='MSCverbal']">
		<pz:metadata type="subject">
			<xsl:value-of select="." />
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='Title']">
		<pz:metadata type="title">
			<xsl:value-of select="." />
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='URI']">
		<pz:metadata type="electronic-url">
			<xsl:value-of select="." />
		</pz:metadata>
	</xsl:template>



	<!--
		Right now, all data we have are articles. 
		This needs to be extended once we have more data types.
	-->
	<xsl:template match="pz:metadata[@type='Format']">
		<pz:metadata type="medium">website</pz:metadata>
	</xsl:template>


</xsl:stylesheet>
