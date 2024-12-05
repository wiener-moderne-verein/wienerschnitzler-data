// Erstelle die Karte
var map = L.map('map').setView([48.2082, 16.3738], 5);

// Füge OpenStreetMap-Layer hinzu
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 18
}).addTo(map);

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

// Funktion zum Laden von GeoJSON basierend auf einem Datum
function loadGeoJsonByDate(date) {
    const url = `https://raw.githubusercontent.com/wiener-moderne-verein/wienerschnitzler-data/main/editions/geojson/${date}.geojson`;

    // Entferne vorherige Layer
    if (window.currentGeoJsonLayer) {
        map.removeLayer(window.currentGeoJsonLayer);
    }

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

                        // Popup-Inhalt
                        const popupContent = `
                            <b>${title}</b><br>
                            ${date}<br>
                            ${link}
                        `;

                        layer.bindPopup(popupContent);
                    }
                }
            }).addTo(map);

            // Karte an die neuen Daten anpassen
            map.fitBounds(window.currentGeoJsonLayer.getBounds());
        })
        .catch(error => console.error('Error loading GeoJSON:', error));
}

// Eventlistener für das Datumseingabefeld
document.getElementById('date-input').addEventListener('change', function () {
    const date = this.value;
    if (date) {
        loadGeoJsonByDate(date);
    }
});

// Eventlistener für den "Laden"-Button
document.getElementById('load-data').addEventListener('click', function () {
    const date = document.getElementById('date-input').value;
    if (date) {
        loadGeoJsonByDate(date);
    }
});

// Eventlistener für den "Vorheriger Tag"-Button
document.getElementById('prev-day').addEventListener('click', function () {
    const dateInput = document.getElementById('date-input');
    const currentDate = dateInput.value;
    const newDate = changeDateByDays(currentDate, -1);
    dateInput.value = newDate;
    loadGeoJsonByDate(newDate);
});

// Eventlistener für den "Nächster Tag"-Button
document.getElementById('next-day').addEventListener('click', function () {
    const dateInput = document.getElementById('date-input');
    const currentDate = dateInput.value;
    const newDate = changeDateByDays(currentDate, 1);
    dateInput.value = newDate;
    loadGeoJsonByDate(newDate);
});

// Initial laden
loadGeoJsonByDate(document.getElementById('date-input').value);
