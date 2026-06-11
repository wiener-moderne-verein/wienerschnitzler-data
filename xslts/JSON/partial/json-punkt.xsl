<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mam="whatever"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all">

    <!-- Erzeugt einen Timeline-Eintrag als XDM-Map -->
    <xsl:function name="mam:macht-punkt" as="map(*)">
        <xsl:param name="input-placeNode" as="node()"/>
        <xsl:param name="timespan-type" as="xs:string"/>
        <xsl:param name="timespan-begin" as="xs:string"/>
        <xsl:param name="timespan-end" as="xs:string"/>
        <xsl:variable name="id" as="xs:string">
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
        </xsl:variable>
        <xsl:variable name="timestamp" as="xs:string" select="
            if ($timespan-begin = $timespan-end)
            then $timespan-begin
            else concat($timespan-begin, '/', $timespan-end)"/>
        <xsl:variable name="entity-type" select="$input-placeNode/tei:desc[@type = 'entity_type'][1]"/>
        <xsl:sequence select="
            map {
                'id': $id,
                'title': normalize-space($input-placeNode/tei:placeName[1]),
                'timestamp': [ $timestamp ],
                'type': if (starts-with($entity-type, 'A.') or starts-with($entity-type, 'P.') or $entity-type = 'BSO')
                    then 'p' (: größerer Ort, Land etc. :)
                    else 'a' (: Adresse: Straße, Haus, Monument etc. :)
            }"/>
    </xsl:function>

</xsl:stylesheet>
