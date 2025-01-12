<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs math" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="true"/>
    <!-- diese Datei führt die fehlenden Bezirke ein: also wenn Wien
    vorhanden ist, wird geschaut, aus welchen Bezirken Orte vorhanden 
    sind und diese ergänzt
    -->
    <xsl:param name="bezirke" as="map(xs:string, xs:string)">
        <xsl:map>
            <xsl:map-entry key="'pmb51'" select="'I., Innere Stadt'"/>
            <xsl:map-entry key="'pmb52'" select="'II., Leopoldstadt'"/>
            <xsl:map-entry key="'pmb53'" select="'III., Landstraße'"/>
            <xsl:map-entry key="'pmb54'" select="'IV., Wieden'"/>
            <xsl:map-entry key="'pmb55'" select="'V., Margareten'"/>
            <xsl:map-entry key="'pmb56'" select="'VI., Mariahilf'"/>
            <xsl:map-entry key="'pmb57'" select="'VII., Neubau'"/>
            <xsl:map-entry key="'pmb58'" select="'VIII., Josefstadt'"/>
            <xsl:map-entry key="'pmb59'" select="'IX., Alsergrund'"/>
            <xsl:map-entry key="'pmb60'" select="'X., Favoriten'"/>
            <xsl:map-entry key="'pmb61'" select="'XI., Simmering'"/>
            <xsl:map-entry key="'pmb62'" select="'XII., Meidling'"/>
            <xsl:map-entry key="'pmb63'" select="'XIII., Hietzing'"/>
            <xsl:map-entry key="'pmb64'" select="'XIV., Penzing'"/>
            <xsl:map-entry key="'pmb65'" select="'XV., Rudolfsheim-Fünfhaus'"/>
            <xsl:map-entry key="'pmb66'" select="'XVI., Ottakring'"/>
            <xsl:map-entry key="'pmb67'" select="'XVII., Hernals'"/>
            <xsl:map-entry key="'pmb68'" select="'XVIII., Währing'"/>
            <xsl:map-entry key="'pmb69'" select="'XIX., Döbling'"/>
            <xsl:map-entry key="'pmb70'" select="'XX., Brigittenau'"/>
            <xsl:map-entry key="'pmb71'" select="'XXI., Floridsdorf'"/>
            <xsl:map-entry key="'pmb72'" select="'XXII., Donaustadt'"/>
            <xsl:map-entry key="'pmb73'" select="'XXIII., Liesing'"/>
        </xsl:map>
    </xsl:param>
    <xsl:template match="tei:place[@corresp = '#pmb50']">
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="tei:placeName"/>
        </xsl:element>
        <xsl:variable name="alle-corresps"
            select="parent::tei:listPlace/tei:place/replace(@corresp, '#', '')" as="xs:string*"/>
        <xsl:for-each
            select="distinct-values(parent::tei:listPlace/tei:place/tei:ancestors/tokenize(@ana, '#pmb'))">
            <xsl:if
                test="xs:long(replace(., 'pmb', '')) lt 74 and xs:long(replace(., 'pmb', '')) gt 50">
                <xsl:if test="
                        not(some $c in $alle-corresps
                            satisfies $c = .)">
                    <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="corresp" select="concat('#', .)"/>
                        <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:value-of select="map:get($bezirke, .)"/>
                        </xsl:element>
                        <xsl:element name="ancestors" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="ana">
                                <xsl:text>50</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:ancestors[tokenize(@ana, 'pmb')[2]]">
        <xsl:for-each select="(tokenize(@ana, 'pmb'))">
            <xsl:if test="not(normalize-space(.) = '')">
                <xsl:element name="ancestors" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="ana">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:ancestors[tokenize(@ana, 'pmb')[1] and not(tokenize(@ana, 'pmb')[2])]">
        <xsl:element name="ancestors" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="ana">
                <xsl:value-of select="replace(@ana, 'pmb', '')"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:ancestors[not(@ana) or @ana = '']"/>
</xsl:stylesheet>
