<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    
    <xsl:output method="json" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:sequence select="array{
            for $event in //tei:event
            return map{
            'date': string($event/@when),
            'title': replace(string($event/tei:eventName), '&amp;', '&amp;amp;'),
            'weight': count($event//tei:place[not(.//tei:listPlace)])
            }
            }"/>
    </xsl:template>
</xsl:stylesheet>
