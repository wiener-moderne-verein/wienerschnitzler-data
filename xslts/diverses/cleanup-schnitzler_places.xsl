<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output media-type="xml" indent="true"/>
    
    
    <!-- Diese Datei bereinigt schnitzler_places um Dubletten und gruppiert
    Orte innerhalb anderer Orte, also etwa "Café Central" im "Ersten Bezirk"
    -->
    
    <!-- jeder Tag nur einmal: -->
    <xsl:template match="tei:listPlace/tei:place[tei:idno[@subtype='pmb']=preceding-sibling::tei:place/tei:idno[@subtype='pmb']]"/>
    
    <xsl:template match="tei:listPlace">
        <xsl:variable name="current-list" select="." as="node()"/>
        <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="child::tei:place/tei:location[@type='located_in_place']/tei:placeName/@key">
                <xsl:variable name="current-key" select="replace(replace(., 'pmb', ''), 'place__', '')"/>
                <xsl:variable name="current-key-idno" select="concat('https://pmb.acdh.oeaw.ac.at/entity/', $current-key, '/')"/>
                <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="$current-list/tei:place[tei:idno[@subtype='pmb']=$current-key-idno]"/>
                
                <xsl:choose>
                    <xsl:when test="$current-list/tei:place/tei:idno[@subtype='pmb'] = $current-key-idno">
                        <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:copy-of select="$current-list/tei:place[tei:location[@type='located_in_place']/tei:placeName/@key = concat('place__', $current-key)]"/>
                            <xsl:copy-of select="$current-list/tei:place[tei:location[@type='located_in_place']/tei:placeName/@key = concat('pmb', $current-key)]"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select=""></xsl:copy-of>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:element>
                
                
            </xsl:for-each>
            
            
            
            
        </xsl:element>
        
        
    </xsl:template>
    
    
</xsl:stylesheet>