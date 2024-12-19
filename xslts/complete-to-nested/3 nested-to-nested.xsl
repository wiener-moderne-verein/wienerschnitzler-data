<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs math" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="true"/>
    <!-- Der dritte Schritt macht ancestors/ana eindeutig: Also wenn die Gumpendorferstraße sowohl dem 6. Bezirk wie Wien zugeschlagen
        wird, sollte nach diesem Schritt nur mehr der 6. Bezirk als "enthalten in" vorliegen, da er selbst in Wien.
        
        im Notfall (ein Ort gehört zu mehreren erwähnten Orten) kommt es zu mehreren ancestors-elementen  -->
    <xsl:template match="tei:ancestors[tokenize(@ana, 'pmb')[2]]">
        <xsl:variable name="ana-values" select="tokenize(@ana, 'pmb')[. != '']" as="xs:string*"/>
        <xsl:variable name="ana-values-bereinigt" as="xs:string*">
            <!-- hier wird 50 rausgelöscht, wenn auch ein wiener bezirk vorliegt -->
            <xsl:variable name="has-50" select="exists($ana-values[. = '50'])"/>
            <xsl:variable name="has-in-range"
                select="exists($ana-values[xs:integer(.) gt 50 and xs:integer(.) lt 74])"/>
            <xsl:if test="$has-50 or $has-in-range">
                <xsl:for-each select="$ana-values">
                    <xsl:variable name="current-value" select="xs:integer(.)"/>
                    <xsl:if
                        test="$current-value != 50 and $current-value gt 50 and $current-value lt 74">
                        <xsl:sequence select="xs:string($current-value)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="corresp-values"
            select="parent::tei:place/parent::tei:listPlace/tei:place/@corresp/replace(., '#pmb', '')"
            as="xs:string*"/>
        <xsl:variable name="erweiterte-corresp-values" as="xs:string*">
            <xsl:choose>
                <xsl:when test="contains(string-join($corresp-values, ' '), '50')">
                    <xsl:sequence select="$corresp-values"/>
                    <xsl:for-each select="51 to 74">
                        <xsl:value-of select="."/>
                        <xsl:if test="position() != last()"> </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$corresp-values"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Kreuzen der beiden Variablen -->
        <xsl:for-each select="$ana-values-bereinigt">
            <xsl:variable name="current-ana" select="." as="xs:string"/>
            <xsl:for-each select="distinct-values($erweiterte-corresp-values)">
                <xsl:if test=". = $current-ana">
                    <xsl:element name="ancestors" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="ana">
                            <xsl:value-of select="concat('pmb', $current-ana)"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:ancestors[not(@ana) or @ana = '']"/>
</xsl:stylesheet>
