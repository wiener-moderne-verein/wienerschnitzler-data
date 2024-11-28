<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-skip"/>
    <!-- Ausgabe als Text (CSV) -->
    <xsl:output method="text" encoding="UTF-8" />

<!-- angewandt auf index_place_day.xml werden nur jene
    werte ausgegeben, die im tagebuch vorkommen, nicht aber
    in wienerschnitzler_complete.xml -->

<xsl:param name="start-date" as="xs:date" select="xs:date('1895-08-31')"/>
<xsl:param name="wienerschnitzler_complete" select="document('../editions/xml/wienerschnitzler_complete.xml')"></xsl:param>
<xsl:key name="date-match" match="*:event" use="@when"/>

    <!-- Hauptvorlage für die Transformation -->
    <xsl:template match="/list">
        <!-- CSV-Header -->
        <xsl:text>date,leer,Tagebuch,pmb,Name&#10;</xsl:text>
        
        <!-- Schleife über alle item-Elemente -->
        <xsl:for-each select="*:item[child::*[1] and xs:date(@target) &gt; $start-date]">
            <!-- Datum (aus dem @when-Attribut des date-Elements) -->
            <xsl:variable name="target" select="@target" />
            <xsl:variable name="matched-day" select="key('date-match', $target, $wienerschnitzler_complete)" as="node()?"/>
            <xsl:for-each select="*:placeName">
                <xsl:variable name="ref" select="replace(@ref, 'pmb', '')"/>
                <xsl:choose>
                    <xsl:when test="$ref='43406'"/>
                    <xsl:when test="$ref='45794'"/>
                    <xsl:when test="$ref='168'"/>
                    <xsl:when test="$ref='44053'"/>
                    <xsl:when test="$ref='47628'"/>
                    <xsl:when test="$ref='90249'"/>
                    <xsl:when test="$ref='166'"/>
                    <xsl:when test="$ref='38174'"/>
                    <xsl:when test="$ref='151'"/>
                    <xsl:when test="$ref='41240'"/>
                    <xsl:when test="$ref='44016'"/>
                    <xsl:when test="$ref='34478'"/>
                    <xsl:when test="$ref='91638'"/>
                    <xsl:when test="$ref='40306'"/>
                    <xsl:when test="$ref='91638'"/>
                    <xsl:when test="$ref='44335'"/>
                    <xsl:when test="$ref='43435'"/>
                    <xsl:when test="$ref='48771'"/>
                    <xsl:when test="$ref='38216'"/>
                    
                    <xsl:when test="$matched-day//*:idno[@subtype='pmb'] = concat('https://pmb.acdh.oeaw.ac.at/entity/', $ref, '/')"/>
                    <xsl:otherwise>
                        <xsl:value-of select="$target"/>
                        <xsl:text>,</xsl:text>
                        
                        <!-- Leere Spalte -->
                        
                        <xsl:text>,</xsl:text>
                        
                        <!-- PMB (Inhalt des ref-Elements mit @type='pmb') -->
                        <xsl:value-of select="$ref" />
                        
                        <xsl:text>,"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>",</xsl:text>
                        
                        <!-- Tagebuch (Inhalt des p-Elements) -->
                        <xsl:value-of select="concat('https://schnitzler-tagebuch.acdh.oeaw.ac.at/entry__', $target, '.html')" />
                        <!-- Neue Zeile für jede CSV-Zeile -->
                        <xsl:text>&#10;</xsl:text>
                        
                        
                    </xsl:otherwise>
                </xsl:choose>
               
                
                
                
            </xsl:for-each>
          
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
