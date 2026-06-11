<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mam="whatever"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="json tei">
    <!-- Output format: JSON (minified) -->
    <xsl:output method="json"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:import href="./partial/geoJSON-punkt.xsl"/>
    <xsl:param name="listplace" select="document('../../data/indices/listplace.xml')"/>
    <xsl:key name="listplace-lookup"
        match="tei:TEI/tei:text[1]/tei:body[1]/tei:listPlace[1]/tei:place" use="@xml:id"/>
    <!-- Root template to generate the entire GeoJSON output -->
    <xsl:template match="/">
        <!-- Process all places with coordinates and events -->
        <xsl:variable name="listPlaceGesamt" select="descendant::tei:body/tei:listPlace" as="node()"/>
        <xsl:variable name="features" as="map(*)*">
            <xsl:for-each
                select="$listPlaceGesamt/tei:place[mam:koordinaten-vorhanden(@xml:id) and tei:listEvent[1]/tei:event]">
                <xsl:variable name="place" as="node()">
                    <xsl:element name="tei:place">
                        <xsl:copy-of select="key('listplace-lookup', @xml:id, $listplace)/@*"/>
                        <xsl:copy-of select="key('listplace-lookup', @xml:id, $listplace)/*"/>
                        <xsl:copy-of select="tei:listEvent"/>
                    </xsl:element>
                </xsl:variable>
                <xsl:sequence select="mam:macht-punkt($place, 'complete', '', '')"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence
            select="map { 'type': 'FeatureCollection', 'features': array { $features } }"/>
    </xsl:template>
    <!-- Function to check if coordinates are present -->
    <xsl:function name="mam:koordinaten-vorhanden" as="xs:boolean">
        <xsl:param name="corresp" as="xs:string"/>
        <xsl:variable name="corresp-clean" as="xs:string"
            select="concat('pmb', replace(replace($corresp, '#', ''), 'pmb', ''))"/>
        <xsl:variable name="lookup" select="key('listplace-lookup', $corresp-clean, $listplace)"
            as="node()?"/>
        <xsl:choose>
            <xsl:when
                test="$lookup/tei:location[@type = 'coords'][1]/tei:geo[not(normalize-space(.) = '')]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
