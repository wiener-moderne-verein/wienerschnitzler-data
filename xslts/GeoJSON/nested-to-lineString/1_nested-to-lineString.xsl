<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="tei">
    <xsl:output method="xml" encoding="UTF-8"/>
    <!-- Parameter, der das externe listplace-Dokument enthält -->
    <xsl:param name="listplace-doc" select="document('../../../data/indices/listplace.xml')"/>
    <!-- Key, um in der externen Datei per @xml:id auf tei:place zuzugreifen -->
    <xsl:key name="listplace-match" match="tei:place" use="@xml:id"/>
    <!-- plätze ohne lat/lon weg -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="true"/>
    <xsl:template match="tei:place[not(child::tei:listPlace)]">
        <xsl:variable name="placeID" select="substring-after(@corresp, '#')"/>
        <!-- Den passenden Ort im externen Dokument holen -->
        <xsl:variable name="placeNode" select="key('listplace-match', $placeID, $listplace-doc)"/>
        <!-- Annahme: Die Koordinaten stehen im tei:geo-Element unter tei:location[@type='coords'] -->
        <xsl:choose>
            <xsl:when test="$placeNode/tei:location[@type = 'coords']">
                <xsl:copy-of select="."/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
