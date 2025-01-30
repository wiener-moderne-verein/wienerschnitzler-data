<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs math" version="3.0">
    <xsl:mode on-no-match="shallow-copy" />
    <xsl:output indent="true"/>
    <xsl:param name="partOf" select="document('../../data/indices/partOf.xml')"/>
    <!-- Das ist eine schwierige, mehrstufige Transformation, um die Hierarche aus der
    PMB ordentlich umzusetzen, also dass Wien -> Innere Stadt -> Burggasse -> Ordination
    entsteht. 
    Im ersten Schritt wird ein Element ancestors eingeführt, das alle Elemente
    vermerkt, zu denen ein Ort gehört.
    -->
    <xsl:template match="tei:place">
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <xsl:variable name="current-corresp" select="replace(@corresp, '#pmb', '')"/>
            <xsl:apply-templates/>
            <xsl:element name="ancestors" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="ana">
                    <xsl:for-each
                        select="$partOf/root/list/item[descendant::contains[@id = $current-corresp]]">
                        <xsl:if test="@id != $current-corresp">
                            <!-- Sonderregel, für den Fall, dass ein partOf
                        mit sich selbst verlinkt ist, also Wien partOf Wien-->
                            <xsl:value-of select="concat('pmb', @id)"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
