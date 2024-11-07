<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs math"
    version="3.0">
    
        <!-- Identitätstransformation: Kopiert alle Elemente in das Resultat -->
        <xsl:mode on-no-match="shallow-copy"/>
        <xsl:output indent="true"/>
        
        
    <xsl:template match="tei:place[tei:location[@type='located_in_place']]">
        <xsl:variable name="listPlace" select="parent::tei:listPlace" as="node()"/>
        <xsl:variable name="current" select="current()" as="node()"/>
        <xsl:for-each select="tei:location[@type='located_in_place']">
            <xsl:variable name="idno" select="concat('https:pmb.acdh.oeaw.ac.at/entity/', replace(tei:placeName/@key, 'pmb', ''))"/>
            <xsl:if test="$listPlace//tei:place[tei:idno=$idno]">
                <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="tei:placeName"/>
                    <xsl:element name="contains" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:copy-of select="$current"/>
                    </xsl:element>
                    
                    
                </xsl:element>
                
                
            </xsl:if>
            
        </xsl:for-each>
        
        
    </xsl:template>
        
        
    </xsl:stylesheet>
    