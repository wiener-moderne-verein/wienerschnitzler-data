<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:mam="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <!-- Identity template to copy all nodes and attributes unchanged -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="true"/>
    <!-- Das hier ergänzt die jeweilige Wohnadresse an Tagen, an denen sich Schnitzler in Wien
    aufhält-->
    <xsl:param name="wohnsitze" as="node()">
        <list>
            <item>
                <target_label>Sternwartestraße 71</target_label>
                <target_id>168815</target_id>
                <start_date>1910-07-17</start_date>
                <end_date>1931-10-21</end_date>
            </item>
            <item>
                <target_label>Edmund-Weiß-Gasse 7</target_label>
                <target_id>168940</target_id>
                <start_date>1903-09-12</start_date>
                <end_date>1910-07-16</end_date>
            </item>
            <item>
                <target_label>Frankgasse 1</target_label>
                <target_id>168934</target_id>
                <start_date>1893-11-15</start_date>
                <end_date>1903-09-11</end_date>
            </item>
            <item>
                <target_label>Grillparzerstraße</target_label>
                <target_id>412</target_id>
                <start_date>1892-10-15</start_date>
                <end_date>1893-11-14</end_date>
            </item>
            <item>
                <target_label>Kärntnerring 12/Bösendorferstraße 11</target_label>
                <target_id>167805</target_id>
                <start_date>1889-12-03</start_date>
                <end_date>1892-10-14</end_date>
            </item>
            <item>
                <target_label>Wohnung und Ordination Dr. Arthur Schnitzler Burgring 1</target_label>
                <target_id>168768</target_id>
                <start_date>1888-10-19</start_date>
                <end_date>1889-12-02</end_date>
            </item>
            <item>
                <target_label>Wohnung und Ordination Johann Schnitzler Burgring 1</target_label>
                <target_id>168765</target_id>
                <start_date>1870-05-12</start_date>
                <end_date>1888-10-18</end_date>
            </item>
            <item>
                <target_label>Kärntnerring 12/Bösendorferstraße 11</target_label>
                <target_id>167805</target_id>
                <start_date>1870-01-01</start_date>
                <end_date>1871-01-01</end_date>
            </item>
            <item>
                <target_label>Schottenbastei 3</target_label>
                <target_id>51969</target_id>
                <start_date>1864-01-22</start_date>
                <end_date>1870-01-01</end_date>
            </item>
            <item>
                <target_label>Praterstraße 16</target_label>
                <target_id>168783</target_id>
                <start_date>1862-05-15</start_date>
                <end_date>1864-01-01</end_date>
            </item>
        </list>
    </xsl:param>
    
    
    <!-- uebergib ein Datum und er schaut, in welcher Wohnung Schnitzler wohnte -->
    <xsl:function name="mam:check-date-range" as="xs:string">
        <xsl:param name="iso-date" as="xs:date"/>
        <xsl:value-of select="$wohnsitze/item[xs:date(start_date) le $iso-date and xs:date(end_date) ge $iso-date]/target_id"/>
    </xsl:function>
    
    <xsl:template match="
            tei:listPlace[tei:place/@corresp[((starts-with(., '#pmb5') or starts-with(., '#pmb6')) and string-length(.) = 6)
            or . = '#pmb70' or . = '#pmb71' or . = '#pmb72' or . = '#pmb73']]">
        <xsl:variable name="current-day" as="xs:date" select="parent::tei:event[1]/@when"/>
        <xsl:variable name="wohnungs-nummer" as="xs:string" select="mam:check-date-range($current-day)"/>
        <xsl:choose>
            <xsl:when test="tei:place/@corresp = concat('#pmb', $wohnungs-nummer)">
                <!-- es gibt die wohnung in der liste, also nur listPlace kopieren -->
                <xsl:copy-of select="."></xsl:copy-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="@*|*"/>
                    <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="corresp">
                            <xsl:value-of select="concat('#pmb', $wohnungs-nummer)"/>
                        </xsl:attribute>
                        <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="$wohnsitze/item[target_id= $wohnungs-nummer]/target_label"/>
                        </xsl:element>
                    </xsl:element>
                    
                    
                    
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
        
        
    </xsl:template>
</xsl:stylesheet>
