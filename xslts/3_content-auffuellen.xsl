<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <!-- Identity template to copy all nodes and attributes unchanged -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="true" ></xsl:output>
    <!-- Main template to match the row element -->
    
    <!-- Das hier nimmt die mit Transformation 2 geschaffene Liste
        und ergänzt den Inhalt von einer listPlace. (Ich hätte es live über die API
        machen können, aber das wäre viel langsamer). Also zuerst hier
        die Liste laden: https://pmb.acdh.oeaw.ac.at/export/ -->
    
    <xsl:param name="listPlace" select="document('../input-data/listPlace.xml')" as="node()"/>
    <xsl:key name="listPlace-lookup" match="tei:place" use="replace(replace(@xml:id, 'place__', ''), 'pmb', '')"/>
    
    <xsl:template match="tei:place">
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:variable name="place-lookup" select="key('listPlace-lookup', replace(@corresp, '#pmb', ''), $listPlace)[1]"/>
            <xsl:copy-of select="$place-lookup/tei:placeName[1]|$place-lookup/tei:location|$place-lookup/tei:idno|$place-lookup/tei:link"/>
            
            
        </xsl:element>
        
        
    </xsl:template>
    
    
    
    
    
</xsl:stylesheet>
