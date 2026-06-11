<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mam="whatever"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="json tei">
    <!-- Output format: JSON (minified) -->
    <xsl:output method="json"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:import href="./partial/json-punkt.xsl"/>
    <xsl:param name="listplace" select="document('../../data/indices/listplace.xml')"/>
    <xsl:key name="listplace-lookup"
        match="tei:TEI/tei:text[1]/tei:body[1]/tei:listPlace[1]/tei:place" use="@xml:id"/>
    <!-- Root template to generate the entire timeline output -->
    <xsl:template match="/">
        <xsl:variable name="listPlaceGesamt" select="descendant::tei:body/tei:listPlace" as="node()"/>
        <xsl:variable name="entries" as="map(*)*">
            <xsl:for-each
                select="$listPlaceGesamt/tei:place[tei:listEvent[1]/tei:event]">
                <xsl:variable name="place" as="node()">
                    <xsl:element name="tei:place">
                        <xsl:copy-of select="key('listplace-lookup', @xml:id, $listplace)/@*"/>
                        <xsl:copy-of select="key('listplace-lookup', @xml:id, $listplace)/*"/>
                        <xsl:copy-of select="tei:listEvent"/>
                    </xsl:element>
                </xsl:variable>
                <!-- Aufeinanderfolgende Tage zu einer Zeitspanne zusammenfassen -->
                <xsl:for-each-group select="tei:listEvent/tei:event"
                    group-adjacent="((xs:date(@when) - xs:date('1900-01-01'))
                    div xs:dayTimeDuration('P1D')) - position()">
                    <xsl:sequence
                        select="mam:macht-punkt($place, 'timeline', current-group()[1]/@when, current-group()[last()]/@when)"/>
                </xsl:for-each-group>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="array { $entries }"/>
    </xsl:template>
   
   
   

    
    
    
    
</xsl:stylesheet>
