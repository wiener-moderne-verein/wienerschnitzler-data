<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="3.0">
    
    <!-- Set the path to the external document -->
    <xsl:param name="externalDoc"
        select="document('../../data/editions/xml/wienerschnitzler_distinctPlaces.xml')"/>
    <xsl:param name="ortstypen"
        select="document('../../data/indices/ortstypen.xml')"/>
    <xsl:key name="ortstypenmatch" match="*:item" use="*:abbreviation"/>
    
    <!-- Default behavior: shallow copy -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- Output settings -->
    <xsl:output method="xml" indent="yes"/>
    
    <!-- Process tei:listPlace -->
    <xsl:template match="tei:listPlace">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- Sort tei:place elements by tei:placeName[1] -->
            <xsl:apply-templates select="tei:place">
                <xsl:sort select="tei:placeName[1]" data-type="text" order="ascending" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <!-- Process tei:place -->
    <xsl:template match="tei:listPlace/tei:place">
        <xsl:variable name="current-id" select="@xml:id" as="xs:string"/>
        <!-- Check if xml:id exists in the external document -->
        <xsl:if test="$externalDoc/tei:TEI/tei:text[1]/tei:body[1]/tei:listPlace[1]/tei:place[@xml:id = $current-id][1]">
            <xsl:copy>
                <xsl:apply-templates select="@* | node()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:desc[@type='entity_type']">
        <xsl:copy-of select="."/>
        <xsl:if test="key('ortstypenmatch', ., $ortstypen)">
            <xsl:element name="desc" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="type">
                    <xsl:text>entity_type_literal</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="key('ortstypenmatch', ., $ortstypen)//*:name"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
