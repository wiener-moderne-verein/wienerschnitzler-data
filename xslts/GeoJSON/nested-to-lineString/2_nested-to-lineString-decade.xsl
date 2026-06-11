<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:mam="whatever"
    exclude-result-prefixes="#all">
    <!-- Ausgabe als minifiziertes JSON -->
    <xsl:output method="json"/>
    <xsl:import href="partial_l-linie.xsl"/>

    <!-- Externes Dokument mit den Listplace-Daten -->
    <xsl:param name="listplace-doc" select="document('../../../data/indices/listplace.xml')"/>

    <xsl:template match="/">
        <xsl:variable name="current" select="descendant::tei:listEvent" as="node()"/>
        <!-- Für jede Dekade ein Feature -->
        <xsl:variable name="features" as="map(*)*">
            <xsl:for-each select="
                distinct-values(
                //tei:event/concat(
                string(floor((fn:year-from-date(@when) - 1) div 10) * 10 + 1),
                '-',
                string(floor((fn:year-from-date(@when) - 1) div 10) * 10 + 10)
                )
                )">
                <xsl:variable name="decade" select="."/>
                <xsl:sequence select="
                    mam:l-feature('decade', $decade,
                        $current/tei:event[
                            concat(
                            string(floor((fn:year-from-date(@when) - 1) div 10) * 10 + 1),
                            '-',
                            string(floor((fn:year-from-date(@when) - 1) div 10) * 10 + 10)
                            ) = $decade
                        ]//tei:place[not(descendant::tei:listPlace/tei:place)]/@corresp,
                        $listplace-doc)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence
            select="map { 'type': 'FeatureCollection', 'features': array { $features } }"/>
    </xsl:template>
</xsl:stylesheet>
