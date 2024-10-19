<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="json tei">
    
    <!-- Output format: plain text -->
    <xsl:output method="text" indent="yes" />
    <xsl:mode on-no-match="shallow-skip"/>
    
    <!-- Root template to start the GeoJSON output -->
    <xsl:template match="tei:TEI">
        <xsl:text>{</xsl:text>
        <xsl:text>&#10;  "type": "FeatureCollection",</xsl:text>
        <xsl:text>&#10;  "features": [</xsl:text>
        <xsl:for-each select="descendant::tei:place[tei:location[@type='coords']/tei:geo]">
            <xsl:apply-templates select="."/>
            <xsl:if test="position() != last()">
                <xsl:text>,</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>&#10;  ]</xsl:text>
        <xsl:text>&#10;}</xsl:text>
    </xsl:template>
    
    <!-- Template to process each listPlace -->
    <xsl:template match="tei:place[tei:location[@type='coords']/tei:geo]">
        <xsl:variable name="datum-ohne-strich" select="replace(ancestor::tei:event/@when, '-', '')"/>
        
            <!-- Add a comma before every feature except the first one -->
            <xsl:text>&#10;    {</xsl:text>
            <xsl:text>&#10;      "type": "Feature",</xsl:text>
            <xsl:text>&#10;      "geometry": {</xsl:text>
            <xsl:text>&#10;        "type": "Point",</xsl:text>
            <xsl:text>&#10;        "coordinates": [</xsl:text>
            <xsl:variable name="coords" select="descendant::tei:location[@type = 'coords']/tei:geo"/>
            <xsl:variable name="lat" select="replace(substring-before($coords, ' '), ',', '.')"/>
            <xsl:variable name="lon" select="replace(substring-after($coords, ' '), ',', '.')"/>
            <!-- Correct order: longitude, latitude -->
            <xsl:text>&#10;          </xsl:text>
            <xsl:value-of select="concat($lon, $datum-ohne-strich)"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="concat($lat, $datum-ohne-strich)"/>
            <xsl:text>&#10;        ]</xsl:text>
            <xsl:text>&#10;      },</xsl:text>
            <xsl:text>&#10;      "properties": {</xsl:text>
            <xsl:text>&#10;         "title": "</xsl:text>
            <xsl:value-of select="tei:placeName[1]"/>
            <xsl:text>"</xsl:text>
            <xsl:text>&#10;      }</xsl:text>
            <xsl:text>&#10;      }</xsl:text>
            
        
    </xsl:template>
    
</xsl:stylesheet>
