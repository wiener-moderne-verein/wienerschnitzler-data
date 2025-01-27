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
tei_url = 'https://pmb.acdh.oeaw.ac.at/network/tei/?source_kind=person&target_kind=place&edge_label=arbeitet+in&edge_label=wohnhaft+in'

# Ordner zum Speichern der Dateien
input_data_folder = './input-data'
indices_folder = './input-data'

# Kontrollvariablen zum Aktivieren/Deaktivieren der Schritte
RUN_DOWNLOAD_XML = True
RUN_CSV_TO_XML = True
RUN_EXTRACT_PART_OF = True
RUN_DOWNLOAD_TEI = True

# Funktion, um Inhalte in spitzen Klammern zu entfernen
def remove_angle_brackets(content):
    return re.sub(r'<.*?>', '', content)

# Funktion, um das XML-Dokument schön zu formatieren
def prettify_xml(elem):
    rough_string = ET.tostring(elem, 'utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="    ")

# Funktion, um die CSV-Datei aus dem Internet zu laden
def load_csv_from_url(url):
    response = requests.get(url)
    response.raise_for_status()
    return StringIO(response.text)

# Funktion, um die TEI-Datei herunterzuladen
def download_tei_file(url, output_folder):
    # Sicherstellen, dass der Ausgabepfad existiert
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # Fester Dateiname
    filename = "living-working-in.xml"
    output_path = os.path.join(output_folder, filename)

    try:
        # Datei herunterladen
        response = requests.get(url)
        response.raise_for_status()  # Überprüfen, ob die Anfrage erfolgreich war

        # Datei speichern
        with open(output_path, "wb") as file:
            file.write(response.content)

        print(f"Die TEI-Datei wurde erfolgreich heruntergeladen und in '{output_path}' gespeichert.")
    except requests.exceptions.RequestException as e:
        print(f"Fehler beim Herunterladen der Datei: {e}")

# Schritt 1: XML herunterladen und bearbeiten
def download_and_modify_xml(xml_url, output_xml):
    print("[1/3] XML-Datei wird heruntergeladen...")
    response = requests.get(xml_url)

    if response.status_code == 200:
        print("    [✓] Download erfolgreich.")
        xml_content = response.text
        print("    [>] Ersetze 'place__' durch 'pmb'...")
        modified_content = xml_content.replace('place__', 'pmb')
        with open(output_xml, 'w', encoding='utf-8') as file:
            file.write(modified_content)
        print(f"    [✓] Datei erfolgreich gespeichert unter: {output_xml}")
    else:
        print(f"    [✗] Fehler beim Herunterladen der Datei. Status Code: {response.status_code}")

# Schritt 2: CSV in XML umwandeln
def csv_to_xml_from_url(csv_url, output_xml):
    print("[2/3] CSV-Datei wird geladen und in XML umgewandelt...")
    root = ET.Element('root')
    csv_data = load_csv_from_url(csv_url)
    reader = csv.reader(csv_data)
    headers = next(reader)
    for row in reader:
        if '2121' in row:
            item = ET.Element('row')
            for header, cell in zip(headers, row):
                cleaned_cell = remove_angle_brackets(cell)
                field = ET.SubElement(item, header)
                field.text = cleaned_cell
            root.append(item)
    pretty_xml = prettify_xml(root)
    with open(output_xml, 'w', encoding='utf-8') as f:
        f.write(pretty_xml)
    print(f"    [✓] CSV-Daten erfolgreich in {output_xml} umgewandelt.")

# Schritt 3: "gehört zu"- und "enthält"-Zeilen extrahieren
def extract_part_of_and_contains(csv_url, output_xml):
    print("[3/3] 'gehört zu'- und 'enthält'-Zeilen werden extrahiert...")
    root = ET.Element('root')
    csv_data = load_csv_from_url(csv_url)
    reader = csv.reader(csv_data)
    headers = next(reader)
    
    for row in reader:
        if len(row) > 1:
            relation_type = row[1].strip()
            if relation_type == "gehört zu" or relation_type == "enthält":
                item = ET.Element('row')
                temp_fields = {}

                for header, cell in zip(headers, row):
                    cleaned_cell = remove_angle_brackets(cell)
                    
                    # Elemente, die mit "source" oder "target" beginnen, temporär speichern
                    if relation_type == "enthält" and (header.startswith("source") or header.startswith("target")):
                        if header.startswith("source"):
                            temp_fields[header.replace("source", "target")] = cleaned_cell
                        elif header.startswith("target"):
                            temp_fields[header.replace("target", "source")] = cleaned_cell
                    else:
                        field = ET.SubElement(item, header)
                        field.text = cleaned_cell
                
                # Temporär gespeicherte Elemente hinzufügen (vertauschte source/target-Felder)
                if relation_type == "enthält":
                    for key, value in temp_fields.items():
                        field = ET.SubElement(item, key)
                        field.text = value
                
                root.append(item)
    
    pretty_xml = prettify_xml(root)
    with open(output_xml, 'w', encoding='utf-8') as f:
        f.write(pretty_xml)
    print(f"    [✓] 'gehört zu'- und 'enthält'-Zeilen erfolgreich in {output_xml} gespeichert.")

# Pfade für die Dateien
listplace_output_file = os.path.join(indices_folder, 'listplace.xml')
csv_output_file = os.path.join(input_data_folder, 'relations.xml')
part_of_output_file = os.path.join(input_data_folder, 'partOf.xml')
tei_output_file = os.path.join(input_data_folder, 'living-working-in.xml')

# Sicherstellen, dass die Ordner existieren
os.makedirs(input_data_folder, exist_ok=True)
os.makedirs(indices_folder, exist_ok=True)

# Schrittweises Debugging ermöglichen
if RUN_DOWNLOAD_XML:
    download_and_modify_xml(xml_url, listplace_output_file)

if RUN_CSV_TO_XML:
    csv_to_xml_from_url(csv_url, csv_output_file)

if RUN_EXTRACT_PART_OF:
    extract_part_of_and_contains(csv_url, part_of_output_file)

if RUN_DOWNLOAD_TEI:
    download_tei_file(tei_url, input_data_folder)
