# Frontend-Migration: neue Datenformate und data-Branch

Stand: Juni 2026. Diese Anleitung beschreibt, was im Frontend
(`wienerschnitzler-static`, ggf. auch `wienerschnitzler-claude`) angepasst
werden muss, nachdem die Datenpipeline in diesem Repositorium umgestellt
wurde.

## Was sich an den Daten geändert hat

1. **Ergebnisdaten liegen auf dem Branch `data`, nicht mehr auf `main`.**
   Der Branch wird vom Workflow bei jedem Lauf als einzelner Commit neu
   erzeugt (Force-Push); `main` enthält nur noch Quelldaten und Pipeline.
2. **Tagesdateien sind durch Jahresbündel ersetzt.** Statt
   `geojson/1900-05-15.geojson` (~19.600 Dateien) gibt es
   `geojson/days/1900.json` (63 Dateien). Ein Jahresbündel ist ein
   JSON-Objekt mit einer GeoJSON-FeatureCollection pro belegtem Tag:
   ```json
   { "1900-05-15": { "type": "FeatureCollection", "features": [ ... ] },
     "1900-05-16": { ... } }
   ```
   Die FeatureCollection pro Tag ist strukturell identisch mit dem Inhalt
   der bisherigen Tagesdateien (siehe Punkte 4–6).
3. **Alle JSON-/GeoJSON-Ausgaben sind minifiziert** (kein Pretty-Print mehr).
   Für `JSON.parse`/`fetch().json()` ändert das nichts.
4. **Properties `lat` und `lon` entfallen** in allen Point-Features. Die
   Koordinaten stehen wie bisher in `geometry.coordinates` (`[lon, lat]`).
   Im Frontend wurde keine Stelle gefunden, die `properties.lat/lon` liest.
5. **LineString-Features entfallen, wenn es weniger als zwei
   unterschiedliche Koordinatenpaare gibt** (vorher: ungültige
   Ein-Punkt-LineStrings). Betrifft die Tages-FeatureCollections sowie
   `l_months`/`l_years`/`l_decades.geojson`. Der bestehende Code filtert
   ohnehin nach `geometry.type`, es ist also keine Änderung nötig — eine
   Ausnahme siehe unten bei `script_tag.js`.
6. **`uebersicht.json`: Feld `title` heißt jetzt `places`** und enthält nur
   noch die Ortsliste (z. B. `"Praterstraße 16 und Wien"`) statt des ganzen
   Satzes „Am 15. 5. 1862 hielt sich Schnitzler in Praterstraße 16 und Wien
   auf“. `date` und `weight` unverändert. Es sind auch keine vorab
   HTML-escapeten `&amp;` mehr enthalten, sondern rohes `&`.
7. **`wienerschnitzler_timeline.geojson` gibt es nicht mehr** (war seit
   April 2025 verwaist; `wienerschnitzler_timeline.json` bleibt unverändert
   bestehen, nur minifiziert).

## Reihenfolge der Umstellung (wichtig)

Damit die Website nie ins Leere greift:

1. Diese Pipeline-Änderungen auf `main` mergen — **ohne** `data/editions/`
   von `main` zu löschen. Die alten Dateien auf `main` bleiben so lange
   stehen (eingefroren auf dem letzten Stand), wie das Frontend sie noch
   liest.
2. Den Workflow „Update Data from PMB“ einmal manuell laufen lassen →
   erzeugt den Branch `data` mit den neuen Formaten.
3. Frontend anpassen und deployen (siehe unten).
4. Erst danach im Datenrepo aufräumen:
   ```bash
   git rm -r --cached data/editions
   # in .gitignore die auskommentierte Zeile "data/editions/" aktivieren
   git commit -m "Generierte Daten von main entfernt (liegen auf dem data-Branch)"
   ```

## Anpassungen in wienerschnitzler-static

### a) Basis-URL überall umstellen

Alle URLs der Form
`https://raw.githubusercontent.com/wiener-moderne-verein/wienerschnitzler-data/main/data/editions/...`
(auch die Varianten mit `refs/heads/main` und mit `data//editions`) ändern in:

```
https://raw.githubusercontent.com/wiener-moderne-verein/wienerschnitzler-data/data/data/editions/...
```

(Branchname `data`, danach der Pfad `data/editions/...`; mit `refs/heads/data`
statt des ersten `data` wird es lesbarer.)

Fundstellen (Stand heute): `html/js/script_tag.js`, `script_monat.js`,
`script_jahr.js`, `script_dekade.js`, `uebersicht.js`, `fuer-alle-karten.js`,
`schnitzler-und-ich.js`, `zeitleiste.js`, `xslt/index.xsl`,
`xslt/partials/html_navbar.xsl`. Am besten eine gemeinsame Konstante
`DATA_BASE_URL` einführen (z. B. in `fuer-alle-karten.js` oder
`translations.js`), statt die URL zehnmal zu wiederholen.

