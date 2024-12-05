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
    <xsl:template
        match="tei:ancestors[@ana and (string-length(@ana) - string-length(translate(@ana, 'pmb', ''))) div 3 &gt; 1]">
        <xsl:variable name="hierarchie" as="node()">
            <list>
                <xsl:for-each
                    select="parent::tei:place/preceding-sibling::tei:place | parent::tei:place/following-sibling::tei:place">
                    <xsl:variable name="corresp" select="replace(@corresp, '#', '')"/>
                    <xsl:for-each select="tokenize(tei:ancestors/@ana, 'pmb')">
                        <xsl:if test=". != ''">
                            <item>
                                <xsl:attribute name="corresp">
                                    <xsl:value-of select="$corresp"/>
                                </xsl:attribute>
                                <xsl:value-of select="."/>
                            </item>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
            </list>
        </xsl:variable>
        <xsl:variable name="existiert-wien-und-bezirk" as="xs:boolean"
            select="exists(tokenize(@ana, 'pmb')[. != '' and xs:int(.) gt 50 and xs:int(.) lt 74])"/>
        <!-- Das hier ist grausam. Aber es gab Dubletten, wenn ein Ort sowohl in Wien, als auch
        in einem Bezirk lag. Deswegen wird in solchen Fällen hier der Ort Wien gestrichen. -->
        
        <xsl:for-each select="tokenize(@ana, 'pmb')">
            <xsl:if test="not(. = '50') and $existiert-wien-und-bezirk">
                <xsl:variable name="current" select="."/>
                <xsl:choose>
                    <xsl:when test=". = ''"/>
                    <xsl:when test="$hierarchie/item = $current"/>
                    <xsl:otherwise>
                        <xsl:element name="ancestors" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="ana">
                                <xsl:value-of select="concat('pmb', $current)"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:ancestors[not(@ana) or @ana = '']"/>
</xsl:stylesheet>
