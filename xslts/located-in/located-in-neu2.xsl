<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs math" version="3.0">
    <!-- Identitätstransformation: Kopiert alle Elemente in das Resultat -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="true"/>
    <xsl:param name="listplace"
        select="document('../../editions/indices/listplace.xml')/tei:TEI[1]/tei:text[1]/tei:body[1]/tei:listPlace[1]"/>
   
   <!-- Der zweite Schritt kürzt die Inhalte der partOf-Beziehung auf jene, die auch in einem anderen place vorkommen,
       da nur für diese eine Hierarchie hergestellt wird
   
   -->
   
   <xsl:template match="tei:ancestors/@ana">
       <xsl:attribute name="ana">
           <xsl:variable name="listPlace" select="ancestor::tei:event/tei:listPlace" as="node()"/>
       <xsl:variable name="current-places" as="node()">
           <list>
               <xsl:for-each select="ancestor::tei:event/tei:listPlace/tei:place/@corresp">
                   <xsl:variable name="current" select="replace(., '#', '')"/>
                   <xsl:if
                       test="$listplace/tei:place[@xml:id = $current]/tei:location[@type = 'coords'][1]/tei:geo[1]">
                       <!-- nur Orte, die Koordinaten haben, heben andere auf -->
                       <item>
                           <xsl:value-of select="replace(., '#pmb', '')"/>
                       </item>
                   </xsl:if>
                   <xsl:if test="$current = 'pmb50'">
                       <!-- Sonderregel, hier alle Wiener Bezirke vermerken, so dass der fall, dass
                            ein Aufenthalt in Wien auch einen Aufenthalt in allen Wiener Bezirken abdeckt. -->
                       <xsl:for-each select="51 to 73">
                           <item>
                               <xsl:value-of select="."/>
                           </item>
                       </xsl:for-each>
                   </xsl:if>
               </xsl:for-each>
           </list>
       </xsl:variable>
       <xsl:for-each select="tokenize(., 'pmb')">
           <xsl:variable name="current" select="replace(., 'pmb', '')"/>
           <xsl:choose>
               <xsl:when test="$current-places/item = $current">
                   <xsl:value-of select="concat('pmb',$current)"/>
               </xsl:when>
               <xsl:otherwise>
               </xsl:otherwise>
           </xsl:choose>
       </xsl:for-each>
       
       </xsl:attribute>
       
   </xsl:template>
   
    
    
</xsl:stylesheet>
