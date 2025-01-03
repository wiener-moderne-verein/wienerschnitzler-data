<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:mam="whatever"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="json tei">
    <xsl:function name="mam:macht-punkt">
        <xsl:param name="input-placeNode" as="node()"/>
        <xsl:param name="timespan-type" as="xs:string"/>
        <xsl:param name="timespan-begin" as="xs:string"/>
        <xsl:param name="timespan-end" as="xs:string"/>
        <xsl:variable name="coords"
            select="$input-placeNode/descendant::tei:location[@type = 'coords']/tei:geo"/>
        <xsl:variable name="lat" select="replace(substring-before($coords, ' '), ',', '.')"/>
        <xsl:variable name="lon" select="replace(substring-after($coords, ' '), ',', '.')"/>
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
            select="concat('pmb', replace(replace($input-placeNode/tei:idno[@subtype = 'pmb'][1], 'https://pmb.acdh.oeaw.ac.at/entity/', ''), '/', ''))"/>
        <xsl:text>",</xsl:text>
        <xsl:text>&#10;         "title": "</xsl:text>
        <xsl:value-of select="$input-placeNode/tei:placeName[1]"/>
        <xsl:text>",</xsl:text>
        <xsl:text>&#10;         "lat": "</xsl:text>
        <xsl:value-of select="$lat"/>
        <xsl:text>",</xsl:text>
        <xsl:text>&#10;         "lon": "</xsl:text>
        <xsl:value-of select="$lon"/>
        <xsl:text>",</xsl:text>
        <!-- Aggregate visit dates for the current location -->
        <xsl:text>&#10;         "timestamp": [</xsl:text>
        <xsl:choose>
            <xsl:when test="$timespan-type = 'complete'">
                <xsl:for-each
                    select="$input-placeNode/tei:listEvent/tei:event/@when">
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"</xsl:text>
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$timespan-type = 'decade'">
                <xsl:for-each
                    select="$input-placeNode/tei:listEvent/tei:event/@when[number(substring(., 1, 4)) >= number($timespan-begin) and number(substring(., 1, 4)) &lt;= number($timespan-end)]">
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"</xsl:text>
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$timespan-type = 'year' or $timespan-type = 'month'">
                <xsl:for-each
                    select="$input-placeNode/tei:listEvent/tei:event/@when[starts-with(., $timespan-begin)]">
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"</xsl:text>
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$timespan-type = 'day'"> 
                <xsl:text>"</xsl:text>
                <xsl:value-of select="$input-placeNode/descendant::tei:event/@when"/>
                <xsl:text>"</xsl:text>
                
            </xsl:when>
        </xsl:choose>
        <xsl:text>],</xsl:text>
        <!-- Aggregate event descriptions -->
        <xsl:text>&#10;         "importance": "</xsl:text>
        <xsl:choose>
            <xsl:when test="$timespan-type = 'complete'">
                <xsl:value-of
                    select="count($input-placeNode/descendant::tei:listEvent/tei:event)"
                />
            </xsl:when>
            <xsl:when test="$timespan-type = 'decade'">
                <xsl:value-of
                    select="count($input-placeNode/descendant::tei:listEvent/tei:event[@when[number(substring(., 1, 4)) >= number($timespan-begin) and number(substring(., 1, 4)) &lt;= number($timespan-end)]])"
                />
            </xsl:when>
            <xsl:when test="$timespan-type = 'year' or $timespan-type = 'month'">
                <xsl:value-of
                    select="count($input-placeNode/descendant::tei:listEvent/tei:event[@when[starts-with(., $timespan-begin)]])"
                />
            </xsl:when>
            <xsl:when test="$timespan-type = 'day'">
                <xsl:text>1</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>"</xsl:text>
        <xsl:text>&#10;      }</xsl:text>
        <xsl:text>&#10;      }</xsl:text>
    </xsl:function>
</xsl:stylesheet>
