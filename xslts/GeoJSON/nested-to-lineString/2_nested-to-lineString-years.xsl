<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="tei">
    <!-- Ausgabe als reiner Text (JSON) -->
    <xsl:output method="text" encoding="UTF-8"/>
    <!-- Externes Dokument mit den Listplace-Daten -->
    <xsl:param name="listplace-doc" select="document('../../../data/indices/listplace.xml')"/>
    <!-- Key zur Verknüpfung via @xml:id -->
    <xsl:key name="listplace-match" match="tei:place" use="@xml:id"/>
    <!-- Aktueller Kontext, z. B. eine tei:listEvent-Struktur -->
    <xsl:param name="current" select="descendant::tei:listEvent" as="node()"/>
    <xsl:template match="/">
        <xsl:result-document href="../../../data/editions/geojson/l_years.geojson" method="text">
            <xsl:text>{&#10;</xsl:text>
            <xsl:text>  "type": "FeatureCollection",&#10;</xsl:text>
            <xsl:text>  "features": [&#10;</xsl:text>
            <!-- Für jedes Jahr ein Feature -->
            <xsl:for-each select="distinct-values(//tei:event/fn:year-from-date(@when))">
                <xsl:variable name="jahr" select="."/>
                <xsl:text>    {&#10;</xsl:text>
                <xsl:text>      "type": "Feature",&#10;</xsl:text>
                <xsl:text>      "properties": {&#10;</xsl:text>
                <xsl:text>        "year": "</xsl:text>
                <xsl:value-of select="$jahr"/>
                <xsl:text>"&#10;</xsl:text>
                <xsl:text>      },&#10;</xsl:text>
                <xsl:text>      "geometry": {&#10;</xsl:text>
                <xsl:text>        "type": "LineString",&#10;</xsl:text>
                <xsl:text>        "coordinates": [&#10;</xsl:text>
                <!-- Alle Koordinaten für das aktuelle Jahr -->
                <xsl:for-each
                    select="$current/tei:event[fn:year-from-date(@when) = $jahr]//tei:place[not(descendant::tei:listPlace/tei:place)]/@corresp">
                    <xsl:variable name="current-id"
                        select="replace(replace(., '#', 'pmb'), 'pmbpmb', 'pmb')"/>
                    <xsl:variable name="geo"
                        select="normalize-space(key('listplace-match', $current-id, $listplace-doc)/tei:location[@type = 'coords'])"/>
                    <!-- Beachte: In geoJSON ist in der Regel die Reihenfolge [lng, lat] -->
                    <xsl:variable name="lat" select="replace(substring-before($geo, ' '), ',', '.')"/>
                    <xsl:variable name="lng" select="replace(substring-after($geo, ' '), ',', '.')"/>
                    <xsl:value-of select="concat('          [', $lng, ', ', $lat, ']')"/>
                    <xsl:if test="$lat = ''">
                        <xsl:value-of select="concat('Error', ancestor::*/@when)"/>
                    </xsl:if>
                    <xsl:if test="not(position() = last())">
                        <xsl:text>,&#10;</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text>&#10;        ]&#10;</xsl:text>
                <xsl:text>      }&#10;</xsl:text>
                <xsl:text>    }</xsl:text>
                <!-- Komma zwischen den Features, falls es nicht das letzte Jahr ist -->
                <xsl:if test="not(position() = last())">
                    <xsl:text>,&#10;</xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>&#10;  ]&#10;</xsl:text>
            <xsl:text>}</xsl:text>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
