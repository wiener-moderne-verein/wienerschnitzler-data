<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mam="whatever" exclude-result-prefixes="#all">

    <!-- Key zur Verknüpfung via @xml:id (gilt auch für importierende Stylesheets) -->
    <xsl:key name="listplace-match" match="tei:place" use="@xml:id"/>

    <!-- Erzeugt ein LineString-Feature (als XDM-Map) für eine chronologische
         Folge von Orts-Referenzen (@corresp). Orte ohne Koordinaten werden
         übersprungen, unmittelbar aufeinanderfolgende identische Koordinaten
         zusammengefasst. Bleiben weniger als zwei Punkte übrig, wird kein
         Feature erzeugt (leere Sequenz) – eine "Linie" mit einem Punkt wäre
         ungültiges GeoJSON. -->
    <xsl:function name="mam:l-feature" as="map(*)?">
        <xsl:param name="prop-name" as="xs:string"/>
        <xsl:param name="prop-value" as="xs:string"/>
        <xsl:param name="corresps" as="attribute()*"/>
        <xsl:param name="listplace-doc" as="node()"/>
        <xsl:variable name="raw" as="xs:string*">
            <xsl:for-each select="$corresps">
                <xsl:variable name="current-id"
                    select="replace(replace(., '#', 'pmb'), 'pmbpmb', 'pmb')"/>
                <xsl:variable name="geo"
                    select="normalize-space(key('listplace-match', $current-id, $listplace-doc)/tei:location[@type = 'coords'])"/>
                <xsl:if test="contains($geo, ' ')">
                    <!-- In GeoJSON gilt die Reihenfolge [lng, lat] -->
                    <xsl:sequence
                        select="concat(replace(substring-after($geo, ' '), ',', '.'), '|', replace(substring-before($geo, ' '), ',', '.'))"
                    />
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="dedup" as="xs:string*" select="
            for $i in 1 to count($raw)
            return if ($i = 1 or $raw[$i] ne $raw[$i - 1]) then $raw[$i] else ()"/>
        <xsl:if test="count($dedup) ge 2">
            <xsl:sequence select="
                map {
                    'type': 'Feature',
                    'properties': map { $prop-name: $prop-value },
                    'geometry': map {
                        'type': 'LineString',
                        'coordinates': array {
                            for $c in $dedup
                            return [ xs:decimal(substring-before($c, '|')), xs:decimal(substring-after($c, '|')) ]
                        }
                    }
                }"/>
        </xsl:if>
    </xsl:function>
</xsl:stylesheet>
