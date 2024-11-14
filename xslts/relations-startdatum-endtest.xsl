<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    
    <!-- angewandt auf relations.xml. liegt das start-date auch wirklich vor dem end-date? -->
    
    <xsl:output method="xml" indent="true"/>
    <xsl:mode on-no-match="shallow-skip"/>
    
    
    <!-- Template zum Verarbeiten der XML -->
    <xsl:template match="/Items|/root">
        <root>
        <xsl:apply-templates select="item|row"/>
        </root>
    </xsl:template>
    
    <!-- Template für jedes <item> -->
    <xsl:template match="item|row">
        <!-- Variablen für die Datumswerte -->
        <xsl:variable name="startDate" as="xs:string">
            <xsl:choose>
                <xsl:when test="matches(relation_start_date, '^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$')">
                    <xsl:value-of select="relation_start_date"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0001-01-01</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable> 
        <xsl:variable name="endDate" as="xs:string">
            <xsl:choose>
                <xsl:when test="matches(relation_end_date, '^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$')">
                    <xsl:value-of select="relation_end_date"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0001-01-01</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$endDate !='0001-01-01' and $startDate !='0001-01-01'">
        <!-- Überprüfung, ob das Startdatum vor dem Enddatum liegt -->
        <xsl:choose>
            <xsl:when test="xs:date($startDate) lt xs:date($endDate)"/>
            <xsl:when test="xs:date($startDate) eq xs:date($endDate)"/>
            <xsl:otherwise>
                <xsl:element name="error">
                    <xsl:text>Fehler: Das Startdatum liegt nach dem Enddatum!</xsl:text>
                    <xsl:value-of select="relation_pk"/>
                </xsl:element>
                <!-- Fehlerfall, wenn Startdatum nach Enddatum liegt -->
            </xsl:otherwise>
        </xsl:choose>
        
       
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
