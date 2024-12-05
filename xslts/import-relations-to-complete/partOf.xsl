<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    <xsl:output method="xml" indent="yes"/>
    <!-- Das wird angewandt auf den PMB-import partOf.xml, der aus dem
    python-script hervorgeht. Ich hab' die Namen rauskopiert, dann ist die 
    Datei kleiner-->
    <!-- Haupttransformationsregel -->
    <xsl:template match="root">
        <root>
            <p>This file contains partOf-relations of places, i.e. Vienna is in Austria. It is used
                to always use the geographically most accurate position. Example: On a certain day
                Schnitzler was in Vienna and in the Café Central. As the Café Central is a more
                exact position within Vienna than "Vienna" itself, the latter information is
                redundant and can be omitted.</p>
            <list>
                <!-- Gruppierung der Beziehungen nach target -->
                <xsl:for-each-group select="row" group-by="target_id">
                    <xsl:if test="current-grouping-key() != source_id">
                        <!-- This should rule out relations to self, i.e. Vienna is located in Vienna -->
                        <item>
                            <xsl:attribute name="id">
                                <xsl:value-of select="current-grouping-key()"/>
                            </xsl:attribute>
                            <!--<name>
                        <xsl:value-of select="current-group()[1]/target"/>
                    </name>-->
                            <xsl:for-each select="current-group()">
                                <contains>
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="source_id"/>
                                    </xsl:attribute>
                                    <!--<name>
                                <xsl:value-of select="source"/>
                            </name>-->
                                </contains>
                            </xsl:for-each>
                        </item>
                    </xsl:if>
                </xsl:for-each-group>
            </list>
        </root>
    </xsl:template>
</xsl:stylesheet>
