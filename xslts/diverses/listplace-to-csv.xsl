<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei"
    expand-text="yes">
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <!-- Header row (optional, kann entfernt werden) -->
    <xsl:template match="/">
        <xsl:text>ID1,ID2&#10;</xsl:text>
        <xsl:apply-templates select="//tei:place"/>
    </xsl:template>
    
    <!-- Each row: id,id -->
    <xsl:template match="tei:place">
        <xsl:variable name="id" select="replace(@xml:id, 'pmb', '')"/>
        <xsl:variable name="id-uri" select="concat('https://wienerschnitzler.org/', @xml:id, '.html')"/>
        <xsl:value-of select="$id || ',' || $id-uri || '&#10;'"/>
    </xsl:template>
    
</xsl:stylesheet>
