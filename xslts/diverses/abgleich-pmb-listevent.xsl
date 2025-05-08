<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"  xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs tei">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="lookup-doc" select="doc('../../data/editions/xml/wienerschnitzler_complete.xml')"/>
    
    <xsl:template match="/">
        <results>
            <xsl:apply-templates select="//tei:event"/>
        </results>
    </xsl:template>
    
    <xsl:template match="tei:event">
        <xsl:variable name="current-when" select="@when-iso"/>
        <xsl:for-each select="descendant::tei:listPlace/tei:place/tei:placeName/@key">
            <xsl:variable name="current-key" select="concat('#', .)"/>
            
            <xsl:variable name="match-exists" as="xs:boolean"
                select="exists($lookup-doc//tei:event[@when = $current-when]/descendant::tei:place[@corresp = $current-key])"/>
            
            <xsl:choose>
                <xsl:when test="$match-exists"/>
                
                <xsl:otherwise>
                    <falsch when="{$current-when}" key="{$current-key}"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="tei:event" priority="1">
        <xsl:if test="exists(root(.)) and exists(root($lookup-doc)) and root(.) is root($lookup-doc)">
        </xsl:if>
        <xsl:next-match/> </xsl:template>
    
    <xsl:template match="text()|comment()|processing-instruction()"/>
    
</xsl:stylesheet>