<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="json tei">
    
    <!-- Achtung, Orte ohne genaue Angabe @type='coords' sind gerade herausgefiltert -->
    
    <!-- Output format: plain text -->
    <xsl:output method="text" indent="yes" />
    <xsl:mode on-no-match="shallow-skip"/>
    
    <!-- Root template to start the GeoJSON output -->
    <xsl:template match="tei:TEI">
        <xsl:text>{</xsl:text>
        <xsl:text>&#10;  "type": "FeatureCollection",</xsl:text>
        <xsl:text>&#10;  "features": [</xsl:text>
        <xsl:apply-templates select="descendant::tei:listPlace"/>
        <xsl:text>&#10;  ]</xsl:text>
        <xsl:text>&#10;}</xsl:text>
    </xsl:template>
    
    <!-- Template to process each listPlace -->
    <xsl:template match="tei:listPlace[descendant::tei:place/tei:location[@type='coords']/tei:geo]">
        <!-- Add a comma before every feature except the first one -->
        <xsl:if test="position() > 1"><xsl:text>,</xsl:text></xsl:if>
        
        <xsl:text>&#10;    {</xsl:text>
        <xsl:text>&#10;      "type": "Feature",</xsl:text>
        
        <!-- Check if there is only one place or multiple places in the listPlace -->
        <xsl:choose>
            <!-- If there's only one place, create a Point -->
            <xsl:when test="count(tei:place[descendant::tei:location[@type='coords']/tei:geo]) = 1">
                <xsl:text>&#10;      "geometry": {</xsl:text>
                <xsl:text>&#10;        "type": "Point",</xsl:text>
                <xsl:text>&#10;        "coordinates": [</xsl:text>
                
                <!-- Get the coordinates for the single place -->
                <xsl:variable name="coords" select="tei:place/tei:location[@type='coords']/tei:geo"/>
                <xsl:variable name="lon" select="replace(substring-before($coords, ' '), ',', '.')"/>
                <xsl:variable name="lat" select="replace(substring-after($coords, ' '), ',', '.')"/>
                
                <xsl:text>&#10;          </xsl:text>
                <xsl:value-of select="$lon"/><xsl:text>, </xsl:text><xsl:value-of select="$lat"/>
                <xsl:text>&#10;        ]</xsl:text>
                <xsl:text>&#10;      },</xsl:text>
            </xsl:when>
            
            <!-- If there are multiple places, create a Polygon -->
            <xsl:otherwise>
                <xsl:text>&#10;      "geometry": {</xsl:text>
                <xsl:text>&#10;        "type": "Polygon",</xsl:text>
                <xsl:text>&#10;        "coordinates": [</xsl:text>
                <xsl:text>&#10;          [</xsl:text>
                
                <!-- Iterate over all places and get their coordinates -->
                <xsl:for-each select="tei:place[descendant::tei:location[@type='coords']/tei:geo]">
                    <xsl:variable name="coords" select="tei:location[@type='coords']/tei:geo"/>
                    <xsl:variable name="lon" select="replace(substring-before($coords, ' '), ',', '.')"/>
                    <xsl:variable name="lat" select="replace(substring-after($coords, ' '), ',', '.')"/>
                    
                    <xsl:if test="position() > 1"><xsl:text>, </xsl:text></xsl:if>
                    <xsl:text>&#10;            [</xsl:text><xsl:value-of select="$lon"/><xsl:text>, </xsl:text><xsl:value-of select="$lat"/><xsl:text>]</xsl:text>
                </xsl:for-each>
                
                <xsl:text>&#10;          ]</xsl:text>
                <xsl:text>&#10;        ]</xsl:text>
                <xsl:text>&#10;      },</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        
        <!-- Properties: Add place or listPlace name -->
        <xsl:text>&#10;      "properties": {</xsl:text>
        <xsl:text>&#10;        "name": "</xsl:text>
        <xsl:value-of select="tei:placeName"/>
        <xsl:text>"</xsl:text>
        <xsl:text>&#10;      }</xsl:text>
        <xsl:text>&#10;    }</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>
