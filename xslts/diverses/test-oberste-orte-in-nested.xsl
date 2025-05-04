<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <!-- Dieses XSLT wird auf wienerschnitzler_complete_nested angewandt und es zeigt jene
    Einträge, die nicht Orte sind und als oberste Orte in nested genannt werden. Damit kann
    überprüft werden, ob nicht etwa eine Straße aber nicht der dazugehärige Ort an einem
    Tag genannt ist -->
    
    <xsl:param name="listplace" select="document('../data/indices/listplace.xml')"/>
    <xsl:key name="listplace-lookup" match="*:place" use="@xml:id"></xsl:key>
    
    <xsl:mode on-no-match="shallow-skip"/>
    
    
    <xsl:template match="/">
        <root>
            <xsl:apply-templates/>
            
        </root>
    </xsl:template>
    
    <xsl:template match="*:place[not(*:idno)]">
        <xsl:variable name="corresp" select="replace(@corresp, '#', '')"/>
        <xsl:variable name="lookup" select="key('listplace-lookup', $corresp, $listplace)/*:desc[@type='entity_type']"/>
        <xsl:choose>
            <xsl:when test="starts-with($lookup, 'A.')"/>
            <xsl:when test="starts-with($lookup, 'P.')"/>
            <xsl:when test="contains($lookup, '.BSO)')"/>  
            <xsl:when test="starts-with($lookup, 'H.')"/>  
            <xsl:when test="starts-with($lookup, 'T.')"/>
            <xsl:when test="contains($lookup, '(N.')"/>
            <xsl:otherwise>
                
                <xsl:copy-of select="." copy-namespaces="no"></xsl:copy-of>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
</xsl:stylesheet>