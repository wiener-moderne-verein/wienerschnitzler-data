<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mam="whatever"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs math" version="3.0">
    <!-- Identitätstransformation: Kopiert alle Elemente in das Resultat -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="true"/>
    <!-- Der vierte Schritt soll nun die Hierarchie tatsächlich umsetzen, indem er bei 
        Elementen ohne ancestors beginnt -->
    <xsl:key name="places-by-ancestor" match="tei:place" use="tei:ancestors/@ana"/>
    <xsl:template match="tei:place[tei:ancestors]"/>
    <xsl:template match="tei:place[not(tei:ancestors)]">
        <xsl:variable name="listPlace" as="node()">
            <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="parent::tei:listPlace/tei:place[tei:ancestors]"/>
            </xsl:element>
        </xsl:variable>
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:variable name="corresp" select="replace(@corresp, '#pmb', '')" as="xs:string"/>
            <xsl:copy-of select="@* | *"/>
            <xsl:if test="$listPlace//*:place[*:ancestors/@ana = $corresp and not(*:ancestors[2])]">
                <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:for-each
                        select="$listPlace//*:place[*:ancestors/@ana = $corresp and not(*:ancestors[2])]">
                        <xsl:apply-templates select="." mode="hierarchie">
                            <xsl:with-param name="listPlace" select="$listPlace"/>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:place[tei:ancestors]" mode="hierarchie">
        <xsl:param name="listPlace"/>
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*|tei:placeName"/>
            <xsl:variable name="corresp" select="replace(replace(@corresp, '#', ''), 'pmb', '')"/>
            <xsl:variable name="lastPlace">
                <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:for-each select="$listPlace//*:place">
                        <xsl:choose>
                            <xsl:when test="@corresp = concat('pmb', $corresp)"/>
                            <!-- den gerade 
                        verarbeiteten knoten braucht man nicht -->
                            <xsl:when test="child::*:ancestors[2]">
                                <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:copy-of select="@*"></xsl:copy-of>
                                    <xsl:copy-of select="*:placeName"/>
                                    <xsl:for-each select="*:ancestors[not(@ana = $corresp)]">
                                        <xsl:element name="ancestors"
                                            namespace="http://www.tei-c.org/ns/1.0">
                                            <xsl:copy-of select="@*"/>
                                        </xsl:element>
                                    </xsl:for-each>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:element>
            </xsl:variable>
            <xsl:if test="$lastPlace//*:place[*:ancestors/@ana = $corresp and not(*:ancestors[2])]">
                <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="listPlace">
                    <xsl:for-each
                        select="$lastPlace//*:place[*:ancestors/@ana = $corresp and not(*:ancestors[2])]">
                        <xsl:apply-templates select="." mode="hierarchie">
                            <xsl:with-param name="listPlace" select="$lastPlace"/>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
