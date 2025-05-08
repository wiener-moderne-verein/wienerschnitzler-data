<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="yes"/>
    <!-- Template zur Verarbeitung von tei:listEvent -->
    <xsl:template match="tei:listEvent">
        <xsl:variable name="listEvent" select="."/>
        <xsl:element name="listEvent" namespace="http://www.tei-c.org/ns/1.0">
            <!-- Iteration über eindeutige @when-Werte -->
            <xsl:for-each select="distinct-values(tei:event/@when)">
                <xsl:sort select="."/>
                <xsl:variable name="current-when" select="."/>
                <xsl:element name="event" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="when">
                        <xsl:value-of select="$current-when"/>
                    </xsl:attribute>
                    <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                        <!-- Gruppierung der tei:place-Elemente nach ihrem (normalisierten) Textinhalt -->
                        <xsl:for-each-group
                            select="$listEvent/tei:event[@when = $current-when]//tei:place"
                            group-by="normalize-space(.)">
                            <!-- Nur das erste Element der Gruppe wird übernommen -->
                            <xsl:copy-of select="current-group()[1]"/>
                        </xsl:for-each-group>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
