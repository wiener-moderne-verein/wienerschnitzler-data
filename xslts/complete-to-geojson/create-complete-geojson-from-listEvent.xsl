<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mam="whatever"
    exclude-result-prefixes="json tei">
    
    <!-- Output format: plain text -->
    <xsl:output method="text" indent="yes" />
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:import href="./partial/geoJSON-punkt.xsl"/>
    
    <!-- Root template to start the GeoJSON output -->
    <xsl:template match="tei:TEI">
        <xsl:text>{</xsl:text>
        <xsl:text>&#10;  "type": "FeatureCollection",</xsl:text>
        <xsl:text>&#10;  "features": [</xsl:text>
        
        <!-- Group places by coordinates to merge duplicate locations -->
        <xsl:for-each select="descendant::tei:place[tei:location[@type='coords']/tei:geo]">
            <xsl:apply-templates select="."/>
            <xsl:if test="position() != last()">
                <xsl:text>,</xsl:text>
            </xsl:if>
        </xsl:for-each>
        
        <xsl:text>&#10;  ]</xsl:text>
        <xsl:text>&#10;}</xsl:text>
    </xsl:template>
    
    <!-- Template to process each unique place -->
    <xsl:template match="tei:place[tei:location[@type='coords']/tei:geo]">
        <xsl:variable name="place-with-event">
            <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="@*|child::*"/>
                <xsl:element name="listEvent" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="event" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="when">
                            <xsl:value-of select="ancestor::tei:event/@when"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
                
            </xsl:element>
            
        </xsl:variable>
        <xsl:value-of select="mam:macht-punkt($place-with-event/*, 'day', $place-with-event/descendant::tei:event/@when, $place-with-event/descendant::tei:event/@when)"/>
    </xsl:template>
    
</xsl:stylesheet>
