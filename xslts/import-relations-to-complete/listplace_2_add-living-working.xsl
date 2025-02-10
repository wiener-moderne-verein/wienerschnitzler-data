<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="3.0">
    <xsl:param name="living-working-in"
        select="document('../../data/indices/living-working-in.xml')"/>
    <xsl:key name="living-in-match" match="tei:place" use="@xml:id"/>
    <!-- Default behavior: shallow copy -->
    <xsl:mode on-no-match="shallow-copy"/>
    <!-- Output settings -->
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="tei:place">
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@* | *"/>
            <xsl:if test="key('living-in-match', @xml:id, $living-working-in)">
                <xsl:copy-of select="key('living-in-match', @xml:id, $living-working-in)//*:noteGrp"
                />
            </xsl:if>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
