// Array zur Verwaltung der GeoJSON-Layer
const geoJsonLayers = [];

// Funktion zum Entfernen aller GeoJSON-Layer
function clearGeoJsonLayers() {
    geoJsonLayers.forEach(layer => map.removeLayer(layer));
    geoJsonLayers.length = 0; // Array leeren
}

// Funktion zum Laden von GeoJSON basierend auf einem Datum
function loadGeoJsonByDate(date) {
    const url = `https://raw.githubusercontent.com/wiener-moderne-verein/wienerschnitzler-data/main/editions/geojson/${date}.geojson`;

    // Entferne vorherige Layer
    clearGeoJsonLayers();

    // GeoJSON laden und anzeigen
    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error(`GeoJSON für ${date} nicht gefunden.`);
            }
            return response.json();
        })
        .then(data => {
            const newLayer = L.geoJSON(data, {
                style: function (feature) {
                    return {
                        color: '#FF3B30', // Linienfarbe
                        weight: 2, // Dicke der Linie
                        opacity: 1 // Deckkraft der Linie
                    };
                },
                pointToLayer: function (feature, latlng) {
                    return L.circleMarker(latlng, {
                        radius: 5,
                        color: '#007BFF', // Randfarbe
                        fillColor: '#FFFF00', // Füllfarbe
                        fillOpacity: 1, // Füllungsdeckkraft (1 = vollständig undurchsichtig)
                        weight: 2 // Optional: Randgewicht auf 0 setzen, um nur den Punkt zu sehen
                    });
                },
                onEachFeature: function (feature, layer) {
                    if (feature.properties) {
                        const title = feature.properties.title || 'Kein Titel';
                        const date = feature.properties.timestamp || 'Kein Datum';
            
                        // Erstelle den Link, falls ein Datum vorhanden ist
                        const link = date !== 'Kein Datum'
                            ? `<a href="https://schnitzler-tagebuch.acdh.oeaw.ac.at/entry__${date}.html" target="_blank">Tagebuch</a>`
                            : '';
            
                        // Popup-Inhalt
                        const popupContent = `
                            <b>${title}</b><br>
                            ${date}<br>
                            ${link}
                        `;
            
                        layer.bindPopup(popupContent, { maxWidth: 300 });
                    }
                }
            }).addTo(map);
            

            // Hinzufügen der neuen Layer-Referenz zur Liste
            geoJsonLayers.push(newLayer);

            // Karte an die neuen Daten anpassen
            if (newLayer.getLayers().length > 0) {
                map.fitBounds(newLayer.getBounds());
            } else {
                console.warn('Keine gültigen Features gefunden.');
            }
        })
        .catch(error => {
            console.error('Error loading GeoJSON:', error);
            clearGeoJsonLayers(); // Entferne alte Layer auch bei Fehlern
        });
}

// Funktion, um das Fragment in der URL zu aktualisieren
function updateUrlFragment(date) {
    if (window.location.hash.substring(1) !== date) {
        window.location.hash = date;
    }
}

// Funktion, um das Datum aus der URL zu lesen
function getDateFromUrl() {
    const hash = window.location.hash;
    return hash ? hash.substring(1) : null;
}

// Funktion zum Ändern des Datums in der Eingabe und URL
function setDateAndLoad(date) {
    document.getElementById('date-input').value = date;
    updateUrlFragment(date);
    loadGeoJsonByDate(date);
}

// Funktion zum Formatieren von Datum in ISO-String (YYYY-MM-DD)
function formatDateToISO(date) {
    return date.toISOString().split('T')[0];
}

// Funktion, um das aktuelle Datum um eine Anzahl Tage zu ändern
function changeDateByDays(currentDate, days) {
    const date = new Date(currentDate);
    date.setDate(date.getDate() + days);
    return formatDateToISO(date);
}

// Initialisierung der Karte
const map = L.map('map').setView([48.2082, 16.3738], 5);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 18
}).addTo(map);

// Eventlistener für das Datumseingabefeld
document.getElementById('date-input').addEventListener('change', function () {
    const date = this.value;
    if (date) {
        setDateAndLoad(date);
    }
});

// Eventlistener für den "Laden"-Button
document.getElementById('load-data').addEventListener('click', function () {
    const date = document.getElementById('date-input').value;
    if (date) {
        setDateAndLoad(date);
    }
});

// Eventlistener für den "Vorheriger Tag"-Button
document.getElementById('prev-day').addEventListener('click', function () {
    const dateInput = document.getElementById('date-input');
    const currentDate = dateInput.value;
    const newDate = changeDateByDays(currentDate, -1);
    setDateAndLoad(newDate);
});

// Eventlistener für den "Nächster Tag"-Button
document.getElementById('next-day').addEventListener('click', function () {
    const dateInput = document.getElementById('date-input');
    const currentDate = dateInput.value;
    const newDate = changeDateByDays(currentDate, 1);
    setDateAndLoad(newDate);
});

// Überwache Änderungen am URL-Fragment
window.addEventListener('hashchange', function () {
    const date = getDateFromUrl();
    if (date) {
        setDateAndLoad(date);
    }
});

// Initialisiere die Karte mit dem Datum aus der URL oder einem Standardwert
const initialDate = getDateFromUrl() || '1895-01-23';
setDateAndLoad(initialDate);

// Funktion zum Holen des Datums aus der URL nach "#"
function getDateFromUrl() {
    const hash = window.location.hash;
    return hash ? hash.substring(1) : null; // Gibt das Datum zurück, oder null, wenn kein Datum vorhanden ist
}

// Funktion zum Setzen des Links für "Schnitzler Chronik" basierend auf dem Datum aus der URL
function setSchnitzlerChronikLink() {
    let date = getDateFromUrl(); // Datum aus der URL holen
    
    // Wenn kein Datum vorhanden ist, setze den Standardwert '1999-01-01'
    if (!date) {
        date = '1999-01-01';
    }
    
    // Den Button holen
    const button = document.getElementById('schnitzler-chronik-btn');
    
    // Den Link des Buttons aktualisieren
    button.onclick = function() {
        window.open(`https://schnitzler-chronik.acdh.oeaw.ac.at/${date}.html`, '_blank');
    };
    
    // Optional: Den Button-Text mit dem Datum aktualisieren
    button.textContent = `Schnitzler Chronik`;  // Hier wird der Button-Text dynamisch angepasst
}

// Rufe die Funktion auf, um den Link beim Laden der Seite zu setzen
setSchnitzlerChronikLink();

// Überwache Änderungen am URL-Fragment, um den Link bei Änderungen der URL zu aktualisieren
window.addEventListener('hashchange', setSchnitzlerChronikLink);
 

