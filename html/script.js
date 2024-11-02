// Erstelle die Karte und setze die Startansicht
var map = L.map('map', {
    center: [48.2082, 16.3738],
    zoom: 5,
    timeDimension: true,
    timeDimensionControl: true,
    timeDimensionControlOptions: {
        position: 'bottomleft',
        autoPlay: true,
        backwardButton: true,
        forwardButton: true,
        timeSlider: true,
        speedSlider: false,
        loopButton: true,
        playerOptions: {
            transitionTime: 1000,
            loop: true,
            startOver: true
        }
    },
    timeDimensionOptions: {
        timeInterval: "1869-01-01/1924-06-19",
        period: "P1D",
        currentTime: Date.parse("1869-01-01")
    }
});

// Füge die Kartenkacheln von OpenStreetMap hinzu
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 18,
}).addTo(map);

// Funktion, die jeden Datumswert als eigenes Feature im GeoJSON-Format erstellt
// Funktion, die jeden Datumswert als eigenes Feature im GeoJSON-Format erstellt
function expandDates(feature) {
    var features = [];
    if (feature.properties.dates && Array.isArray(feature.properties.dates)) {
        feature.properties.dates.forEach(date => {
            // Datum direkt verwenden, da es bereits im "YYYY-MM-DD"-Format ist
            var newFeature = {
                type: "Feature",
                geometry: feature.geometry,
                properties: {
                    ...feature.properties,
                    time: date // Nur das Datum im Format "YYYY-MM-DD" ohne Uhrzeit
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
                time: feature.properties.date // Nur das Datum übernehmen
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

        console.log(expandedData); // Überprüfe die erweiterten Daten in der Konsole

        // TimeDimension-Layer aus den erweiterten Daten erstellen
        var timeLayer = L.timeDimension.layer.geoJson(L.geoJSON(expandedData, {
            pointToLayer: function (feature, latlng) {
                return L.circleMarker(latlng, { radius: 5, color: 'red' });
            },
            onEachFeature: function (feature, layer) {
                // Popup für jeden Punkt mit Titel und Datum anzeigen
                if (feature.properties && feature.properties.title) {
                    layer.bindPopup(
                        `<b>${feature.properties.title}</b><br>${feature.properties.time}`
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
