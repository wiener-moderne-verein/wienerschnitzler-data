<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:mam="whatever"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all">
    <!-- Erzeugt pro Jahr eine Datei days/JJJJ.json, die für jeden belegten Tag
         des Jahres eine GeoJSON-FeatureCollection enthält:
         { "1900-05-15": { "type": "FeatureCollection", "features": [...] }, ... }
         Ersetzt die früheren ca. 19.600 Einzeldateien JJJJ-MM-TT.geojson. -->
    <xsl:output method="text"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:import href="./partial/geoJSON-punkt.xsl"/>
    <xsl:import href="./partial/geoJSON-linie.xsl"/>
    <xsl:param name="listplace" select="document('../../data/indices/listplace.xml')"/>
    <xsl:key name="listplace-lookup"
        match="tei:TEI/tei:text[1]/tei:body[1]/tei:listPlace[1]/tei:place" use="@xml:id"/>

    <xsl:template match="/">
        <xsl:for-each-group select="/tei:TEI/descendant::tei:event[@when]"
            group-by="substring(@when, 1, 4)">
            <xsl:result-document href="days/{current-grouping-key()}.json" method="json">
                <xsl:variable name="day-entries" as="map(*)*">
                    <xsl:for-each select="current-group()">
                        <xsl:variable name="when" select="string(@when)"/>
                        <!-- eine Variable, die die zu berücksichtigenden Orte enthält -->
                        <xsl:variable name="full-listPlace" as="node()">
                            <!-- hier werden nur die untersten Orte der Hierarchie berücksichtigt -->
                            <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:for-each select="descendant::tei:place">
                                    <xsl:choose>
                                        <xsl:when
                                            test="not(mam:koordinaten-vorhanden(@corresp)) and not(child::tei:listPlace)">
                                            <!-- hier wären Sonderregeln möglich für Orte, die keine Koordinaten haben, etwa
                                                 die Berücksichtigung des Orts, in dem er liegt -->
                                        </xsl:when>
                                        <xsl:when
                                            test="child::tei:listPlace/tei:place[mam:koordinaten-vorhanden(@corresp)][1]">
                                            <!-- Orte übergehen, für die es einen genaueren Punkt gibt -->
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:variable name="current"
                                                select="replace(@corresp, '#', '')"/>
                                            <xsl:copy-of
                                                select="$listplace/tei:TEI/tei:text/tei:body/tei:listPlace/tei:place[@xml:id = $current]"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </xsl:element>
                        </xsl:variable>
                        <!-- Orte, die in mehreren Bezirken liegen, nicht mehrfach aufnehmen, z. B. Gallitzinberg -->
                        <xsl:variable name="full-listPlace-dublettenbereinigt" as="node()">
                            <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:for-each
                                    select="$full-listPlace//tei:place[not(@xml:id = preceding-sibling::tei:place/@xml:id)]">
                                    <xsl:copy-of select="."/>
                                </xsl:for-each>
                            </xsl:element>
                        </xsl:variable>
                        <xsl:variable name="features" as="map(*)*">
                            <!-- Verbindungslinie (entfällt bei weniger als zwei unterschiedlichen Punkten) -->
                            <xsl:sequence
                                select="mam:macht-linie($full-listPlace-dublettenbereinigt, 'day', $when, $when)"/>
                            <!-- Punkte -->
                            <xsl:for-each
                                select="$full-listPlace-dublettenbereinigt/tei:place[tei:location[@type = 'coords']/tei:geo]">
                                <xsl:sequence select="mam:macht-punkt(., 'day', $when, $when)"/>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:sequence select="
                            map {
                                $when: map { 'type': 'FeatureCollection', 'features': array { $features } }
                            }"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:sequence select="map:merge($day-entries)"/>
            </xsl:result-document>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:function name="mam:koordinaten-vorhanden" as="xs:boolean">
        <xsl:param name="corresp" as="xs:string"/>
        <xsl:variable name="corresp-clean" as="xs:string"
            select="concat('pmb', replace(replace($corresp, '#', ''), 'pmb', ''))"/>
        <xsl:variable name="lookup" select="key('listplace-lookup', $corresp-clean, $listplace)"
            as="node()?"/>
        <xsl:choose>
            <xsl:when
                test="$lookup/tei:location[@type = 'coords'][1]/tei:geo[not(normalize-space(.) = '')]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
