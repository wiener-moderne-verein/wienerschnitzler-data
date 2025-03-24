#!/usr/bin/env python3
import os
import requests
from lxml import etree

def get_wiengeschichtewiki_from_wikidata(qid):
    """
    Ruft die Wikidata-Entität für die gegebene Q-ID ab und liefert den Wert der Property P7842 zurück,
    sofern vorhanden.
    """
    url = f"https://www.wikidata.org/wiki/Special:EntityData/{qid}.json"
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        claims = data.get("entities", {}).get(qid, {}).get("claims", {})
        if "P7842" in claims:
            claim = claims["P7842"][0]
            value = claim.get("mainsnak", {}).get("datavalue", {}).get("value")
            return value
    except Exception as e:
        print(f"Fehler beim Abruf von Wikidata für {qid}: {e}")
    return None

def process_xml(input_file, output_file):
    """
    Lädt die TEI-XML (listplace.xml), iteriert über alle <place>-Elemente (im TEI-Namespace)
    und erstellt eine neue XML-Datei mit einer Liste von <item>-Elementen.
    
    Jedes <item> enthält:
      - eine <idno>-URI vom Typ wikidata (z.B. http://www.wikidata.org/entity/Q33393124)
      - eine <idno>-URI vom Typ wiengeschichtewiki, die aus dem Ergebnis der Wikidata-Abfrage
        (Property P7842) erzeugt wird. Hierbei wird der URL-Schnippsel vorangestellt.
    
    Nur <place>-Elemente, die eine Wikidata-URI besitzen und KEINE wiengeschichtewiki-URI, werden berücksichtigt.
    """
    parser = etree.XMLParser(remove_blank_text=True)
    tree = etree.parse(input_file, parser)
    root = tree.getroot()

    # Definiere den TEI-Namespace
    ns = {"tei": "http://www.tei-c.org/ns/1.0"}
    
    # Erstelle den Wurzelknoten für die neue XML-Ausgabe
    list_root = etree.Element("list")

    # Iteriere über alle <place>-Elemente im TEI-Namespace
    for place in root.xpath("//tei:place", namespaces=ns):
        wikidata_idno = place.find("tei:idno[@subtype='wikidata']", namespaces=ns)
        wgw_idno = place.find("tei:idno[@subtype='wiengeschichtewiki']", namespaces=ns)
        
        if wikidata_idno is not None and wgw_idno is None:
            wikidata_url = wikidata_idno.text.strip().rstrip("/")
            # Extrahiere die Q-ID (z. B. Q33393124)
            qid = wikidata_url.split("/")[-1]
            print(f"Verarbeite {qid} ...")
            
            # Abrufen des Wertes der Property P7842 von Wikidata
            wgw_value = get_wiengeschichtewiki_from_wikidata(qid)
            if wgw_value:
                print(f"  -> P7842 gefunden: {wgw_value}")
                # Erstelle den vollständigen wiengeschichtewiki-URL
                full_url = f"https://www.geschichtewiki.wien.gv.at/Special:URIResolver/?curid={wgw_value}"
                
                # Erstelle ein neues <item>-Element und füge die beiden <idno>-Elemente hinzu
                item = etree.SubElement(list_root, "item")
                idno_wd = etree.SubElement(item, "idno", type="URL", subtype="wikidata")
                idno_wd.text = wikidata_url
                idno_wgw = etree.SubElement(item, "idno", type="URL", subtype="wiengeschichtewiki")
                idno_wgw.text = full_url
            else:
                print(f"  -> P7842 nicht gefunden für {qid}")

    # Schreibe die neue XML-Struktur in die Ausgabedatei
    tree_out = etree.ElementTree(list_root)
    tree_out.write(output_file, encoding="utf-8", pretty_print=True, xml_declaration=True)

if __name__ == '__main__':
    # Ermittle den Pfad des aktuellen Scripts
    current_dir = os.path.dirname(os.path.realpath(__file__))
    # Gehe eine Ebene nach oben zum Projektordner
    project_root = os.path.abspath(os.path.join(current_dir, ".."))
    # Setze die relativen Pfade für die Eingabe- und Ausgabedateien
    input_file = os.path.join(project_root, "data", "indices", "listplace.xml")
    output_file = os.path.join(project_root, "data", "indices", "wiengeschichtewiki-nachtraege.xml")
    
    print(f"Eingabedatei: {input_file}")
    print(f"Ausgabedatei: {output_file}")
    
    process_xml(input_file, output_file)
