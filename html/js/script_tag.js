// Funktion zum Entfernen aller GeoJSON-Layer
function clearGeoJsonLayers() {
    if (window.currentGeoJsonLayer) {
        map.removeLayer(window.currentGeoJsonLayer);
        window.currentGeoJsonLayer = null;
    }
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
            window.currentGeoJsonLayer = L.geoJSON(data, {
                pointToLayer: function (feature, latlng) {
                    return L.circleMarker(latlng, { radius: 5, color: 'red' });
                },
                onEachFeature: function (feature, layer) {
                    if (feature.properties) {
                        const title = feature.properties.title || 'Kein Titel';
                        const date = feature.properties.timestamp || 'Kein Datum';
                        
                        // Erstelle den Link, falls ein Datum vorhanden ist
                        const link = date !== 'Kein Datum'
                            ? `<a href="https://schnitzler-tagebuch.acdh.oeaw.ac.at/entry__${date}.html" target="_blank">Tagebuch</a>`
                            : '';

                        // Popup-Inhalt als HTML-String setzen
                        const popupContent = `
                            <b>${title}</b><br>
                            ${date}<br>
                            ${link}
                        `;

                        layer.bindPopup(popupContent, { maxWidth: 300 });
                    }
                }
            }).addTo(map);

            // Karte an die neuen Daten anpassen
            if (window.currentGeoJsonLayer.getLayers().length > 0) {
                map.fitBounds(window.currentGeoJsonLayer.getBounds());
            } else {
                console.warn('Keine gültigen Features gefunden.');
            }
        })
        .catch(error => console.error('Error loading GeoJSON:', error));
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
const initialDate = getDateFromUrl() || '1899-01-01';
setDateAndLoad(initialDate);
