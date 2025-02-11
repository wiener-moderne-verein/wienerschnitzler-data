<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">
    
    <xsl:param name="listPlace" select="document('../../data/indices/listplace.xml')"/>
    <xsl:key name="placeLookup" match="*:place" use="@xml:id"/>
    
    <!-- Wir geben als Ausgabe reinen Text (CSV) aus -->
    <xsl:output method="text" encoding="UTF-8" />
    
    <!-- Template für den Startknoten -->
    <xsl:template match="/">
        <!-- Optional: CSV-Header ausgeben (hier auskommentiert) -->
         <xsl:text>"ISO-date","Name","PMB-id","Latitude","Longitude","Type","Wikidata"&#10;</xsl:text>
        
        <!-- Durchlaufe alle tei:place-Elemente -->
        <xsl:for-each select="//tei:place">
            <xsl:sort select="tei:placeName[1]"/>
            <!-- Variablen zur Speicherung der Werte aus dem tei:place -->
            <xsl:variable name="placeID" select="@xml:id"/>
            <xsl:variable name="placeName" select="tei:placeName"/>
            <xsl:variable name="placeLookuppi" select="key('placeLookup', $placeID, $listPlace)" as="node()?"/>
            
            <!-- Innerhalb eines tei:place: Durchlaufe alle tei:event-Elemente in tei:listEvent -->
            <xsl:for-each select="tei:listEvent/tei:event">
                <!-- Ausgabe der CSV-Zeile: placeID, placeName, event/@when -->
                <xsl:value-of select="@when"/>
                <xsl:text>,"</xsl:text>
                <xsl:value-of select="$placeName"/>
                <xsl:text>",</xsl:text>
                <xsl:value-of select="$placeID"/>
                <xsl:text>,"</xsl:text>
                <xsl:value-of select="$placeLookuppi/tei:location[@type='coords']/tei:geo/substring-before(.,' ')"/>
                <xsl:text>","</xsl:text>
                <xsl:value-of select="$placeLookuppi/tei:location[@type='coords']/tei:geo/substring-after(.,' ')"/>
                <xsl:text>","</xsl:text>
                <xsl:value-of select="$placeLookuppi/tei:desc[@type='entity_type_literal']"/>
                <xsl:text>"</xsl:text>
                <!-- Achtung, wenn mehr Werte eingefügt werden, hier das Komma immer setzen -->
                <xsl:if test="$placeLookuppi/tei:idno[@subtype='wikidata']">
                    <xsl:text>,"</xsl:text>
                    <xsl:value-of select="concat('Q', replace(substring-after($placeLookuppi/tei:idno[@subtype='wikidata'][1], 'Q'), '/', ''))"/>
                    <xsl:text>"</xsl:text>
                </xsl:if>
                
                
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
