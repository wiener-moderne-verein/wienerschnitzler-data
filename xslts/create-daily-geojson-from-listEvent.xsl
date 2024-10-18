<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="json tei">
    
    <!-- Output format: plain text -->
    <xsl:output method="text" indent="yes" />
    <xsl:mode on-no-match="shallow-skip"/>
    
    <!-- Root template to start processing and generate output for each date -->
    <xsl:template match="/">
        <xsl:for-each select="/tei:TEI/descendant::tei:event[@when]">
            <!-- Extract the date from the current context -->
            <xsl:variable name="date" select="xs:date(@when)" as="xs:date"/>
            <!-- Format the date as YYYY-MM-DD -->
            <xsl:variable name="formatted-date" select="format-date($date, '[Y0001]-[M01]-[D01]')" />
            <!-- Generate a new file with the formatted date as the filename -->
            <xsl:result-document href="../editions//geojson/{$formatted-date}.geojson" method="text">
                <xsl:text>{</xsl:text>
                <xsl:text>&#10;  "type": "FeatureCollection",</xsl:text>
                <xsl:text>&#10;  "features": [</xsl:text>
                <!-- Call the template to create the GeoJSON content for this event -->
                <xsl:apply-templates select="descendant::tei:listPlace"/>
                <xsl:text>&#10;  ]</xsl:text>
                <xsl:text>&#10;}</xsl:text>
            </xsl:result-document>
        </xsl:for-each>
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
                <xsl:variable name="lat" select="replace(substring-before($coords, ' '), ',', '.')"/>
                <xsl:variable name="lon" select="replace(substring-after($coords, ' '), ',', '.')"/>
                
                <!-- Correct order: longitude, latitude -->
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
                    <xsl:variable name="lat" select="replace(substring-before($coords, ' '), ',', '.')"/>
                    <xsl:variable name="lon" select="replace(substring-after($coords, ' '), ',', '.')"/>
                    
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
        <xsl:variable name="iso-date" select="ancestor::tei:event/@when"/>
        
        <!-- Extrahiere Tag, Monat und Jahr -->
        <xsl:variable name="day" select="substring($iso-date, 9, 2)"/>
        <xsl:variable name="month" select="substring($iso-date, 6, 2)"/>
        <xsl:variable name="year" select="substring($iso-date, 1, 4)"/>
        
        <!-- Wandle die Monatsnummer in den Monatsnamen um -->
        <xsl:variable name="month-name">
            <xsl:choose>
                <xsl:when test="$month = '01'">Januar</xsl:when>
                <xsl:when test="$month = '02'">Februar</xsl:when>
                <xsl:when test="$month = '03'">März</xsl:when>
                <xsl:when test="$month = '04'">April</xsl:when>
                <xsl:when test="$month = '05'">Mai</xsl:when>
                <xsl:when test="$month = '06'">Juni</xsl:when>
                <xsl:when test="$month = '07'">Juli</xsl:when>
                <xsl:when test="$month = '08'">August</xsl:when>
                <xsl:when test="$month = '09'">September</xsl:when>
                <xsl:when test="$month = '10'">Oktober</xsl:when>
                <xsl:when test="$month = '11'">November</xsl:when>
                <xsl:when test="$month = '12'">Dezember</xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Ausgabe im Format "Tag. Monat Jahr" -->
        <xsl:value-of select="concat($day, '. ', $month-name, ' ', $year)"/>
        <xsl:text>"</xsl:text>
        <xsl:text>&#10;      }</xsl:text>
        <xsl:text>&#10;    }</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>
