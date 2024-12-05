// Create the map and set the initial view
var mapDaily = L.map('map', {
    center: [48.2082, 16.3738],
    zoom: 10,
    timeDimension: true,
    timeDimensionControl: true,
    timeDimensionControlOptions: {
        position: 'bottomleft',
        autoPlay: true,
        backwardButton: true,
        forwardButton: true,
        timeSlider: true,
        speedSlider: false,
        loopButton: false,
        timeFormat: "YYYY-MM",
        playerOptions: {
            transitionTime: 1000,
            loop: false,
            startOver: false
        }
    },
    timeDimensionOptions: {
        timeInterval: "1869-01-01/1931-12-31",
        period: "P1M",
        currentTime: Date.parse("1890-01-01")
    }
});

// Add OpenStreetMap tile layer
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 18
}).addTo(mapDaily);

// Function to expand dates into individual GeoJSON features
function expandDates(feature) {
    var features = [];
    if (feature.properties.dates && Array.isArray(feature.properties.dates)) {
        feature.properties.dates.forEach(date => {
            features.push({
                type: "Feature",
                geometry: feature.geometry,
                properties: {
                    ...feature.properties,
                    time: date.slice(0, 7) // Use the date in "YYYY-MM" format
                }
            });
        });
    } else if (feature.properties.date) {
        features.push({
            type: "Feature",
            geometry: feature.geometry,
            properties: {
                ...feature.properties,
                time: feature.properties.date.slice(0, 7) // Use the date in "YYYY-MM" format
            }
        });
    } else {
        features.push(feature);
    }
    return features;
}

// Load and expand GeoJSON data
fetch('https://raw.githubusercontent.com/wiener-moderne-verein/wienerschnitzler-data/refs/heads/main/editions/geojson/wienerschnitzler_complete_points.geojson')
    .then(response => response.json())
    .then(data => {
        var expandedData = {
            type: "FeatureCollection",
            features: data.features.flatMap(expandDates)
        };

        console.log(expandedData); // Check expanded data in the console

        // Create GeoJSON layer for TimeDimension
        var geoJsonLayer = L.geoJSON(expandedData, {
            pointToLayer: function (feature, latlng) {
                return L.circleMarker(latlng, { radius: 5, color: 'red' });
            },
            onEachFeature: function (feature, layer) {
                if (feature.properties && feature.properties.title) {
                    layer.bindPopup(
                        `<b>${feature.properties.title}</b><br>${feature.properties.time}`
                    );
                }
            }
        });

        var timeLayer = L.timeDimension.layer.geoJson(geoJsonLayer, {
            updateTimeDimension: true,
            updateTimeDimensionMode: 'replace',
            addlastPoint: true,
            duration: 'P1M'
        });

        timeLayer.addTo(mapDaily);

        // Center the map initially to fit all bounds
        var initialBounds = geoJsonLayer.getBounds();
        mapDaily.fitBounds(initialBounds);

        // Adjust the view dynamically on time load
        mapDaily.timeDimension.on('timeload', function() {
            var visibleLayers = [];
            var currentTime = new Date(mapDaily.timeDimension.getCurrentTime()).toISOString().slice(0, 7);

            // Find features for the current month
            geoJsonLayer.eachLayer(function(layer) {
                var feature = layer.feature;
                if (feature && feature.properties && feature.properties.time) {
                    if (feature.properties.time === currentTime) {
                        visibleLayers.push(layer.getLatLng());
                    }
                }
            });

            if (visibleLayers.length > 0) {
                var currentBounds = L.latLngBounds(visibleLayers);
                mapDaily.fitBounds(currentBounds, {
                    padding: [10, 10], // Optional: Add padding around the bounds
                    maxZoom: 18 // Ensure it doesn't zoom in too much beyond max zoom level
                });
            }

            // Update the date display to show only year and month
            var dateElement = document.querySelector('.leaflet-control-timecontrol.timecontrol-date');
            if (dateElement) {
                dateElement.textContent = currentTime;
            }
        });
    })
    .catch(error => console.error('Error loading GeoJSON data:', error));