### b) `fetch_data.sh`: data-Branch-ZIP laden

```bash
curl -LO https://github.com/wiener-moderne-verein/wienerschnitzler-data/archive/refs/heads/data.zip
unzip data.zip
mv ./wienerschnitzler-data-data/data/ .
rm data.zip
rm -rf ./wienerschnitzler-data-data
```

### c) Tagesansicht (`script_tag.js`, ca. Zeile 204)

Bisher:
```js
const url = `…/geojson/${date}.geojson`;
fetch(url).then(r => r.json()).then(data => { /* data ist FeatureCollection */ });
```

Neu — Jahresbündel laden und Tag herausgreifen; das Bündel cachen, dann ist
das Blättern innerhalb eines Jahres ohne weiteren Request möglich:

```js
const dayBundleCache = {};

async function loadDay(date) {
  const year = date.slice(0, 4);
  if (!dayBundleCache[year]) {
    const response = await fetch(`${DATA_BASE_URL}/geojson/days/${year}.json`);
    if (!response.ok) throw new Error(`Daten für ${year} nicht gefunden.`);
    dayBundleCache[year] = await response.json();
  }
  // Tage ohne Beleg fehlen im Bündel:
  return dayBundleCache[year][date] ?? { type: 'FeatureCollection', features: [] };
}
```

Zwei Folgeänderungen in derselben Datei:

* Die „nicht gefunden“-Behandlung lief bisher über den HTTP-404 der
  Tagesdatei; jetzt ist sie der Fall `bundle[date] === undefined` (leere
  FeatureCollection im Snippet oben).
* Zeile 215 liest den Anzeigenamen aus dem ersten Feature
  (`data.features[0]?.properties?.name`). Das erste Feature ist nur noch
  dann eine Linie mit `name`, wenn der Tag mindestens zwei
  unterschiedliche Punkte hat. Das ausgeschriebene Datum besser direkt
  bauen — die Funktion `formatIsoDateToGerman(date)` existiert in der
  Datei bereits.

Gleiches Muster gilt für `script_tag_standalone.js`, falls dort ebenfalls
Tagesdateien geladen werden.

### d) Heatmap/Übersicht (`uebersicht.js`, ca. Zeile 179–190)

`e.title` gibt es nicht mehr; den Satz aus `date` und `places` bauen:

```js
events.forEach(e => {
  const key = dayjs(e.date).format('YYYY-MM-DD');
  eventByDate[key] = `Am ${dayjs(e.date).format('D. M. YYYY')} hielt sich Schnitzler in ${e.places} auf`;
});
```

(Für eine englische Seitenvariante entsprechend einen englischen Satz —
das war mit dem fertigen deutschen `title` bisher gar nicht möglich.)

### e) `make_geojson_enriched.py`

Das Skript liest bisher `data/editions/geojson/{date}.geojson` pro Tag.
Neu: pro Jahr `data/editions/geojson/days/{year}.json` einmal laden und die
Tages-FeatureCollections daraus nehmen:

```python
import json, os
from functools import lru_cache

@lru_cache(maxsize=None)
def load_year_bundle(year):
    path = os.path.join('data/editions/geojson/days', f'{year}.json')
    if not os.path.exists(path):
        return {}
    with open(path, encoding='utf-8') as f:
        return json.load(f)

# statt: open(f'data/editions/geojson/{date}.geojson')
geojson_data = load_year_bundle(date[:4]).get(date)
if geojson_data is None:
    geojson_data = {'type': 'FeatureCollection', 'features': []}  # wie bisher bei fehlender Datei
```

Ob das Skript weiterhin Einzeldateien nach `html/geojson/` schreibt oder
die Bündel durchreicht, ist eine Frontend-Entscheidung; für die bestehende
Standalone-Tagesseite können die Einzeldateien dort einfach weiter erzeugt
werden.

### f) Keine Änderung nötig (zur Kontrolle)

* `properties.timestamp`, `id`, `importance`, `title`, `wohnort`,
  `arbeitsort`, `wikipedia`, `wiengeschichtewiki`, `wikidata`, `geonames`,
  `abbr`, `type` bleiben unverändert erhalten (`wohnort`/`arbeitsort`
  inklusive `p_id` im Format `#12345`).
* Monats-/Jahres-/Dekadendateien (`1900-05.geojson`, `1900.geojson`,
  `1891-1900.geojson`) behalten Namen und Struktur (nur minifiziert,
  ohne `lat`/`lon`-Properties).
* `l_months`/`l_years`/`l_decades.geojson`: Struktur unverändert
  (`properties.month/year/decade` als String); Features mit weniger als
  zwei Punkten entfallen, identische aufeinanderfolgende Koordinaten sind
  zusammengefasst. Die bestehenden Filter funktionieren unverändert.
* `wienerschnitzler_timeline.json` und `complete.csv`: unverändert
  (Timeline minifiziert).
