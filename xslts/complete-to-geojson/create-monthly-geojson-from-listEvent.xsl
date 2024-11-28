<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="json tei">
    <!-- Output format: plain text -->
    <xsl:output method="text" indent="yes"/>
    <xsl:mode on-no-match="shallow-skip"/>
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
                <xsl:result-document href="../../editions/geojson/{$year-month}.geojson"
                    method="text">
                    <xsl:text>{</xsl:text>
                    <xsl:text>&#10;  "type": "FeatureCollection",</xsl:text>
                    <xsl:text>&#10;  "features": [</xsl:text>
                    <!-- Wiederherstellen des Kontexts und Filtern der passenden Events -->
                    <xsl:for-each
                        select="$listPlaceGesamt/tei:place[tei:location[@type='coords']/tei:geo and tei:listEvent[1]/tei:event[starts-with(@when, $year-month)][1]]">
                        <xsl:variable name="coords"
                            select="descendant::tei:location[@type = 'coords']/tei:geo"/>
                        <xsl:variable name="lat"
                            select="replace(substring-before($coords, ' '), ',', '.')"/>
                        <xsl:variable name="lon"
                            select="replace(substring-after($coords, ' '), ',', '.')"/>
                        <xsl:text>&#10;    {</xsl:text>
                        <xsl:text>&#10;      "type": "Feature",</xsl:text>
                        <xsl:text>&#10;      "geometry": {</xsl:text>
                        <xsl:text>&#10;        "type": "Point",</xsl:text>
                        <xsl:text>&#10;        "coordinates": [</xsl:text>
                        <xsl:value-of select="$lon"/>
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="$lat"/>
                        <xsl:text>]</xsl:text>
                        <xsl:text>&#10;      },</xsl:text>
                        <!-- Properties section with title and aggregated visit dates -->
                        <xsl:text>&#10;      "properties": {</xsl:text>
                        <xsl:text>&#10;         "id": "</xsl:text>
                        <xsl:value-of
                            select="concat('pmb', replace(replace(tei:idno[@subtype = 'pmb'][1], 'https://pmb.acdh.oeaw.ac.at/entity/', ''), '/', ''))"/>
                        <xsl:text>",</xsl:text>
                        <xsl:text>&#10;         "title": "</xsl:text>
                        <xsl:value-of select="tei:placeName[1]"/>
                        <xsl:text>",</xsl:text>
                        <xsl:text>&#10;         "lat": "</xsl:text>
                        <xsl:value-of select="$lat"/>
                        <xsl:text>",</xsl:text>
                        <xsl:text>&#10;         "lon": "</xsl:text>
                        <xsl:value-of select="$lon"/>
                        <xsl:text>",</xsl:text>
                        <!-- Aggregate visit dates for the current location -->
                        <xsl:text>&#10;         "timestamp": [</xsl:text>
                        <xsl:for-each
                            select="tei:listEvent/tei:event/@when[starts-with(., $year-month)]">
                            <xsl:text>"</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>"</xsl:text>
                            <xsl:if test="position() != last()">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text>],</xsl:text>
                        <!-- Aggregate event descriptions -->
                        <xsl:text>&#10;         "importance": "</xsl:text>
                        <xsl:value-of
                            select="count(descendant::tei:listEvent/tei:event[@when[starts-with(., $year-month)]])"/>
                        <xsl:text>"</xsl:text>
                        <xsl:text>&#10;      }</xsl:text>
                        <xsl:text>&#10;      }</xsl:text>
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
