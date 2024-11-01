<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mam="whatever"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output method="xml" indent="yes"/>
    <!-- Root template match -->
    <xsl:template match="tei:TEI">
        <xsl:element name="TEI" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="tei:teiHeader" copy-namespaces="true"/>
            <xsl:element name="text" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="body" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:apply-templates
                            select="descendant::tei:place[tei:location[@type = 'coords']/tei:geo]"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template
        match="tei:place[tei:location[@type = 'coords']/tei:geo and not(tei:idno[@subtype = 'pmb'] = preceding::tei:event/tei:listPlace/tei:place[tei:location[@type = 'coords']/tei:geo]/tei:idno[@subtype = 'pmb'])]">
        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="*[not(name()='idno')]"/>
            <xsl:element name="listEvent" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="event" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="when">
                        <xsl:value-of select="ancestor::tei:event/@when"/>
                    </xsl:attribute>
                    <xsl:element name="eventName" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="mam:datum(ancestor::tei:event/@when)"/>
                    </xsl:element>
                </xsl:element>
                <xsl:variable name="currentIdno" select="tei:idno[@subtype = 'pmb'][1]"/>
                <xsl:for-each
                    select="following::tei:event[tei:listPlace/tei:place[tei:location[@type = 'coords']/tei:geo and tei:idno[@subtype = 'pmb'] = $currentIdno]]/@when">
                    <xsl:element name="event" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="when">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                        <xsl:element name="eventName" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:value-of select="mam:datum(.)"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
            <xsl:copy-of select="*[(name()='idno')]"/>
        </xsl:element>
    </xsl:template>
    <xsl:template
        match="tei:place[tei:location[@type = 'coords']/tei:geo and (tei:idno[@subtype = 'pmb'] = preceding::tei:event/tei:listPlace/tei:place[tei:location[@type = 'coords']/tei:geo]/tei:idno[@subtype = 'pmb'])]"/>
    <xsl:function name="mam:datum">
        <xsl:param name="date" as="xs:date"/>
        <!-- Extrahiere Jahr, Monat und Tag -->
        <xsl:variable name="year" select="year-from-date($date)"/>
        <xsl:variable name="month" select="month-from-date($date)"/>
        <xsl:variable name="day" select="day-from-date($date)"/>
        <!-- Ermittle den Wochentag (0=Sonntag, 1=Montag, ...) -->
        <xsl:variable name="weekday" select="format-date($date, '[FNn]')"/>
        <!-- Wochentagsnamen auf Deutsch -->
        <xsl:variable name="weekday-de">
            <xsl:choose>
                <xsl:when test="$weekday = 'Monday'">Montag</xsl:when>
                <xsl:when test="$weekday = 'Tuesday'">Dienstag</xsl:when>
                <xsl:when test="$weekday = 'Wednesday'">Mittwoch</xsl:when>
                <xsl:when test="$weekday = 'Thursday'">Donnerstag</xsl:when>
                <xsl:when test="$weekday = 'Friday'">Freitag</xsl:when>
                <xsl:when test="$weekday = 'Saturday'">Samstag</xsl:when>
                <xsl:when test="$weekday = 'Sunday'">Sonntag</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$weekday"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Monatsnamen auf Deutsch -->
        <xsl:variable name="month-de">
            <xsl:choose>
                <xsl:when test="$month = 1">Januar</xsl:when>
                <xsl:when test="$month = 2">Februar</xsl:when>
                <xsl:when test="$month = 3">März</xsl:when>
                <xsl:when test="$month = 4">April</xsl:when>
                <xsl:when test="$month = 5">Mai</xsl:when>
                <xsl:when test="$month = 6">Juni</xsl:when>
                <xsl:when test="$month = 7">Juli</xsl:when>
                <xsl:when test="$month = 8">August</xsl:when>
                <xsl:when test="$month = 9">September</xsl:when>
                <xsl:when test="$month = 10">Oktober</xsl:when>
                <xsl:when test="$month = 11">November</xsl:when>
                <xsl:when test="$month = 12">Dezember</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- Zusammenstellen des deutschen Datumsformats -->
        <xsl:variable name="formattedDate"
            select="concat($weekday-de, ', ', $day, '. ', $month-de, ' ', $year)"/>
        <!-- Rückgabe des formatierten Datums -->
        <xsl:value-of select="$formattedDate"/>
    </xsl:function>
</xsl:stylesheet>
