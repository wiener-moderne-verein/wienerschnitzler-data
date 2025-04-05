<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:mam="whatever"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="json tei">
    <xsl:param name="bewohner" select="document('../../../data/indices/living-working-in.xml')"/>
    <xsl:key match="tei:place" use="@xml:id" name="bewohner-key"/>

    <xsl:function name="mam:macht-punkt">
        <xsl:param name="input-placeNode" as="node()"/>
        <xsl:param name="timespan-type" as="xs:string"/>
        <xsl:param name="timespan-begin" as="xs:string"/>
        <xsl:param name="timespan-end" as="xs:string"/>
        <xsl:variable name="coords"
            select="$input-placeNode/descendant::tei:location[@type = 'coords']/tei:geo"/>
        <xsl:variable name="lat" select="replace(substring-before($coords, ' '), ',', '.')"/>
        <xsl:variable name="lon" select="replace(substring-after($coords, ' '), ',', '.')"/>
        <!-- Properties section with title and aggregated visit dates -->
        <xsl:text>&#10;         {"id": "</xsl:text>
        <xsl:choose>
            <xsl:when test="$input-placeNode/@corresp">
                <xsl:value-of select="replace($input-placeNode/@corresp, '#', '')"/>
            </xsl:when>
            <xsl:when test="$input-placeNode/@xml:id">
                <xsl:value-of select="replace($input-placeNode/@xml:id, '#', '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="concat('pmb', replace(replace($input-placeNode/tei:idno[@subtype = 'pmb'][1], 'https://pmb.acdh.oeaw.ac.at/entity/', ''), '/', ''))"
                />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>",</xsl:text>
        <xsl:text>&#10;         "title": "</xsl:text>
        <xsl:value-of select="normalize-space($input-placeNode/tei:placeName[1])"/>
        <xsl:text>",</xsl:text>
        <!-- Aggregate visit dates for the current location -->
        <xsl:text>&#10;         "timestamp": [</xsl:text>
        <xsl:choose>
            <xsl:when test="$timespan-type = 'timeline'">
                <xsl:choose>
                    <xsl:when test="$timespan-begin = $timespan-end">
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="xs:string($timespan-begin)"/>
                        <xsl:text>"</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="xs:string($timespan-begin)"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="xs:string($timespan-end)"/>
                        <xsl:text>"</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        <xsl:text>,</xsl:text>
        <xsl:text>&#10;         "type": "</xsl:text>
        <xsl:choose>
            <xsl:when test="starts-with($input-placeNode/tei:desc[@type='entity_type'], 'A.') or starts-with($input-placeNode/tei:desc[@type='entity_type'], 'P.') or ($input-placeNode/tei:desc[@type='entity_type'] = 'BSO')">
                <xsl:text>p</xsl:text> <!-- größerer Ort, Land etc. -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>a</xsl:text> <!-- Adresse: Straße, Haus, Monument etc. -->
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>"&#10;</xsl:text>
        <xsl:text>]</xsl:text>
        <xsl:text>&#10;      }</xsl:text>
    </xsl:function>
    
</xsl:stylesheet>
