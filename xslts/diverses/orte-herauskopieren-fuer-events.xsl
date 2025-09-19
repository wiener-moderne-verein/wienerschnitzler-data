<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs tei"
    version="3.0">
   <xsl:output media-type="xml" indent="true"></xsl:output>
    <xsl:mode on-no-match="shallow-skip" />
    
    <xsl:param name="aufenthalte"
        select="document('../../data/editions/xml/wienerschnitzler_distinctPlaces.xml')/tei:TEI/tei:text/tei:body/tei:listPlace"/>
    
    <!-- Template: alle Orte durchlaufen -->
    <xsl:template match="tei:place[tei:desc[@type='entity_type']= 'Museum (K.MUS)' or tei:placeName[contains(., 'Kaiserpanorama')]]">
      <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:copy-of select="@xml:id"></xsl:copy-of>
          <xsl:variable name="current-id" select="@xml:id"/>
          <xsl:variable name="placeName" select="tei:placeName[1]" as="xs:string"/>
          <xsl:element name="listEvent" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:for-each select="$aufenthalte/tei:place[@xml:id = $current-id]/tei:listEvent/tei:event">
              <xsl:element name="event" namespace="http://www.tei-c.org/ns/1.0">
                  <xsl:copy-of select="@when"/>
                  <xsl:element name="eventName" namespace="http://www.tei-c.org/ns/1.0">
                      <xsl:value-of select="concat('Besuch von ', $placeName, ', ', format-date(@when, '[D].[M].[Y]'))"/>
                  </xsl:element>
                  
              </xsl:element>
              
          </xsl:for-each>
          </xsl:element>
          
          
      </xsl:element>
      
      
    </xsl:template>
    
    <xsl:template match="tei:TEI">
        <xsl:element name="TEI" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="tei:teiHeader"/>
            <xsl:element name="text" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="body" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="descendant::tei:body/tei:listPlace/tei:place"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>
