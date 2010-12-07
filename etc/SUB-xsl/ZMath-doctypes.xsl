<?xml version="1.0" encoding="UTF-8"?>
<!--
	Converts <dt> type information from Zentralblatt Math (and related) records 
		to pazpar2 media type names. Zentralblatt Math Documentation is scarce. 
		We mark everything that isn't a book as an article.
		
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


	<xsl:template match="dt">
		<xsl:variable name="doctype" 
			select="translate( substring( normalize-space(.), 1, 1), 'bjx', 'BJX' )"/>

		<xsl:variable name="doctypeString">
		<!--
				Documentation at http://www.zentralblatt-math.org/zbmath/advanced/
				suggests that valid values are
					j: journal article, b: book, a: book article
				At least in JfM data (infos/jfm-doctype-values.xml) the values 
					ABCDHJNPRSX 
				appear (plus a few variations). 					
				Map everything except 'B' to 'article'.
		-->
			<xsl:choose>
				<xsl:when test="$doctype = 'B'">book</xsl:when>
				<xsl:otherwise>article</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$doctypeString != ''">
			<dt>
				<xsl:value-of select="$doctypeString"/>
			</dt>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
