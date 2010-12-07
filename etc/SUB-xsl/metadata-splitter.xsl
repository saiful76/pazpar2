<?xml version="1.0" encoding="UTF-8"?>
<!--
	Template for splitting up a string and putting each component into a 
		<pz:metadata type="subject">-tag.

	Parameters:	* list - string with the list of components
				* separator - string used as separator
				* metadataType - string used as type attribute for pz:metadata element
		
	December 2010
	Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0">


	<xsl:template name="splitter">
		<xsl:param name="list"/>
		<xsl:param name="separator"/>
		<xsl:param name="metadataType"/>

		<xsl:variable name="firstItem">
			<xsl:choose>
				<xsl:when test="contains($list, $separator)">
					<xsl:value-of select="normalize-space(substring-before($list, $separator))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$list"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="remainingItems" select="substring-after($list, $separator)"/>
		
		
		<xsl:if test="$firstItem">
			<pz:metadata>
				<xsl:attribute name="type">
					<xsl:value-of select="$metadataType"/>
				</xsl:attribute>
				<xsl:value-of select="$firstItem"/>
			</pz:metadata>
		</xsl:if>
		
		<xsl:if test="$remainingItems">
			<xsl:call-template name="splitter">
				<xsl:with-param name="list" select="$remainingItems"/>
				<xsl:with-param name="separator" select="$separator"/>
				<xsl:with-param name="metadataType" select="$metadataType"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	
</xsl:stylesheet>
