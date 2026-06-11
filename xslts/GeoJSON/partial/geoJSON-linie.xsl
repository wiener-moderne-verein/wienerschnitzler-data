<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:mam="whatever"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all">

    <!-- Erzeugt ein GeoJSON-LineString-Feature als XDM-Map.
         Liefert eine leere Sequenz, wenn nach Deduplizierung weniger als
         zwei unterschiedliche Koordinatenpaare übrig bleiben (eine Linie
         mit nur einem Punkt wäre ungültiges GeoJSON, RFC 7946). -->
    <xsl:function name="mam:macht-linie" as="map(*)?">
        <xsl:param name="full-listPlace-dublettenbereinigt" as="node()"/>
        <xsl:param name="timespan-type" as="xs:string"/>
        <xsl:param name="timespan-begin" as="xs:string"/>
        <xsl:param name="timespan-end" as="xs:string"/>
        <xsl:variable name="geos"
            select="$full-listPlace-dublettenbereinigt//tei:location[@type = 'coords']/tei:geo"/>
        <xsl:variable name="avg-lat" as="xs:double?"
            select="avg($geos/number(replace(substring-before(., ' '), ',', '.')))"/>
        <xsl:variable name="avg-lon" as="xs:double?"
            select="avg($geos/number(replace(substring-after(., ' '), ',', '.')))"/>
        <!-- Punkte nach Winkel um den Schwerpunkt sortieren -->
        <xsl:variable name="sorted-coords" as="xs:string*">
            <xsl:for-each
                select="$full-listPlace-dublettenbereinigt/tei:place[descendant::tei:location[@type = 'coords']/tei:geo]">
                <xsl:sort select="
                        math:atan2(
                        number(replace(substring-before(tei:location[@type = 'coords']/tei:geo, ' '), ',', '.')) - $avg-lat,
                        number(replace(substring-after(tei:location[@type = 'coords']/tei:geo, ' '), ',', '.')) - $avg-lon
                        )" data-type="number"/>
                <xsl:variable name="coords" select="tei:location[@type = 'coords']/tei:geo"/>
                <xsl:sequence
                    select="concat(replace(substring-after($coords, ' '), ',', '.'), '|', replace(substring-before($coords, ' '), ',', '.'))"
                />
            </xsl:for-each>
        </xsl:variable>
        <!-- identische Koordinaten (Orte im selben Gebäude o. ä.) entfernen -->
        <xsl:variable name="distinct-coords" as="xs:string*"
            select="distinct-values($sorted-coords)"/>
        <xsl:if test="count($distinct-coords) ge 2">
            <xsl:variable name="name" as="xs:string">
                <xsl:choose>
                    <xsl:when test="$timespan-type = 'day'">
                        <!-- Bei einer Datumsangabe ein ausgeschriebenes Datum ausgeben -->
                        <xsl:variable name="day">
                            <xsl:choose>
                                <xsl:when test="starts-with(substring($timespan-begin, 9, 2), '0')">
                                    <xsl:value-of select="substring($timespan-begin, 10, 1)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="substring($timespan-begin, 9, 2)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="month" select="substring($timespan-begin, 6, 2)"/>
                        <xsl:variable name="year" select="substring($timespan-begin, 1, 4)"/>
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
                        <xsl:value-of select="concat($day, '. ', $month-name, ' ', $year)"/>
                    </xsl:when>
                    <xsl:when test="$timespan-begin = $timespan-end">
                        <xsl:value-of select="$timespan-begin"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($timespan-begin, ' – ', $timespan-end)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:sequence select="
                map {
                    'type': 'Feature',
                    'geometry': map {
                        'type': 'LineString',
                        'coordinates': array {
                            for $c in $distinct-coords
                            return [ xs:decimal(substring-before($c, '|')), xs:decimal(substring-after($c, '|')) ]
                        }
                    },
                    'properties': map { 'name': $name }
                }"/>
        </xsl:if>
    </xsl:function>
</xsl:stylesheet>
