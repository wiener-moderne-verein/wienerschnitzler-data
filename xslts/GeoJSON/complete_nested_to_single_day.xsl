<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mam="whatever"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="json tei">
    <!-- Output format: plain text -->
    <xsl:output method="text" indent="yes"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:import href="./partial/geoJSON-punkt.xsl"/>
    <xsl:import href="./partial/geoJSON-linie.xsl"/>
    <xsl:param name="listplace" select="document('../../data/indices/listplace.xml')"/>
    <xsl:key name="listplace-lookup"
        match="tei:TEI/tei:text[1]/tei:body[1]/tei:listPlace[1]/tei:place" use="@xml:id"/>
    <!-- Root template to start processing and generate output for each date -->
    <xsl:template match="/">
        <xsl:for-each select="/tei:TEI/descendant::tei:event[@when]">
            <!-- Extract the date from the current context -->
            <xsl:variable name="date" select="xs:date(@when)" as="xs:date"/>
            <!-- Format the date as YYYY-MM-DD -->
            <xsl:variable name="formatted-date" select="format-date($date, '[Y0001]-[M01]-[D01]')"/>
            <!-- Generate a new file with the formatted date as the filename -->
            <xsl:result-document href="../../../data/editions/geojson/{$formatted-date}.geojson"
                method="text">
                <xsl:text>{</xsl:text>
                <xsl:text>&#10;  "type": "FeatureCollection",</xsl:text>
                <xsl:text>&#10;  "features": [</xsl:text>
                <!-- eine Variable, die die zu berücksichtigenden Orte enthält -->
                <xsl:variable name="full-listPlace" as="node()">
                    <!-- hier werden nur die untersten Orte der Hierarchie berücksichtigt -->
                    <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:for-each select="descendant::tei:place">
                            <xsl:choose>
                                <xsl:when
                                    test="not(mam:koordinaten-vorhanden(@corresp)) and not(child::tei:listPlace)">
                                    <!-- hier wären Sonderregeln möglich für Orte, die keine Koordinaten haben, etwa
                            die Berücksichtigung des Orts, in dem er liegt-->
                                </xsl:when>
                                <xsl:when
                                    test="child::tei:listPlace/tei:place[mam:koordinaten-vorhanden(@corresp)][1]">
                                    <!-- Orte übergehen, für die es einen genaueren Punkt gibt -->
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:variable name="current" select="replace(@corresp, '#', '')"/>
                                    <xsl:copy-of
                                        select="$listplace/tei:TEI/tei:text/tei:body/tei:listPlace/tei:place[@xml:id = $current]"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:variable>
                <xsl:variable name="full-listPlace-dublettenbereinigt" as="node()"><!-- Hier noch eine Schlaufe, damit Orte, die in mehreren
                Bezirken liegen, nicht mehrfach kommen, z.B. Gallitzinberg -->
                    <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:for-each
                            select="$full-listPlace//tei:place[not(@xml:id = preceding-sibling::tei:place/@xml:id)]">
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:variable>
                <xsl:variable name="when" select="@when" as="xs:date"/>
                <!-- Call the template to create the GeoJSON content for this event -->
                <xsl:apply-templates select="tei:listPlace" mode="linestring">
                    <xsl:with-param name="full-listPlace-dublettenbereinigt"
                        select="$full-listPlace-dublettenbereinigt"/>
                </xsl:apply-templates>
                <!-- für die Linien müssen alle Orte gemeinsam verarbeitet werden -->
                <xsl:text>,</xsl:text>
                <xsl:apply-templates select="$full-listPlace-dublettenbereinigt" mode="point">
                    <xsl:with-param name="when" select="$when"/>
                </xsl:apply-templates>
                <xsl:text>&#10;  ]</xsl:text>
                <xsl:text>&#10;}</xsl:text>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <!-- ## place -->
    <xsl:template match="tei:place[tei:location[@type = 'coords']/tei:geo]" mode="point">
        <xsl:param name="when"/>
        <xsl:value-of select="mam:macht-punkt(., 'day', xs:string($when), xs:string($when))"/>
        <xsl:if test="following-sibling::tei:place[tei:location[@type = 'coords']/tei:geo]">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:place[not(tei:location[@type = 'coords']/tei:geo)]" mode="point"/>
    <!-- das haut Orte ohne Koordinaten raus -->
    <!-- ## listPlace  -->
    <xsl:template match="tei:event/tei:listPlace" mode="linestring">
        <xsl:param name="full-listPlace-dublettenbereinigt" as="node()"/>
        <!-- Add a comma before every feature except the first one -->
        <xsl:if test="position() > 1"> </xsl:if>
        <xsl:value-of select="mam:macht-linie($full-listPlace-dublettenbereinigt, 'day', ancestor::tei:event/@when, ancestor::tei:event/@when)"/>
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
