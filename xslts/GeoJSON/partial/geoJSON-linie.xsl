<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:mam="whatever"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="json tei">
    
    <xsl:function name="mam:macht-linie">
        <xsl:param name="full-listPlace-dublettenbereinigt" as="node()"/>
        <xsl:param name="timespan-type" as="xs:string"/>
        <xsl:param name="timespan-begin" as="xs:string"/>
        <xsl:param name="timespan-end" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$full-listPlace-dublettenbereinigt//tei:place">
                <xsl:text>&#10;    {</xsl:text>
                <xsl:text>&#10;      "type": "Feature", </xsl:text>
                <xsl:text>&#10;      "geometry": {</xsl:text>
                <xsl:text>&#10;        "type": "LineString", </xsl:text>
                <xsl:text>&#10;        "coordinates": [</xsl:text>
                <xsl:variable name="latitudes" as="xs:double*"
                    select="$full-listPlace-dublettenbereinigt//tei:location[@type = 'coords']/tei:geo/number(replace(substring-before(., ' '), ',', '.'))"/>
                <xsl:variable name="longitudes" as="xs:double*"
                    select="$full-listPlace-dublettenbereinigt//tei:location[@type = 'coords']/tei:geo/number(replace(substring-after(., ' '), ',', '.'))"/>
                <xsl:variable name="avg-lat" as="xs:double" select="avg($latitudes)"/>
                <xsl:variable name="avg-lon" as="xs:double" select="avg($longitudes)"/>
                <!-- Process points and sort them based on the calculated angle -->
                <xsl:for-each
                    select="$full-listPlace-dublettenbereinigt/tei:place[descendant::tei:location[@type = 'coords']/tei:geo]">
                    <!-- Sort the points by angle -->
                    <xsl:sort select="
                        math:atan2(
                        number(replace(substring-before(tei:location[@type = 'coords']/tei:geo, ' '), ',', '.')) - $avg-lat,
                        number(replace(substring-after(tei:location[@type = 'coords']/tei:geo, ' '), ',', '.')) - $avg-lon
                        )" data-type="number"/>
                    <!-- Extract coordinates (lat and lon) -->
                    <xsl:variable name="coords" select="tei:location[@type = 'coords']/tei:geo"/>
                    <xsl:variable name="lat"
                        select="number(replace(substring-before($coords, ' '), ',', '.'))"/>
                    <xsl:variable name="lon"
                        select="number(replace(substring-after($coords, ' '), ',', '.'))"/>
                    <!-- Output the coordinates in sorted order -->
                    <xsl:if test="position() > 1">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:text>&#10;            [</xsl:text>
                    <xsl:value-of select="$lon"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$lat"/>
                    <xsl:text>]</xsl:text>
                </xsl:for-each>
                <xsl:text>&#10;          ]</xsl:text>
                <xsl:text>&#10;      },</xsl:text>
                <!-- Properties: Add place or listPlace name -->
                <xsl:text>&#10;      "properties": {</xsl:text>
                <xsl:text>&#10;        "name": "</xsl:text>
                <xsl:variable name="iso-date" select="$timespan-begin"/>
                <!-- Extract day, month, and year -->
                <xsl:variable name="day">
                    <xsl:choose>
                        <xsl:when test="starts-with(substring($iso-date, 9, 2), '0')">
                            <xsl:value-of select="substring($iso-date, 10, 1)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring($iso-date, 9, 2)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="month" select="substring($iso-date, 6, 2)"/>
                <xsl:variable name="year" select="substring($iso-date, 1, 4)"/>
                <!-- Convert month number to month name -->
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
                <!-- Output in the format "Day. Month Year" -->
                <xsl:value-of select="concat($day, '. ', $month-name, ' ', $year)"/>
                <xsl:text>"</xsl:text>
                <xsl:text>&#10;      }</xsl:text>
                <xsl:text>&#10;    }</xsl:text>
            </xsl:when>
        </xsl:choose>
        
        
        
        
    </xsl:function>
    
    
    
</xsl:stylesheet>