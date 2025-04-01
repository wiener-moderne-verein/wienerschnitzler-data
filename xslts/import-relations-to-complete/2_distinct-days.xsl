<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="yes"/>
    
    <!-- Template zur Verarbeitung von tei:listEvent -->
    <xsl:template match="tei:listEvent">
        <xsl:variable name="listEvent" select="."/>
        <tei:listEvent>
            <!-- Iteration über eindeutige @when-Werte -->
            <xsl:for-each select="distinct-values(tei:event/@when)">
                <xsl:sort select="."/>
                <xsl:variable name="current-when" select="."/>
                <tei:event when="{$current-when}">
                    <tei:listPlace>
                        <!-- Gruppierung der tei:place-Elemente nach ihrem (normalisierten) Textinhalt -->
                        <xsl:for-each-group 
                            select="$listEvent/tei:event[@when = $current-when]//tei:place" 
                            group-by="normalize-space(.)">
                            <!-- Nur das erste Element der Gruppe wird übernommen -->
                            <xsl:copy-of select="current-group()[1]"/>
                        </xsl:for-each-group>
                    </tei:listPlace>
                </tei:event>
            </xsl:for-each>
        </tei:listEvent>
    </xsl:template>
    
</xsl:stylesheet>
