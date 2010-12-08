<?xml version="1.0" encoding="UTF-8"?>
<!--
	Takes the pz:metadata language element and tries to ensure we are using 
		ISO 639-2/B language codes consistently by
			- replacing deprecated ISO 639-2 codes by their successors (if possible)
			- replacing ISO 639-2/T codes by their ISO 639-2/B counterparts
	
	Infos:
		* https://wiki.sub.uni-goettingen.de/dbservices/index.php/User:Porst/Sprachcodes
		* http://www.loc.gov/standards/iso639-2/ascii_8bits.html
		* http://www.loc.gov/marc/languages/
		* http://www.loc.gov/marc/languages/language_code.html
		
	December 2010
	Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
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


	<xsl:template match="pz:metadata[@type='language']">
		<pz:metadata type="language">
			<xsl:choose>
				<!-- Ensure we have ISO 639-2/B language codes -->
				<xsl:when test=".='sqi'">alb</xsl:when>
				<xsl:when test=".='hye'">arm</xsl:when>
				<xsl:when test=".='eus'">baq</xsl:when>
				<xsl:when test=".='mya'">bur</xsl:when>
				<xsl:when test=".='zho'">chi</xsl:when>
				<xsl:when test=".='ces'">cze</xsl:when>
				<xsl:when test=".='nld'">dut</xsl:when>
				<xsl:when test=".='fra'">fre</xsl:when>
				<xsl:when test=".='kat'">geo</xsl:when>
				<xsl:when test=".='deu'">ger</xsl:when>
				<xsl:when test=".='ell'">gre</xsl:when>
				<xsl:when test=".='isl'">ice</xsl:when>
				<xsl:when test=".='mkd'">mac</xsl:when>
				<xsl:when test=".='mri'">mao</xsl:when>
				<xsl:when test=".='msa'">may</xsl:when>
				<xsl:when test=".='fas'">per</xsl:when>
				<xsl:when test=".='ron'">rum</xsl:when>
				<xsl:when test=".='slk'">slo</xsl:when>
				<xsl:when test=".='bod'">tib</xsl:when>
				<xsl:when test=".='cym'">wel</xsl:when>
			
				<!-- Replace deprecated ISO 639-2 language codes with current versions -->
				<xsl:when test=".='esk'">kal</xsl:when>
				<xsl:when test=".='esp'">epo</xsl:when>
				<xsl:when test=".='eth'">gez</xsl:when>
				<xsl:when test=".='far'">fao</xsl:when>
				<xsl:when test=".='gae'">gla</xsl:when>
				<xsl:when test=".='gag'">glg</xsl:when>
				<xsl:when test=".='iri'">gle</xsl:when>
				<xsl:when test=".='cam'">khm</xsl:when>
				<xsl:when test=".='mla'">mlg</xsl:when>
				<xsl:when test=".='max'">glv</xsl:when>
				<xsl:when test=".='lan'">oci</xsl:when>
				<xsl:when test=".='gal'">orm</xsl:when>
				<xsl:when test=".='lap'">smi</xsl:when>
				<xsl:when test=".='sao'">smo</xsl:when>
				<xsl:when test=".='sho'">sna</xsl:when>
				<xsl:when test=".='scc'">srp</xsl:when>
				<xsl:when test=".='snh'">sin</xsl:when>
				<xsl:when test=".='swz'">ssw</xsl:when>
				<xsl:when test=".='taj'">tgk</xsl:when>
				<xsl:when test=".='tag'">tgl</xsl:when>
				<xsl:when test=".='tar'">tat</xsl:when>
				<xsl:when test=".='tsw'">tsn</xsl:when>
				<!-- The potentially non-unique cases. May be better left out -->
				<xsl:when test=".='sso'">sot</xsl:when>
				<xsl:when test=".='fri'">frr</xsl:when>
				
				<!-- Without a match, keep the existing language code -->
				<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
			</xsl:choose>
		</pz:metadata>
	</xsl:template>

</xsl:stylesheet>
