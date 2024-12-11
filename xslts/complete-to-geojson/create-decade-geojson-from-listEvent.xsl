<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:mam="whatever"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="json tei">
    <!-- Output format: plain text -->
    <xsl:output method="text" indent="yes"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:import href="./partial/geoJSON-punkt.xsl"/>
    <!-- Root template to start processing and generate output for each decade -->
    <xsl:template match="/">
        <!-- Schleife über Dekaden -->
        <xsl:variable name="listPlaceGesamt" select="descendant::tei:body/tei:listPlace" as="node()"/>
        <xsl:for-each select="1870 to 1929">
            <!-- Nur jede 10 Jahre (Start der Dekade) verwenden -->
            <xsl:if test=". mod 10 = 0">
                <xsl:variable name="start-decade" select="string(.)" as="xs:string"/>
                <xsl:variable name="end-decade" select="string(. + 9)" as="xs:string"/>
                <xsl:variable name="decade-label" select="concat($start-decade, '-', $end-decade)" as="xs:string"/>
                <!-- Erstellen der GeoJSON-Datei -->
                <xsl:result-document href="../../../data/editions/geojson/{$decade-label}.geojson"
                    method="text">
                    <xsl:text>{</xsl:text>
                    <xsl:text>&#10;  "type": "FeatureCollection",</xsl:text>
                    <xsl:text>&#10;  "features": [</xsl:text>
                    <!-- Wiederherstellen des Kontexts und Filtern der passenden Events -->
                    <xsl:for-each
                        select="$listPlaceGesamt/tei:place[tei:location[@type='coords']/tei:geo and tei:listEvent[1]/tei:event[number(substring(@when, 1, 4)) >= number($start-decade) and number(substring(@when, 1, 4)) &lt;= number($end-decade)]]">
                       <xsl:value-of select="mam:macht-punkt(., 'decade', $start-decade, $end-decade)"/>
                        <xsl:if test="not(position() = last())">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:text>&#10;  ]</xsl:text>
                    <xsl:text>&#10;}</xsl:text>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    
</xsl:stylesheet>
