<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mam="whatever"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs math" version="3.0">
    <!-- Identitätstransformation: Kopiert alle Elemente in das Resultat -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="true"/>
    <!-- Der vierte Schritt soll nun die Hierarchie tatsächlich umsetzen, indem er bei 
        Elementen ohne ancestors beginnt -->
    <xsl:template match="tei:place[not(tei:ancestors)]">
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:variable name="corresp" select="replace(@corresp, '#', '')"/>
            <xsl:copy-of select="@* | *"/>
            <!-- zuerst kümmern wir uns um Wien, weil das ist uns das wichtigste: wir 
            vermerken bezirke, die in der partOf-Beziehung vorhanden sind-->
            <xsl:variable name="listPlace" select="parent::tei:listPlace" as="node()"/>
            <xsl:variable name="notwendige-bezirke">
                <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:for-each
                        select="distinct-values($listPlace//tei:place/tei:ancestors[mam:wienerbezirk(@ana)]/@ana)">
                        <xsl:if test=". != ''">
                            <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="corresp">
                                    <xsl:value-of select="concat('#', .)"/>
                                </xsl:attribute>
                                <xsl:element name="placeName"
                                    namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:value-of select="mam:bezirksnamen(.)"/>
                                </xsl:element>
                                <xsl:element name="ancestors"
                                    namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="ana">
                                        <xsl:text>pmb50</xsl:text>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:for-each select="$listPlace//tei:place[mam:wienerbezirk(@corresp)]">
                        <xsl:if test=". != ''">
                            <xsl:copy-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:element>
            </xsl:variable>
            <xsl:if test="$listPlace/tei:place[tei:ancestors/@ana = $corresp][1]">
                <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                    <!-- hier zuerst die Wiener Bezirke, die in den Daten sind und die 
                    benötigt werden-->
                    <xsl:if
                        test="$corresp = 'pmb50' and $notwendige-bezirke/tei:listPlace/tei:place[1]">
                        <xsl:apply-templates select="$notwendige-bezirke/tei:listPlace/tei:place"
                            mode="hierarchie-wien">
                            <xsl:with-param name="listplace" select="parent::tei:listPlace"/>
                        </xsl:apply-templates>
                    </xsl:if>
                    <!-- jetzt alle -->
                    <xsl:apply-templates
                        select="parent::tei:listPlace/tei:place[not(mam:wienerbezirk(@corresp)) and tei:ancestors/@ana = $corresp]"
                        mode="hierarchie"/>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:place[tei:ancestors]"/>
    <xsl:template match="tei:place[tei:ancestors]" mode="hierarchie">
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:variable name="corresp" select="replace(@corresp, '#', '')"/>
            <xsl:copy-of select="@* | *[not(name() = 'ancestors')]"/>
            <xsl:if test="parent::tei:listPlace/tei:place[tei:ancestors/@ana = $corresp]">
                <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:apply-templates
                        select="parent::tei:listPlace/tei:place[tei:ancestors/@ana = $corresp]"
                        mode="hierarchie"/>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:place" mode="hierarchie-wien">
        <xsl:param name="listplace" as="node()?"/>
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:variable name="corresp" select="replace(@corresp, '#', '')"/>
            <xsl:copy-of select="@* | *[not(name() = 'ancestors')]"/>
            <xsl:if test="$listplace//tei:place[tei:ancestors/@ana = $corresp]">
                <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:apply-templates
                        select="$listplace//tei:place[tei:ancestors/@ana = $corresp]"
                        mode="hierarchie"/>
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
    <xsl:function name="mam:bezirksnamen" as="xs:string">
        <xsl:param name="corresp" as="xs:string"/>
        <xsl:variable name="corresp-clean" as="xs:string"
            select="concat('pmb', replace(replace($corresp, '#', ''), 'pmb', ''))"/>
        <xsl:choose>
            <xsl:when test="$corresp-clean = 'pmb51'">
                <xsl:text>I., Innere Stadt</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb52'">
                <xsl:text>II., Leopoldstadt</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb53'">
                <xsl:text>III., Landstraße</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb54'">
                <xsl:text>IV., Wieden</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb55'">
                <xsl:text>V., Margareten</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb56'">
                <xsl:text>VI., Mariahilf</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb57'">
                <xsl:text>VII., Neubau</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb58'">
                <xsl:text>VIII., Josefstadt</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb59'">
                <xsl:text>IX., Alsergrund</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb60'">
                <xsl:text>X., Favoriten</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb61'">
                <xsl:text>XI., Simmering</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb62'">
                <xsl:text>XII., Meidling</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb63'">
                <xsl:text>XIII., Hietzing</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb64'">
                <xsl:text>XIV., Penzing</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb65'">
                <xsl:text>XV., Rudolfsheim-Fünfhaus</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb66'">
                <xsl:text>XVI., Ottakring</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb67'">
                <xsl:text>XVII., Hernals</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb68'">
                <xsl:text>XVIII., Währing</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb69'">
                <xsl:text>XIX., Döbling</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb70'">
                <xsl:text>XX., Brigittenau</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb71'">
                <xsl:text>XXI., Floridsdorf</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb72'">
                <xsl:text>XXII., Donaustadt</xsl:text>
            </xsl:when>
            <xsl:when test="$corresp-clean = 'pmb73'">
                <xsl:text>XXIII., Liesing</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Unbekannter Bezirk</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
