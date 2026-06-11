<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0">

    <!-- minifiziertes JSON; statt des ausformulierten Satzes ("Am … hielt sich
         Schnitzler in … auf") wird nur noch die Ortsliste ausgegeben – den Satz
         baut das Frontend selbst aus 'date' und 'places' zusammen. -->
    <xsl:output method="json"/>

    <xsl:template match="/">
        <xsl:sequence select="array{
            for $event in //tei:event
            return map{
            'date': string($event/@when),
            'places': replace(substring-after(string($event/tei:eventName), ' hielt sich Schnitzler in '), ' auf$', ''),
            'weight': count($event//tei:place[not(.//tei:listPlace)])
            }
            }"/>
    </xsl:template>
</xsl:stylesheet>
