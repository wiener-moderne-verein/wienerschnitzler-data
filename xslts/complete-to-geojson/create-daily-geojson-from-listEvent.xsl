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
        <!-- Gruppiere die Ereignisse nach Jahr und Monat -->
        <xsl:for-each-group select="/tei:TEI/descendant::tei:event[@when]" group-by="(substring(@when, 1, 7))">
            <!-- Hole Jahr und Monat aus dem Gruppierungsschlüssel -->
            <xsl:variable name="year-month" select="current-grouping-key()"/>
            <xsl:variable name="year" select="substring($year-month, 1, 4)"/>
            <xsl:variable name="month" select="substring($year-month, 6, 2)"/>
            <!-- Benenne die GeoJSON-Datei nach Jahr und Monat -->
            <xsl:result-document href="../../editions/geojson/month/{$year}-{$month}.geojson" method="text">
                <xsl:text>{</xsl:text>
                <xsl:text>&#10;  "type": "FeatureCollection",</xsl:text>
                <xsl:text>&#10;  "features": [</xsl:text>
                <!-- Verarbeite alle Ereignisse in der aktuellen Gruppe -->
                <xsl:for-each select="current-group()">
                    <!-- Füge für jedes Feature entweder einen Punkt oder eine Linie hinzu -->
                    <xsl:apply-templates select="descendant::tei:listPlace" mode="linestring"/>
                    <xsl:for-each select="tei:listPlace[descendant::tei:place/tei:location[@type = 'coords']/tei:geo]">
                        <xsl:apply-templates mode="point"/>
                        <xsl:if test="not(position() = last() or current-group()/tei:listPlace[descendant::tei:place/tei:location[@type = 'coords']/tei:geo])">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:text>&#10;  ]</xsl:text>
                <xsl:text>&#10;}</xsl:text>
            </xsl:result-document>
        </xsl:for-each-group>
    </xsl:template>
    
    <!-- Templates für Points und Linestrings -->
    <xsl:template match="tei:place[tei:location[@type = 'coords']/tei:geo]" mode="point">
        <xsl:text>&#10;    {</xsl:text>
        <xsl:text>&#10;      "type": "Feature",</xsl:text>
        <xsl:text>&#10;      "geometry": {</xsl:text>
        <xsl:text>&#10;        "type": "Point",</xsl:text>
        <xsl:text>&#10;        "coordinates": [</xsl:text>
        <xsl:variable name="coords" select="tei:location[@type = 'coords']/tei:geo"/>
        <xsl:variable name="lat" select="replace(substring-before($coords, ' '), ',', '.')"/>
        <xsl:variable name="lon" select="replace(substring-after($coords, ' '), ',', '.')"/>
        <xsl:text>&#10;          </xsl:text>
        <xsl:value-of select="$lon"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$lat"/>
        <xsl:text>&#10;        ]</xsl:text>
        <xsl:text>&#10;      },</xsl:text>
        <xsl:text>&#10;      "properties": {</xsl:text>
        <xsl:text>&#10;         "title": "</xsl:text>
        <xsl:value-of select="tei:placeName[1]"/>
        <xsl:text>"</xsl:text>
        <xsl:text>&#10;      }</xsl:text>
        <xsl:text>&#10;    }</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:listPlace[descendant::tei:place/tei:location[@type = 'coords']/tei:geo]" mode="linestring">
        <xsl:text>&#10;    {</xsl:text>
        <xsl:text>&#10;      "type": "Feature",</xsl:text>
        <xsl:text>&#10;      "geometry": {</xsl:text>
        <xsl:text>&#10;        "type": "LineString",</xsl:text>
        <xsl:text>&#10;        "coordinates": [</xsl:text>
        <!-- Die Koordinaten für die Linien -->
        <xsl:for-each select="tei:place[tei:location[@type = 'coords']/tei:geo]">
            <xsl:if test="position() > 1">
                <xsl:text>,</xsl:text>
            </xsl:if>
            <xsl:text>&#10;          [</xsl:text>
            <xsl:variable name="coords" select="tei:location[@type = 'coords']/tei:geo"/>
            <xsl:variable name="lat" select="replace(substring-before($coords, ' '), ',', '.')"/>
            <xsl:variable name="lon" select="replace(substring-after($coords, ' '), ',', '.')"/>
            <xsl:value-of select="$lon"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$lat"/>
            <xsl:text>]</xsl:text>
        </xsl:for-each>
        <xsl:text>&#10;        ]</xsl:text>
        <xsl:text>&#10;      }</xsl:text>
        <xsl:text>&#10;    }</xsl:text>
    </xsl:template>
</xsl:stylesheet>
