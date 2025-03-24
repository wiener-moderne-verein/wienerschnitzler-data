<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="3.0">
    <xsl:param name="wiengeschichtewiki-nachtraege"
        select="document('../../data/indices/wiengeschichtewiki-nachtraege.xml')"/>
    <xsl:key name="uri-match" match="//*:item" use="*:idno[@subtype='wikidata']"/>
    <!-- Default behavior: shallow copy -->
    <xsl:mode on-no-match="shallow-copy"/>
    <!-- Output settings -->
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="tei:place[tei:idno/@subtype='wikidata' and not(tei:idno/@subtype='wiengeschichtewiki')]">
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@* | *"/>
            <xsl:if test="key('uri-match', tei:idno[@subtype='wikidata'][1], $wiengeschichtewiki-nachtraege)">
                <xsl:element name="idno" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">
                        <xsl:text>URL</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="subtype">
                        <xsl:text>wiengeschichtewiki</xsl:text>
                    </xsl:attribute>
                <xsl:copy-of select="key('uri-match', tei:idno[@subtype='wikidata'][1], $wiengeschichtewiki-nachtraege)/*:idno[@subtype='wiengeschichtewiki']/text()"
                />
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
