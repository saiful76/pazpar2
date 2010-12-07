<?xml version="1.0" encoding="UTF-8"?>
<!--
	Converts the odd full text languages found in JfM records to ISO 639-2 codes.
		Only use the first language found in the string.
		
	See infos/jfm-language-values.xml for a list of values in the database.
	
	December 2010
	Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->

<xsl:stylesheet
		version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="la">
		<xsl:variable name="languageString">
			<xsl:value-of select="substring-before( 
									translate( concat(normalize-space(.), ' '), 
												',;/?.3', 
												'      '), 
									' ')"/>
		</xsl:variable>

		<xsl:variable name="languageCode">
			<xsl:choose>
				<xsl:when test="$languageString = 'Arabic'">ara</xsl:when>
				<xsl:when test="$languageString = 'Belgian'">dut</xsl:when>
				<xsl:when test="$languageString = 'Bulgarian'">bul</xsl:when>
				<xsl:when test="$languageString = 'Catalan'">cat</xsl:when>
				<xsl:when test="$languageString = 'Chinese'">chi</xsl:when>
				<xsl:when test="$languageString = 'Croatian'">hrv</xsl:when>
				<xsl:when test="$languageString = 'Czech'">cze</xsl:when>
				<xsl:when test="$languageString = 'Danish'">dan</xsl:when>
				<xsl:when test="$languageString = 'Dutch'">dut</xsl:when>
				<xsl:when test="$languageString = 'English'">eng</xsl:when>
				<xsl:when test="$languageString = 'english'">eng</xsl:when>
				<xsl:when test="$languageString = 'Esperanto'">epo</xsl:when>
				<xsl:when test="$languageString = 'Estonian'">est</xsl:when>
				<xsl:when test="$languageString = 'Finnish'">fin</xsl:when>
				<xsl:when test="$languageString = 'Flemish'">dut</xsl:when>
				<xsl:when test="$languageString = 'French'">fre</xsl:when>
				<xsl:when test="$languageString = 'Georgian'">geo</xsl:when>
				<xsl:when test="$languageString = 'German'">ger</xsl:when>
				<xsl:when test="$languageString = 'GERMAN'">ger</xsl:when>
				<xsl:when test="$languageString = 'Greek'">gre</xsl:when>
				<xsl:when test="$languageString = 'Hebrew'">heb</xsl:when>
				<xsl:when test="$languageString = 'Hungarian'">hun</xsl:when>
				<xsl:when test="$languageString = 'Interlingua'">ina</xsl:when>
				<xsl:when test="$languageString = 'Italian'">ita</xsl:when>
				<xsl:when test="$languageString = 'Japanese'">jpn</xsl:when>
				<xsl:when test="$languageString = 'Kroatian'">hrv</xsl:when>
				<xsl:when test="$languageString = 'Latin'">lat</xsl:when>
				<xsl:when test="$languageString = 'Latino'">lat</xsl:when>
				<xsl:when test="$languageString = 'Latvian'">lav</xsl:when>
				<xsl:when test="$languageString = 'Lithuanian'">lit</xsl:when>
				<xsl:when test="$languageString = 'New'">lat</xsl:when> <!-- New Latin -->
				<xsl:when test="$languageString = 'Norwegian'">nno</xsl:when>
				<xsl:when test="$languageString = 'Polish'">pol</xsl:when>
				<xsl:when test="$languageString = 'Portuguese'">por</xsl:when>
				<xsl:when test="$languageString = 'Potuguese'">por</xsl:when>
				<xsl:when test="$languageString = 'Romanian'">rum</xsl:when>
				<xsl:when test="$languageString = 'Russian'">rus</xsl:when>
				<xsl:when test="$languageString = 'RUSSIAN'">rus</xsl:when>
				<xsl:when test="$languageString = 'Sanscrit'">san</xsl:when>
				<xsl:when test="$languageString = 'Sanskrit'">san</xsl:when>
				<xsl:when test="$languageString = 'Serbian-Croatian'">srp</xsl:when>
				<xsl:when test="$languageString = 'Serbian'">srp</xsl:when>
				<xsl:when test="$languageString = 'Serbocroatian'">srp</xsl:when>
				<xsl:when test="$languageString = 'Serbo-croatian'">srp</xsl:when>
				<xsl:when test="$languageString = 'Serbo-Croatian'">srp</xsl:when>
				<xsl:when test="$languageString = 'Slovak'">slk</xsl:when>
				<xsl:when test="$languageString = 'Slovenian'">slv</xsl:when>
				<xsl:when test="$languageString = 'Spanish'">spa</xsl:when>
				<xsl:when test="$languageString = 'Swedish'">swe</xsl:when>
				<xsl:when test="$languageString = 'Ukrainian'">ukr</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$languageCode != ''">
			<la>
				<xsl:value-of select="$languageCode"/>
			</la>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
