<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mam="whatever"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="json tei">
    <!-- Output format: plain text -->
    <xsl:output method="text" indent="yes"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:import href="./partial/geoJSON-punkt.xsl"/>
    <!-- Root template to start processing and generate output for each month -->
    <xsl:template match="/">
        <!-- Schleife über Jahre -->
        <xsl:variable name="listPlaceGesamt" select="descendant::tei:body/tei:listPlace" as="node()"/>
        <xsl:for-each select="1872 to 1931">
            <xsl:variable name="year" select="string(.)" as="xs:string"/>
            <!-- Schleife über Monate -->
            <xsl:for-each select="1 to 12">
                <xsl:variable name="month" select="format-number(., '00')" as="xs:string"/>
                <xsl:variable name="year-month" select="concat($year, '-', $month)"/>
                <!-- Erstellen der GeoJSON-Datei -->
                <xsl:result-document href="../../data/editions/geojson/{$year-month}.geojson"
                    method="text">
                    <xsl:text>{</xsl:text>
                    <xsl:text>&#10;  "type": "FeatureCollection",</xsl:text>
                    <xsl:text>&#10;  "features": [</xsl:text>
                    <!-- Wiederherstellen des Kontexts und Filtern der passenden Events -->
                    <xsl:for-each
                        select="$listPlaceGesamt/tei:place[tei:location[@type='coords']/tei:geo and tei:listEvent[1]/tei:event[starts-with(@when, $year-month)][1]]">
                        <xsl:value-of select="mam:macht-punkt(., 'month', $year-month, $year-month)"/>
                        <xsl:if test="not(position() = last())">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:text>&#10;  ]</xsl:text>
                    <xsl:text>&#10;}</xsl:text>
                </xsl:result-document>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
