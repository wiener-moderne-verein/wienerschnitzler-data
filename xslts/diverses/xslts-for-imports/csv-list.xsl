<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" media-type="text"/>
    
    <!-- das hier, angewandt auf ein excel-file, das in oxygenxml importiert wurde,
    schreibt ein csv für alle zeilen mit aufenthaltsorten. das heißt, die beziehung
    ist immer 1181
    -->
    
    
    <!-- Root template -->
    <xsl:template match="/">
        <!-- CSV Header -->
        <xsl:text>relation-id,relation_start_date,relation_end_date,relation_start_date_written,relation_end_date_written,source_id,target_id</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:for-each select="descendant::*:row[child::*[1]/name()='Heading0' and not(Heading0='') and not(Heading3='')]">
            <xsl:text>1181,</xsl:text>
            <xsl:variable name="relation_start_date" select="replace(*:Heading0, 'T00:00:00', '')"/>
            <xsl:variable name="relation_end_date">
                <xsl:choose>
                    <xsl:when test="*:Heading1 != ''">
                        <xsl:value-of select="replace(*:Heading1, 'T00:00:00', '')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$relation_start_date"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
                <xsl:value-of select="$relation_start_date"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$relation_end_date"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$relation_start_date"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$relation_end_date"/>
                <xsl:text>,2121,</xsl:text>
                <xsl:value-of select="replace(*:Heading3, 'pmb', '')"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        
        <!-- das hier, wenn die Zellen Namen haben -->
        <xsl:for-each select="descendant::*:row[child::*[1][name()='Anfang'] and matches(replace(Anfang, 'T00:00:00', ''), '^\d{4}-\d{2}-\d{2}$') and PMB != '']">
            <xsl:text>1181,</xsl:text>
            <xsl:variable name="relation_start_date" select="replace(*:Anfang, 'T00:00:00', '')"/>
            <xsl:variable name="relation_end_date">
                <xsl:choose>
                    <xsl:when test="*:Ende != ''">
                        <xsl:value-of select="replace(*:Ende, 'T00:00:00', '')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$relation_start_date"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="$relation_start_date"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$relation_end_date"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$relation_start_date"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$relation_end_date"/>
            <xsl:text>,2121,</xsl:text>
            <xsl:value-of select="replace(*:PMB, 'pmb', '')"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
      
      
    </xsl:template>
</xsl:stylesheet>
