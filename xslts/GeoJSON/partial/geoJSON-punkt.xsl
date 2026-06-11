<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:mam="whatever"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all">
    <xsl:param name="bewohner" select="document('../../../data/indices/living-working-in.xml')"/>
    <xsl:key match="tei:place" use="@xml:id" name="bewohner-key"/>

    <!-- Personenliste (wohnort/arbeitsort) als JSON-Array -->
    <xsl:function name="mam:personen-array" as="array(*)">
        <xsl:param name="persNames" as="node()*"/>
        <xsl:sequence select="
            array {
                for $p in $persNames
                return map {
                    'p_name': normalize-space(concat($p/tei:forename, ' ', $p/tei:surname)),
                    'p_id': string($p/@ref)
                }
            }"/>
    </xsl:function>

    <!-- Erzeugt ein GeoJSON-Point-Feature als XDM-Map -->
    <xsl:function name="mam:macht-punkt" as="map(*)">
        <xsl:param name="input-placeNode" as="node()"/>
        <xsl:param name="timespan-type" as="xs:string"/>
        <xsl:param name="timespan-begin" as="xs:string"/>
        <xsl:param name="timespan-end" as="xs:string"/>
        <xsl:variable name="coords"
            select="$input-placeNode/descendant::tei:location[@type = 'coords'][1]/tei:geo[1]"/>
        <xsl:variable name="lat"
            select="xs:decimal(replace(substring-before($coords, ' '), ',', '.'))"/>
        <xsl:variable name="lon"
            select="xs:decimal(replace(substring-after($coords, ' '), ',', '.'))"/>
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
        <!-- Besuchsdaten je nach Zeitraumstyp -->
        <xsl:variable name="timestamps" as="xs:string*">
            <xsl:choose>
                <xsl:when test="$timespan-type = 'complete'">
                    <xsl:sequence
                        select="$input-placeNode/tei:listEvent/tei:event/@when/string()"/>
                </xsl:when>
                <xsl:when test="$timespan-type = 'decade'">
                    <xsl:sequence
                        select="$input-placeNode/tei:listEvent/tei:event/@when[number(substring(., 1, 4)) >= number($timespan-begin) and number(substring(., 1, 4)) &lt;= number($timespan-end)]/string()"
                    />
                </xsl:when>
                <xsl:when test="$timespan-type = 'year' or $timespan-type = 'month'">
                    <xsl:sequence
                        select="$input-placeNode/tei:listEvent/tei:event/@when[starts-with(., $timespan-begin)]/string()"
                    />
                </xsl:when>
                <xsl:when test="$timespan-type = 'day'">
                    <xsl:sequence select="$timespan-begin"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="importance" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$timespan-type = 'complete'">
                    <xsl:sequence
                        select="count($input-placeNode/descendant::tei:listEvent/tei:event)"/>
                </xsl:when>
                <xsl:when test="$timespan-type = 'decade'">
                    <xsl:sequence
                        select="count($input-placeNode/descendant::tei:listEvent/tei:event[@when[number(substring(., 1, 4)) >= number($timespan-begin) and number(substring(., 1, 4)) &lt;= number($timespan-end)]])"
                    />
                </xsl:when>
                <xsl:when test="$timespan-type = 'year' or $timespan-type = 'month'">
                    <xsl:sequence
                        select="count($input-placeNode/descendant::tei:listEvent/tei:event[@when[starts-with(., $timespan-begin)]])"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="entity-type" select="$input-placeNode/tei:desc[@type = 'entity_type']"/>
        <!-- Bewohner-Angaben nur für Gebäude u. ä. -->
        <xsl:variable name="bewohner-relevant" as="xs:boolean"
            select="starts-with($entity-type, 'R.') or contains($entity-type, 'ebäude') or contains($entity-type, 'ohnung') or contains($entity-type, 'otel') or contains($entity-type, 'heater') or contains($entity-type, '(K.')"/>
        <xsl:variable name="bewohner-eintrag"
            select="key('bewohner-key', $input-placeNode/@xml:id, $bewohner)"/>
        <xsl:variable name="properties" as="map(*)" select="
            map:merge((
                map {
                    'id': $id,
                    'title': normalize-space($input-placeNode/tei:placeName[1]),
                    'timestamp': array { $timestamps },
                    'importance': $importance
                },
                if ($input-placeNode/tei:idno[@subtype = 'wikipedia'])
                    then map { 'wikipedia': string($input-placeNode/tei:idno[@subtype = 'wikipedia'][1]) } else (),
                if ($input-placeNode/tei:idno[@subtype = 'wiengeschichtewiki'])
                    then map { 'wiengeschichtewiki': string($input-placeNode/tei:idno[@subtype = 'wiengeschichtewiki'][1]) } else (),
                if ($input-placeNode/tei:idno[@subtype = 'wikidata'])
                    then map { 'wikidata': string($input-placeNode/tei:idno[@subtype = 'wikidata'][1]) } else (),
                if ($input-placeNode/tei:idno[@subtype = 'geonames'])
                    then map { 'geonames': string($input-placeNode/tei:idno[@subtype = 'geonames'][1]) } else (),
                if ($entity-type)
                    then map {
                        'abbr': string($entity-type[1]),
                        'type': string($input-placeNode/tei:desc[@type = 'entity_type_literal'][1])
                    } else (),
                if ($bewohner-relevant and $bewohner-eintrag/tei:noteGrp[1]/tei:note[@type = 'lebt'][1])
                    then map { 'wohnort': mam:personen-array($bewohner-eintrag/tei:noteGrp[1]/tei:note[@type = 'lebt']/tei:persName) } else (),
                if ($bewohner-relevant and $bewohner-eintrag/tei:noteGrp[1]/tei:note[@type = 'arbeitet'][1])
                    then map { 'arbeitsort': mam:personen-array($bewohner-eintrag/tei:noteGrp[1]/tei:note[@type = 'arbeitet']/tei:persName) } else ()
            ))"/>
        <xsl:sequence select="
            map {
                'type': 'Feature',
                'geometry': map {
                    'type': 'Point',
                    'coordinates': [ $lon, $lat ]
                },
                'properties': $properties
            }"/>
    </xsl:function>

</xsl:stylesheet>
