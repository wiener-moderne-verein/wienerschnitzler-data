<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    version="3.0">
    <!-- Identity template to copy all nodes and attributes unchanged -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="true"/>
    
    <xsl:template match="tei:event">
        <xsl:element name="event" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="when">
                <xsl:value-of select="@when"/>
            </xsl:attribute>
            <xsl:element name="eventName" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:text>Am </xsl:text>
                <xsl:value-of select="format-date(xs:date(@when), '[D].&#160;[M].&#160;[Y0001]')"/>
                <xsl:text> hielt sich Schnitzler in </xsl:text>
                <xsl:for-each select="descendant::tei:place[not(descendant::tei:listPlace)]">
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <xsl:value-of select="normalize-space(descendant::tei:placeName)"/>
                        </xsl:when>
                        <xsl:when test="position() = last()">
                            <xsl:text> und </xsl:text>
                            <xsl:value-of select="normalize-space(descendant::tei:placeName)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select="normalize-space(descendant::tei:placeName)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:text> auf</xsl:text>
            </xsl:element>
            <xsl:copy-of select="tei:listPlace"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>

