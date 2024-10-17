import re
import csv
import xml.etree.ElementTree as ET
from xml.dom import minidom
import requests
from io import StringIO

# URL zur CSV-Datei
csv_url = 'https://pmb.acdh.oeaw.ac.at/media/relations.csv'

# Funktion, um Inhalte in spitzen Klammern zu entfernen
def remove_angle_brackets(content):
    return re.sub(r'<.*?>', '', content)

# Funktion, um das XML-Dokument schön zu formatieren
def prettify_xml(elem):
    """Return a pretty-printed XML string for the Element."""
    rough_string = ET.tostring(elem, 'utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="    ")  # 4 Leerzeichen für Einrückung

# Funktion, um die CSV-Datei aus dem Internet zu laden
def load_csv_from_url(url):
    response = requests.get(url)
    response.raise_for_status()  # Fehlermeldung, falls die Anfrage fehlschlägt
    return StringIO(response.text)  # Die CSV-Inhalte als StringIO-Objekt zurückgeben

# CSV lesen und in XML umwandeln
def csv_to_xml_from_url(csv_url, output_xml):
    # XML-Baum und Haupt-Element erstellen
    root = ET.Element('root')

    # CSV-Daten aus der URL laden
    csv_data = load_csv_from_url(csv_url)
    
    # CSV-Datei lesen
    reader = csv.reader(csv_data)
    headers = next(reader)  # Erste Zeile (Spaltennamen) lesen
    
    # Über alle Zeilen der CSV-Datei iterieren
    for row in reader:
        # Überprüfen, ob der Wert '2121' in der Zeile vorkommt
        if '2121' in row:
            # Neues XML-Element für jede Zeile, die '2121' enthält
            item = ET.Element('row')
            for header, cell in zip(headers, row):
                # Inhalte in spitzen Klammern entfernen
                cleaned_cell = remove_angle_brackets(cell)
                
                # XML-Element für jedes Feld hinzufügen
                field = ET.SubElement(item, header)
                field.text = cleaned_cell
            
            # Dem Haupt-Element das Item hinzufügen
            root.append(item)
    
    # XML-Baum schön formatieren und in Datei schreiben
    pretty_xml = prettify_xml(root)
    with open(output_xml, 'w', encoding='utf-8') as f:
        f.write(pretty_xml)

    print("Die Datei wurde erfolgreich von der URL umgewandelt und formatiert gespeichert als:", output_xml)

# Aufruf der Funktion
output_xml = './input-data/relations.xml'  # Pfad für die Ausgabe-XML-Datei
csv_to_xml_from_url(csv_url, output_xml)
