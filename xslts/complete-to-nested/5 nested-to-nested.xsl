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
    <xsl:template match="tei:place[not(tei:ancestors) and not(descendant::tei:listPlace)]">
        <xsl:variable name="listPlace" as="node()">
            <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="parent::tei:listPlace/tei:place[tei:ancestors]"/>
            </xsl:element>
        </xsl:variable>
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:variable name="corresp" select="replace(@corresp, '#pmb', '')" as="xs:string"/>
            <xsl:copy-of select="@* | *"/>
            <xsl:if test="$listPlace//*:place[*:ancestors/@ana = $corresp]">
                <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:for-each
                        select="$listPlace//*:place[*:ancestors/@ana = $corresp]">
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
        <xsl:variable name="corresp" select="replace(replace(@corresp, '#', ''), 'pmb', '')"/>
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@* | tei:placeName"/>
            <xsl:if test="$listPlace/tei:place/tei:ancestors/@ana = $corresp">
                <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:for-each select="$listPlace/tei:place[tei:ancestors/@ana = $corresp]">
                        <xsl:variable name="listplace-reduziert" as="node()?">
                            <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:copy-of select="$listPlace/tei:place[not(@corresp = $corresp)]"/>
                            </xsl:element>
                        </xsl:variable>
                        <xsl:apply-templates select="." mode="hierarchie">
                            <xsl:with-param select="$listplace-reduziert" name="listPlace"/>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:placeName" mode="hierarchie">
        <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
