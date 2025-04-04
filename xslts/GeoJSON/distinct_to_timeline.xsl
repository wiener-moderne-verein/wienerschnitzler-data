<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mam="whatever"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="json tei">
    <!-- Output format: plain text -->
    <xsl:output method="text" indent="yes"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:import href="./partial/geoJSON-punkt.xsl"/>
    <xsl:param name="listplace" select="document('../../data/indices/listplace.xml')"/>
    <xsl:key name="listplace-lookup"
        match="tei:TEI/tei:text[1]/tei:body[1]/tei:listPlace[1]/tei:place" use="@xml:id"/>
    <!-- Root template to generate the entire GeoJSON output -->
    <xsl:template match="/">
        <xsl:text>{</xsl:text>
        <xsl:text>&#10;  "type": "FeatureCollection",</xsl:text>
        <xsl:text>&#10;  "features": [</xsl:text>
        <!-- Process all places with coordinates and events -->
        <xsl:variable name="listPlaceGesamt" select="descendant::tei:body/tei:listPlace" as="node()"/>
        <xsl:for-each
            select="$listPlaceGesamt/tei:place[tei:listEvent[1]/tei:event]">
            <xsl:variable name="place" as="node()">
                <xsl:element name="tei:place">
                    <xsl:copy-of select="key('listplace-lookup', @xml:id, $listplace)/@*"/>
                    <xsl:copy-of select="key('listplace-lookup', @xml:id, $listplace)/*"/>
                    <xsl:copy-of select="tei:listEvent"/>
                </xsl:element>
            </xsl:variable>
            <xsl:for-each-group select="tei:listEvent/tei:event" 
                group-adjacent="((xs:date(@when) - xs:date('1900-01-01')) 
                div xs:dayTimeDuration('P1D')) - position()">
                <xsl:choose>
                    <!-- Wenn mehr als ein Event in der Gruppe ist, handelt es sich um aufeinanderfolgende Tage -->
                    <xsl:when test="count(current-group()) > 1">
                        <xsl:value-of
                            select="mam:macht-punkt($place, 'timeline', current-group()[1]/@when, current-group()[last()]/@when)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="mam:macht-punkt($place, 'timeline', current-group()[1]/@when, current-group()[1]/@when)"/>
                    </xsl:otherwise>
                    
                </xsl:choose>
            </xsl:for-each-group>
            
            
            <xsl:if test="not(position() = last())">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>&#10;  ]</xsl:text>
        <xsl:text>&#10;}</xsl:text>
    </xsl:template>
   
   
   

    
    
    
    
</xsl:stylesheet>
