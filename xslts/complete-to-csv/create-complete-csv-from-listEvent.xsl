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
        <xsl:text>latitude,longitude,height&#10;</xsl:text>
        <!-- Group places by coordinates to merge duplicate locations -->
        <xsl:for-each select="descendant::tei:place[tei:location[@type='coords']/tei:geo]">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        
        </xsl:template>
    
    <!-- Template to process each unique place -->
    <xsl:template match="tei:place[tei:location[@type='coords']/tei:geo]">
        <xsl:variable name="coords" select="descendant::tei:location[@type = 'coords']/tei:geo"/>
        <xsl:variable name="lat" select="replace(substring-before($coords, ' '), ',', '.')"/>
        <xsl:variable name="lon" select="replace(substring-after($coords, ' '), ',', '.')"/>
        <xsl:value-of select="$lon"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$lat"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="count(descendant::tei:listEvent/tei:event)"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>
