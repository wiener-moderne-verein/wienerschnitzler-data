<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei"
    version="3.0">
    <xsl:output indent="true"/>
    
    <!-- Template zum Kopieren des XML-Kopfes -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- Wurzelelement behandeln -->
    <xsl:template match="tei:TEI">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <!-- Fügt die generierte <listPlace> hinzu -->
            <xsl:element name="text" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:element name="body" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:for-each-group select=".//tei:relation" group-by="@passive">
                    <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="replace(current-grouping-key(), '#', 'pmb')"/>
                        </xsl:attribute>
                        <xsl:element name="noteGrp" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:for-each select="current-group()">
                                <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="type">
                                        <xsl:choose>
                                            <xsl:when test="@name='wohnhaft-in'">
                                                <xsl:text>lebt</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="@name='arbeitet-in'">
                                                <xsl:text>arbeitet</xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:value-of select="@active"/>
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each-group>
            </xsl:element>
            </xsl:element>
            </xsl:element>
        </xsl:copy>
        
        
    </xsl:template>
    
    <xsl:template match="tei:listRelation|tei:body|tei:text"/>
    <xsl:template match="tei:title/text()">
        <xsl:text>Wohn- und Arbeitsorte. Konkordanz Orte – Personen</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:publicationStmt/tei:p/text()">
        <xsl:text>Die vorliegende Datei erstellt eine Konkordanz zwischen Orten und
            Personen her. Im Spezifischen geht es darum, dass nur Orte aufgeführt werden,
            für die es eine Beziehung Wohnort oder Arbeitsort in der PMB gibt.</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>
