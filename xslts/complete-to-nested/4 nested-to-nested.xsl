<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mam="whatever"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs math" version="3.0">
    <!-- Identitätstransformation: Kopiert alle Elemente in das Resultat -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="true"/>
    <!-- Der vierte Schritt soll nun die Hierarchie tatsächlich umsetzen, indem er bei 
        Elementen ohne ancestors beginnt -->
    <xsl:param name="bezirke" as="map(xs:string, xs:string)">
        <xsl:map>
            <xsl:map-entry key="'pmb51'" select="'I., Innere Stadt'"/>
            <xsl:map-entry key="'pmb52'" select="'II., Leopoldstadt'"/>
            <xsl:map-entry key="'pmb53'" select="'III., Landstraße'"/>
            <xsl:map-entry key="'pmb54'" select="'IV., Wieden'"/>
            <xsl:map-entry key="'pmb55'" select="'V., Margareten'"/>
            <xsl:map-entry key="'pmb56'" select="'VI., Mariahilf'"/>
            <xsl:map-entry key="'pmb57'" select="'VII., Neubau'"/>
            <xsl:map-entry key="'pmb58'" select="'VIII., Josefstadt'"/>
            <xsl:map-entry key="'pmb59'" select="'IX., Alsergrund'"/>
            <xsl:map-entry key="'pmb60'" select="'X., Favoriten'"/>
            <xsl:map-entry key="'pmb61'" select="'XI., Simmering'"/>
            <xsl:map-entry key="'pmb62'" select="'XII., Meidling'"/>
            <xsl:map-entry key="'pmb63'" select="'XIII., Hietzing'"/>
            <xsl:map-entry key="'pmb64'" select="'XIV., Penzing'"/>
            <xsl:map-entry key="'pmb65'" select="'XV., Rudolfsheim-Fünfhaus'"/>
            <xsl:map-entry key="'pmb66'" select="'XVI., Ottakring'"/>
            <xsl:map-entry key="'pmb67'" select="'XVII., Hernals'"/>
            <xsl:map-entry key="'pmb68'" select="'XVIII., Währing'"/>
            <xsl:map-entry key="'pmb69'" select="'XIX., Döbling'"/>
            <xsl:map-entry key="'pmb70'" select="'XX., Brigittenau'"/>
            <xsl:map-entry key="'pmb71'" select="'XXI., Floridsdorf'"/>
            <xsl:map-entry key="'pmb72'" select="'XXII., Donaustadt'"/>
            <xsl:map-entry key="'pmb73'" select="'XXIII., Liesing'"/>
        </xsl:map>
    </xsl:param>
    <xsl:template match="tei:listPlace">
        <xsl:variable name="corresp-ana">
            <list>
                <xsl:for-each-group select="tei:place" group-by="tei:ancestors/@ana">
                    <group>
                        <xsl:attribute name="ana">
                            <xsl:value-of select="replace(current-grouping-key(), 'pmb', '')"/>
                        </xsl:attribute>
                        <xsl:for-each select="current-group()">
                            <corresp>
                                <xsl:value-of select="replace(@corresp, '#pmb', '')"/>
                            </corresp>
                        </xsl:for-each>
                    </group>
                </xsl:for-each-group>
            </list>
        </xsl:variable>
        <xsl:variable name="listPlace-bearbeitet" as="node()"><!-- hier kommen alle orte rein, die ancestors haben, plus die bezirke, die notwendig sind -->
            <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="tei:place[child::tei:ancestors]"/>
                <xsl:if test="tei:place[@corresp = '#pmb50']">
                    <xsl:for-each select="$corresp-ana//*:group[mam:wienerbezirk(@ana)]">
                        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="corresp">
                                <xsl:value-of select="concat('#pmb', @ana)"/>
                            </xsl:attribute>
                            <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:value-of select="map:get($bezirke, concat('pmb', @ana))"/>
                            </xsl:element>
                            <xsl:element name="ancestors" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="ana">
                                    <xsl:text>pmb50</xsl:text>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:if>
            </xsl:element>
        </xsl:variable>
        <!--<xsl:copy-of select="$corresp-ana"></xsl:copy-of>-->
        <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="tei:place[not(tei:ancestors)]">
                <xsl:with-param name="listPlace-bearbeitet" select="$listPlace-bearbeitet"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:place[not(tei:ancestors)]">
        <xsl:param name="listPlace-bearbeitet"/>
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:variable name="corresp" select="replace(@corresp, '#', '')"
                as="xs:string"/>
            <xsl:copy-of select="@* | *"/>
            
            <xsl:if test="$listPlace-bearbeitet/tei:place[tei:ancestors/@ana = $corresp][1]">
                <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
               <xsl:apply-templates
                   select="$listPlace-bearbeitet/tei:place[tei:ancestors/@ana = $corresp]"
                    mode="hierarchie">
                   <xsl:with-param select="$listPlace-bearbeitet" name="listPlace-bearbeitet"/>
               </xsl:apply-templates>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:place[tei:ancestors]"/>
    <xsl:template match="tei:place[tei:ancestors]" mode="hierarchie">
        <xsl:param name="listPlace-bearbeitet"/>
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:variable name="corresp" select="replace(@corresp, '#', '')"/>
            <xsl:copy-of select="@* | *[not(name() = 'ancestors')]"/>
            <xsl:if test="$listPlace-bearbeitet/tei:place[tei:ancestors/@ana = $corresp][1]">
                <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:apply-templates
                        select="$listPlace-bearbeitet/tei:place[tei:ancestors/@ana = $corresp]"
                        mode="hierarchie">
                        <xsl:with-param select="$listPlace-bearbeitet" name="listPlace-bearbeitet"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <xsl:function name="mam:wienerbezirk" as="xs:boolean">
        <!-- das überprüft, ob eine pmb-Angabe
    eine der Nummern zwischen 51 und 73 ist-->
        <xsl:param name="corresp" as="xs:string"/>
        <xsl:variable name="corresp-zahl" as="xs:int"
            select="xs:int(replace(replace($corresp, '#', ''), 'pmb', ''))"/>
        <xsl:choose>
            <xsl:when test="$corresp-zahl &gt; 50 and $corresp-zahl &lt; 74">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
