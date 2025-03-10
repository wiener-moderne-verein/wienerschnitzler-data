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
        <xsl:result-document href="../../../data/editions/geojson/l_decades.geojson" method="text">
            <xsl:text>{&#10;</xsl:text>
            <xsl:text>  "type": "FeatureCollection",&#10;</xsl:text>
            <xsl:text>  "features": [&#10;</xsl:text>
            
            <!-- Für jede Dekade ein Feature -->
            <xsl:for-each select="
                distinct-values(
                //tei:event/concat(
                string(floor((fn:year-from-date(@when) - 1) div 10) * 10 + 1),
                '-',
                string(floor((fn:year-from-date(@when) - 1) div 10) * 10 + 10)
                )
                )
                ">
                <xsl:variable name="decade" select="."/>
                <xsl:text>    {&#10;</xsl:text>
                <xsl:text>      "type": "Feature",&#10;</xsl:text>
                <xsl:text>      "properties": {&#10;</xsl:text>
                <xsl:text>        "decade": "</xsl:text>
                <xsl:value-of select="$decade"/>
                <xsl:text>"&#10;</xsl:text>
                <xsl:text>      },&#10;</xsl:text>
                <xsl:text>      "geometry": {&#10;</xsl:text>
                <xsl:text>        "type": "LineString",&#10;</xsl:text>
                <xsl:text>        "coordinates": [&#10;</xsl:text>
                
                <!-- Alle Koordinaten für die aktuelle Dekade -->
                <xsl:for-each select="
                    $current/tei:event[
                    concat(
                    string(floor((fn:year-from-date(@when) - 1) div 10) * 10 + 1),
                    '-',
                    string(floor((fn:year-from-date(@when) - 1) div 10) * 10 + 10)
                    ) = $decade
                    ]
                    //tei:place[not(descendant::tei:listPlace/tei:place)]/@corresp
                    ">
                    <xsl:variable name="current-id"
                        select="replace(replace(., '#', 'pmb'), 'pmbpmb', 'pmb')"/>
                    <xsl:variable name="geo"
                        select="normalize-space(key('listplace-match', $current-id, $listplace-doc)/tei:location[@type = 'coords'])"/>
                    <!-- In GeoJSON ist üblicherweise die Reihenfolge [lng, lat] -->
                    <xsl:variable name="lat" select="replace(substring-before($geo, ' '), ',', '.')"/>
                    <xsl:variable name="lng" select="replace(substring-after($geo, ' '), ',', '.')"/>
                    <xsl:value-of select="concat('          [', $lng, ', ', $lat, ']')"/>
                    <xsl:if test="not(position() = last())">
                        <xsl:text>,&#10;</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text>&#10;        ]&#10;</xsl:text>
                <xsl:text>      }&#10;</xsl:text>
                <xsl:text>    }</xsl:text>
                <!-- Komma zwischen den Features, sofern es nicht das letzte ist -->
                <xsl:if test="not(position() = last())">
                    <xsl:text>,&#10;</xsl:text>
                </xsl:if>
            </xsl:for-each>
            
            <xsl:text>&#10;  ]&#10;</xsl:text>
            <xsl:text>}</xsl:text>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
