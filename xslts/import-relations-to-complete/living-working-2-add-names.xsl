<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei"
    version="3.0">
    <xsl:output indent="yes"/>
    
    <!-- Template zum Kopieren des XML-Kopfes -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- Template für <note> -->
    <xsl:template match="tei:note">
        <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
            <!-- Kopiere Attribute -->
            <xsl:copy-of select="@*"/>
            <!-- Attribut "ref" hinzufügen -->
            <xsl:variable name="ref" select="."/>
            <!-- Kopiere und transformiere Elemente im gewünschten Namespace -->
            <xsl:for-each select="document(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/person/', replace(., '#', '')))//*:persName[*:surname or *:forename]">
                <xsl:element name="persName" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="ref">
                        <xsl:value-of select="$ref"/>
                    </xsl:attribute>
                    <xsl:copy-of select="@*"/>
                    <!-- Kopiere Attribute des persName-Elements -->
                    
                        <xsl:if test="*:forename">
                            <xsl:element name="forename" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:value-of select="*:forename"/>
                            </xsl:element>
                        </xsl:if>
                    <xsl:if test="*:surname">
                        <xsl:element name="surname" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:value-of select="*:surname"/>
                        </xsl:element>
                    </xsl:if>
                    
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
