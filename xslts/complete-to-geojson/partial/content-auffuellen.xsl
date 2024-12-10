<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
   
    <!-- das hier holt aus der datei input-data/listplace.xml die details zu 
    einem ort -->
    <xsl:param name="listPlace" select="document('../../data/editions/indices/listPlace.xml')" as="node()"/>
    <xsl:key name="listPlace-lookup" match="tei:place"
        use="replace(replace(@xml:id, 'place__', ''), 'pmb', '')"/>
    <xsl:template match="tei:place" mode="place-lookup">
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@corresp"/>
            <xsl:variable name="place-lookup"
                select="key('listPlace-lookup', replace(@corresp, '#pmb', ''), $listPlace)[1]"/>
            <xsl:copy-of
                select="$place-lookup/tei:placeName[1] | $place-lookup/tei:location | $place-lookup/tei:idno | $place-lookup/tei:link"
            />
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
