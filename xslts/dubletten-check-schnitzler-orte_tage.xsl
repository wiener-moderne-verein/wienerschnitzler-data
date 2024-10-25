<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="3.0">
    <!-- https://pmb.acdh.oeaw.ac.at/apis/relations/person-place/?source=2121&amp;target=50&amp;start_date__year_min=1886&amp;start_date__year_max=1886&amp;end_date__year_min=1886&amp;end_date__year_max=1886 -->
    <!-- Identitätstransformation, um alle Elemente unverändert zu kopieren -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- Template für die Events -->
    <xsl:template match="tei:event">
        <xsl:variable name="currentHead" select="tei:head"/>
        <xsl:variable name="currentDate" select="@when-iso"/>
        <!-- Überprüfen, ob es ein vorheriges event gibt mit demselben @when-iso und head -->
        <xsl:if test="preceding-sibling::tei:event[@when-iso = $currentDate and tei:head = $currentHead]">
            <!-- Nur Dubletten ausgeben -->
            <xsl:variable name="pmb" select="replace(replace(tei:idno, 'https://pmb.acdh.oeaw.ac.at/entity/', ''), '/', '')"/>
            <xsl:variable name="jahr" select="substring($currentDate, 1, 4)"/>
            <xsl:element name="dublette">
                <xsl:attribute name="when">
                    <xsl:value-of select="$currentDate"/>
                </xsl:attribute>
                <xsl:attribute name="head">
                    <xsl:value-of select="$currentHead"/>
                </xsl:attribute>
                <xsl:value-of select="concat('https://pmb.acdh.oeaw.ac.at/apis/relations/person-place/?source=2121&amp;target=', $pmb, '&amp;start_date__year_min=', $jahr, '&amp;start_date__year_max=', $jahr, '&amp;end_date__year_min=', $jahr, '&amp;end_date__year_max=', $jahr)"/>
            </xsl:element>
            
            
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
