<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mam="whatever"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs math" version="3.0">
    <!-- Identitätstransformation: Kopiert alle Elemente in das Resultat -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="true"/>
    <!-- Diese Schritt soll die Klärung übernehmen, ob eine Ort zu zwei Orten
    gehört oder welches das richtige ancestor-Element ist (gehört zu einer 
    Straße, gehört zu einem Bezirk) -->
  
  <xsl:template match="tei:place[tei:ancestors[2]]">
      <xsl:variable name="current-corresp" select="@corresp"/>
      <xsl:variable name="listplace" as="node()">
          <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
              <xsl:copy-of select="parent::tei:listPlace/tei:place[not(@corresp = $current-corresp)]"/>
          </xsl:element>
      </xsl:variable>
      <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:copy-of select="@*|tei:placeName"/>
          <xsl:variable name="anas">
              <list>
                  <xsl:for-each select="tei:ancestors/@ana">
                      <item>
                          <xsl:value-of select="."/>
                      </item>
                  </xsl:for-each>
              </list>
          </xsl:variable>
          <xsl:for-each select="tei:ancestors">
              <xsl:variable name="current-ana" select="@ana"/>
              <xsl:variable name="current-ana-correspformat" select="concat('#pmb', $current-ana)"/>
              <xsl:for-each select="$anas//*:item[. != $current-ana]">
                  <xsl:variable name="other-ana" select="."/>
                  <xsl:choose>
                      <xsl:when test="$listplace/tei:place[@corresp = $current-ana-correspformat]/tei:ancestors/@ana = $other-ana"/>
                      <xsl:otherwise>
                          <xsl:element name="ancestors" namespace="http://www.tei-c.org/ns/1.0">
                              <xsl:attribute name="ana">
                                  <xsl:value-of select="."/>
                              </xsl:attribute>
                          </xsl:element>
                      </xsl:otherwise>
                  </xsl:choose>
              </xsl:for-each>
                            
              
          </xsl:for-each>
          
          
      </xsl:element>
      
  </xsl:template>
  
</xsl:stylesheet>
