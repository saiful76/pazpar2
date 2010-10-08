<?xml version="1.0" encoding="UTF-8"?>
<!--
	Converts MarcXML to TurboMarc
		(to benefit from pazpar2's improved tmarc.xsl)

	October 2010
	Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:srw="http://www.loc.gov/zing/srw/"
	xmlns:tmarc="http://www.indexdata.com/turbomarc">

<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>


<xsl:template match="record">
	<xsl:element name="tmarc:r">
		<xsl:apply-templates select="@*|node()"/>
	</xsl:element>
</xsl:template>


<xsl:template match="leader">
	<xsl:element name="tmarc:l">
		<xsl:apply-templates select="@*|node()"/>
	</xsl:element>
</xsl:template>

<xsl:template match="controlfield|datafield|subfield">
	<!--
		Try to mock Indexdata's specification without regexps:
		Translate all allowed characters to 'a' and assume field names are
		shorter than 62 characters.
		Given the typical 3 digit Marc field numbers this seems
		safe in the practical cases I have seen.

		http://www.indexdata.com/blog/2010/05/turbomarc-faster-xml-marc-records
		http://www.indexdata.com/yaz/doc/marc.html
	-->

	<xsl:variable name="allowedCharacters" select="'0123465789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:variable name="manyAs" select="'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'"/>

	<xsl:choose>
		<xsl:when test="( name(.)='datafield' or name(.)='controlfield') and
						contains($manyAs, translate(@tag, $allowedCharacters, $manyAs))">
		<xsl:element name="{concat('tmarc:', substring(local-name(),1,1), @tag)}">
				<xsl:apply-templates select="@*[name(.)!='tag']|node()"/>
			</xsl:element>
		</xsl:when>

		<xsl:when test="name(.)='subfield' and
						contains($manyAs, translate(@code, $allowedCharacters, $manyAs))">
			<xsl:element name="{concat('tmarc:', substring(local-name(),1,1), @code)}">
				<xsl:apply-templates select="@*[name(.)!='code']|node()"/>
			</xsl:element>
		</xsl:when>

		<xsl:otherwise>
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


</xsl:stylesheet>