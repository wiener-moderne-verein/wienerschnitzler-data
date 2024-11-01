// Erstelle die Karte und setze die Startansicht
var map = L.map('map', {
    center: [48.2082, 16.3738],
    zoom: 5,
    timeDimension: true,
    timeDimensionControl: true,
    timeDimensionControlOptions: {
        position: 'bottomleft',
        autoPlay: false,
        backwardButton: true,
        forwardButton: true,
        timeSlider: true,
        speedSlider: false,
        timeSteps: 1,
        loopButton: true,
        playerOptions: {
            transitionTime: 1000,
            loop: true,
            startOver: true
        }
    },
    timeDimensionOptions: {
        timeInterval: "1891-01-01/1924-06-19",
        period: "P1D",
        currentTime: Date.parse("1891-01-01")
    }
});

// Füge die Kartenkacheln von OpenStreetMap hinzu
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 18,
}).addTo(map);

// Funktion, die jeden Datumswert als eigenes Feature im GeoJSON-Format erstellt
function expandDates(feature) {
    var features = [];
    if (feature.properties.date && Array.isArray(feature.properties.date)) {
        feature.properties.date.forEach(date => {
            var newFeature = {
                type: "Feature",
                geometry: feature.geometry,
                properties: {
                    ...feature.properties,
                    time: new Date(date).toISOString() // Konvertieren Sie das Datum in einen ISO8601-String
                }
            };
            features.push(newFeature);
        });
    } else if (feature.properties.date) {
        var newFeature = {
            type: "Feature",
            geometry: feature.geometry,
            properties: {
                ...feature.properties,
                time: new Date(feature.properties.date).toISOString() // Einzelnes Datum konvertieren
            }
        };
        features.push(newFeature);
    } else {
        features.push(feature);
    }
    return features;
}

// GeoJSON-Daten von GitHub laden und erweitern
fetch('https://raw.githubusercontent.com/wiener-moderne-verein/wienerschnitzler-data/refs/heads/main/editions/geojson/wienerschnitzler_complete_points.geojson')
    .then(response => response.json())
    .then(data => {
        // Erweiterte Datenstruktur erstellen
        var expandedData = {
            type: "FeatureCollection",
            features: []
        };
        
        data.features.forEach(feature => {
            expandedData.features.push(...expandDates(feature));
        });

        // TimeDimension-Layer aus den erweiterten Daten erstellen
        var timeLayer = L.timeDimension.layer.geoJson(L.geoJSON(expandedData, {
            pointToLayer: function (feature, latlng) {
                return L.circleMarker(latlng, { radius: 5, color: 'red' });
            },
            onEachFeature: function (feature, layer) {
                // Popup für jeden Punkt mit Titel und Datum anzeigen
                if (feature.properties && feature.properties.title) {
                    layer.bindPopup(
                        `<b>${feature.properties.title}</b><br>${feature.properties.timestamp}`
                    );
                }
            }
        }), {
            updateTimeDimension: true,
            updateTimeDimensionMode: 'replace',
            addlastPoint: true,
            duration: 'P1D'
        });

        timeLayer.addTo(map);
    })
    .catch(error => console.error('Fehler beim Laden der GeoJSON-Daten:', error));
