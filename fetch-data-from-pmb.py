import os
import re
import csv
import xml.etree.ElementTree as ET
from xml.dom import minidom
import requests
from io import StringIO

# URLs zur XML- und CSV-Datei
xml_url = 'https://pmb.acdh.oeaw.ac.at/media/listplace.xml'
csv_url = 'https://pmb.acdh.oeaw.ac.at/media/relations.csv'

# Ordner zum Speichern der Dateien
output_folder = 'input-data'

# Erstelle den Ordner, falls er nicht existiert
if not os.path.exists(output_folder):
    os.makedirs(output_folder)

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

# Funktion zum Herunterladen und Bearbeiten der XML-Datei
def download_and_modify_xml(xml_url, output_xml):
    response = requests.get(xml_url)

    if response.status_code == 200:
        # Inhalt der heruntergeladenen Datei als Text
        xml_content = response.text

        # Ersetzen von "place__" durch "pmb"
        modified_content = xml_content.replace('place__', 'pmb')

        # Speichern der modifizierten Datei im Ordner
        with open(output_xml, 'w', encoding='utf-8') as file:
            file.write(modified_content)
        print(f'Datei erfolgreich heruntergeladen und modifiziert unter: {output_xml}')
    else:
        print(f'Fehler beim Herunterladen der Datei. Status Code: {response.status_code}')

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

    print(f'Die CSV-Datei wurde erfolgreich in {output_xml} umgewandelt.')

# Aufruf der Funktionen
xml_output_file = os.path.join(output_folder, 'listplace.xml')  # Pfad für die modifizierte XML-Datei
csv_output_file = os.path.join(output_folder, 'relations.xml')  # Pfad für die umgewandelte CSV-Datei

# 1. XML-Datei herunterladen, bearbeiten und speichern
download_and_modify_xml(xml_url, xml_output_file)

# 2. CSV-Datei herunterladen, in XML umwandeln und speichern
csv_to_xml_from_url(csv_url, csv_output_file)
