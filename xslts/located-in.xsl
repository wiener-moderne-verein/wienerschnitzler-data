<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs math" version="3.0">
    <!-- Identitätstransformation: Kopiert alle Elemente in das Resultat -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="true"/>
    <xsl:template match="tei:place">
        <xsl:variable name="current-corresp" as="xs:string" select="replace(@corresp, '#', '')"/>
        <xsl:choose>
            <xsl:when
                test="parent::tei:listPlace/tei:place/tei:location[@type = 'located_in_place']/tei:placeName[@key = $current-corresp]"/>
            <!-- Das hier löscht Elemente, wenn am selben Tag ein untergeordnetes, das heißt: geografisch genaueres
           vorhanden ist-->
            <!-- Sonderregeln für Wiener Bezirke, also wenn der ort wien ist, aber ein unterort innerhalb eines bezirks vorhanden -->
            <xsl:when
                test="$current-corresp = 'pmb50' and parent::tei:listPlace/tei:place/tei:location[@type = 'located_in_place']/tei:placeName[string-length(@key) = 2 and (starts-with(@key,'pmb5') or starts-with(@key, 'pmb6') or @key = 'pmb70' or @key = 'pmb71' or @key = 'pmb72' or @key = 'pmb73')]"/>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
