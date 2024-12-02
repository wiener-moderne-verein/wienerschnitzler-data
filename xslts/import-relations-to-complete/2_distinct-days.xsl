<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <!-- Identity template to copy all nodes and attributes unchanged -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="true" ></xsl:output>
    <!-- Main template to match the row element -->
    
    <!-- Das hier nimmt die mit Transformation 1 geschaffene Liste und macht sie 
    tageweise distinkt  -->
    
    
    <xsl:template match="tei:listEvent">
        <xsl:variable name="listEvent" select="." as="node()"/>
        <xsl:element name="listEvent" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="distinct-values(tei:event/@when)">
                <xsl:sort select="."></xsl:sort>
                <xsl:variable name="current-when" select="."/>
                <xsl:element name="event" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="when">
                        <xsl:value-of select="$current-when"/>
                    </xsl:attribute>
                    <xsl:element name="eventName" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:text>Am </xsl:text>
                        <xsl:value-of select="format-date(xs:date($current-when), '[D].&#160;[M].&#160;[Y0001]')"/>
                        <xsl:text> war Schnitzler in </xsl:text>
                        <xsl:for-each select="$listEvent/tei:event[@when = $current-when]">
                            <xsl:value-of select="normalize-space(descendant::tei:place/tei:placeName)"/>
                            <xsl:if test="not(fn:position() = last())">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:element>
                    <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:for-each select="$listEvent/tei:event[@when = $current-when]">
                            <xsl:copy-of select="descendant::tei:place"/>
                        </xsl:for-each>
                        
                        
                    </xsl:element>
                    
                </xsl:element>
                
                
            </xsl:for-each>
            
            
            
        </xsl:element>
        
        
    </xsl:template>
    
    
    
    
    
</xsl:stylesheet>
