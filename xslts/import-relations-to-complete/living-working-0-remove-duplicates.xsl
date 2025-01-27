<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei"
    version="3.0">
    <xsl:output indent="true"/>
    
    <!-- Template zum Kopieren des XML-Kopfes -->
    <xsl:mode on-no-match="shallow-copy"/>
    
  <!-- nur notwendig, solange  der Bug besteht: https://github.com/arthur-schnitzler/pmb-service/issues/298 -->
    
    <xsl:template match="tei:relation">
        <xsl:variable name="active" select="@active"/>
        <xsl:variable name="passive" select="@passive"/>
        <xsl:variable name="name" select="@name"/>
        <xsl:choose>
            <xsl:when test="preceding-sibling::tei:relation[@active = $active and @passive = $passive and @name = $name]"/>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
        
        
    </xsl:template>
    
    
</xsl:stylesheet>
