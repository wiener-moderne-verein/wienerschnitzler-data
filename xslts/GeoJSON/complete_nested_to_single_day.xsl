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
    <xsl:param name="listplace" select="document('../../data/indices/listplace.xml')"/>
    <xsl:key name="listplace-lookup" match="tei:TEI/tei:text[1]/tei:body[1]/tei:listPlace[1]/tei:place" use="@xml:id"/>
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
                <xsl:variable name="when" select="@when" as="xs:date"/>
                <!-- Call the template to create the GeoJSON content for this event -->
                <xsl:apply-templates select="tei:listPlace" mode="linestring">
                    <xsl:with-param name="full-listPlace" select="$full-listPlace"/>
                </xsl:apply-templates>
                <!-- für die Linien müssen alle Orte gemeinsam verarbeitet werden -->
                <xsl:text>,</xsl:text>
                <xsl:apply-templates select="$full-listPlace" mode="point">
                    <xsl:with-param name="when" select="$when"/>
                </xsl:apply-templates>
                <xsl:text>&#10;  ]</xsl:text>
                <xsl:text>&#10;}</xsl:text>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <!-- ## place -->
    <xsl:template match="tei:place[tei:location[@type = 'coords']/tei:geo]" mode="point">
        <xsl:param name="when" as="xs:date"/>
        <!-- Add a comma before every feature except the first one -->
        <xsl:text>&#10;    {</xsl:text>
        <xsl:text>&#10;      "type": "Feature",</xsl:text>
        <xsl:text>&#10;      "geometry": {</xsl:text>
        <xsl:text>&#10;        "type": "Point",</xsl:text>
        <xsl:text>&#10;        "coordinates": [</xsl:text>
        <xsl:variable name="coords" select="tei:location[@type = 'coords']/tei:geo"/>
        <xsl:variable name="lat" select="replace(substring-before($coords, ' '), ',', '.')"/>
        <xsl:variable name="lon" select="replace(substring-after($coords, ' '), ',', '.')"/>
        <!-- Correct order: longitude, latitude -->
        <xsl:text>&#10;          </xsl:text>
        <xsl:value-of select="$lon"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$lat"/>
        <xsl:text>&#10;        ]</xsl:text>
        <xsl:text>&#10;      },</xsl:text>
        <xsl:text>&#10;      "properties": {</xsl:text>
        <xsl:text>&#10;        "title": "</xsl:text>
        <xsl:value-of select="tei:placeName[1]"/>
        <xsl:text>",</xsl:text>
        <xsl:text>&#10;        "timestamp": ["</xsl:text>
        <xsl:value-of select="$when"/>
        <xsl:text>"],</xsl:text>
        <xsl:text>&#10;        "pmb": "</xsl:text>
        <xsl:value-of
            select="concat('https://pmb.acdh.oeaw.ac.at/entity/', replace(@corresp, '#', ''), '/')"/>
        <xsl:text>"</xsl:text>
        <xsl:if test="tei:idno[@subtype = 'wikipedia']">
            <xsl:text>, </xsl:text>
            <xsl:text>&#10;        "wikipedia": "</xsl:text>
            <xsl:value-of select="tei:idno[@subtype = 'wikipedia']"/>
            <xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:if test="tei:idno[@subtype = 'wiengeschichtewiki']">
            <xsl:text>, </xsl:text>
            <xsl:text>&#10;        "wiengeschichtewiki": "</xsl:text>
            <xsl:value-of select="tei:idno[@subtype = 'wiengeschichtewiki']"/>
            <xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:text>&#10;      }</xsl:text>
        <xsl:text>&#10;      }</xsl:text>
        <xsl:if test="following-sibling::tei:place[tei:location[@type = 'coords']/tei:geo]">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:place[not(tei:location[@type = 'coords']/tei:geo)]" mode="point"/>
    <!-- das haut Orte ohne Koordinaten raus -->
    <!-- ## listPlace  -->
    <xsl:template match="tei:event/tei:listPlace" mode="linestring">
        <xsl:param name="full-listPlace" as="node()"/>
        <!-- Add a comma before every feature except the first one -->
        <xsl:if test="position() > 1"> </xsl:if>
        <xsl:choose>
            <xsl:when test="$full-listPlace//tei:place">
                <xsl:text>&#10;    {</xsl:text>
                <xsl:text>&#10;      "type": "Feature", </xsl:text>
                <xsl:text>&#10;      "geometry": {</xsl:text>
                <xsl:text>&#10;        "type": "LineString", </xsl:text>
                <xsl:text>&#10;        "coordinates": [</xsl:text>
                <xsl:variable name="latitudes" as="xs:double*"
                    select="$full-listPlace//tei:location[@type = 'coords']/tei:geo/number(replace(substring-before(., ' '), ',', '.'))"/>
                <xsl:variable name="longitudes" as="xs:double*"
                    select="$full-listPlace//tei:location[@type = 'coords']/tei:geo/number(replace(substring-after(., ' '), ',', '.'))"/>
                <xsl:variable name="avg-lat" as="xs:double" select="avg($latitudes)"/>
                <xsl:variable name="avg-lon" as="xs:double" select="avg($longitudes)"/>
                <!-- Process points and sort them based on the calculated angle -->
                <xsl:for-each
                    select="$full-listPlace/tei:place[descendant::tei:location[@type = 'coords']/tei:geo]">
                    <!-- Sort the points by angle -->
                    <xsl:sort select="
                            math:atan2(
                            number(replace(substring-before(tei:location[@type = 'coords']/tei:geo, ' '), ',', '.')) - $avg-lat,
                            number(replace(substring-after(tei:location[@type = 'coords']/tei:geo, ' '), ',', '.')) - $avg-lon
                            )" data-type="number"/>
                    <!-- Extract coordinates (lat and lon) -->
                    <xsl:variable name="coords" select="tei:location[@type = 'coords']/tei:geo"/>
                    <xsl:variable name="lat"
                        select="number(replace(substring-before($coords, ' '), ',', '.'))"/>
                    <xsl:variable name="lon"
                        select="number(replace(substring-after($coords, ' '), ',', '.'))"/>
                    <!-- Output the coordinates in sorted order -->
                    <xsl:if test="position() > 1">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:text>&#10;            [</xsl:text>
                    <xsl:value-of select="$lon"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$lat"/>
                    <xsl:text>]</xsl:text>
                </xsl:for-each>
                <xsl:text>&#10;          ]</xsl:text>
                <xsl:text>&#10;      },</xsl:text>
                <!-- Properties: Add place or listPlace name -->
                <xsl:text>&#10;      "properties": {</xsl:text>
                <xsl:text>&#10;        "name": "</xsl:text>
                <xsl:variable name="iso-date" select="ancestor::tei:event/@when"/>
                <!-- Extract day, month, and year -->
                <xsl:variable name="day">
                    <xsl:choose>
                        <xsl:when test="starts-with(substring($iso-date, 9, 2), '0')">
                            <xsl:value-of select="substring($iso-date, 10, 1)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring($iso-date, 9, 2)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="month" select="substring($iso-date, 6, 2)"/>
                <xsl:variable name="year" select="substring($iso-date, 1, 4)"/>
                <!-- Convert month number to month name -->
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
                <!-- Output in the format "Day. Month Year" -->
                <xsl:value-of select="concat($day, '. ', $month-name, ' ', $year)"/>
                <xsl:text>"</xsl:text>
                <xsl:text>&#10;      }</xsl:text>
                <xsl:text>&#10;    }</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:function name="mam:koordinaten-vorhanden" as="xs:boolean">
        <xsl:param name="corresp" as="xs:string"/>
        <xsl:variable name="corresp-clean" as="xs:string"
            select="concat('pmb', replace(replace($corresp, '#', ''), 'pmb', ''))"/>
        <xsl:variable name="lookup" select="key('listplace-lookup', $corresp-clean, $listplace)" as="node()?"/>
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
