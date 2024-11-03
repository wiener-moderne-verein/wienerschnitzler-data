// Create the map and set the initial view
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
        loopButton: false,
        timeFormat: "YYYY-MM-DD",
        playerOptions: {
            transitionTime: 1000,
            loop: false,
            startOver: false
        }
    },
    timeDimensionOptions: {
        timeInterval: "1869-01-01/1931-10-21",
        period: "P1D",
        currentTime: Date.parse("1890-01-01")
    }
});

// Add OpenStreetMap tile layer
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 18
}).addTo(map);

// Function to expand dates into individual GeoJSON features
function expandDates(feature) {
    var features = [];
    if (feature.properties.dates && Array.isArray(feature.properties.dates)) {
        feature.properties.dates.forEach(date => {
            var newFeature = {
                type: "Feature",
                geometry: feature.geometry,
                properties: {
                    ...feature.properties,
                    time: date // Use the date in "YYYY-MM-DD" format
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
                time: feature.properties.date // Use the date directly
            }
        };
        features.push(newFeature);
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
            features: []
        };
        
        data.features.forEach(feature => {
            expandedData.features.push(...expandDates(feature));
        });

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
            duration: 'P1D'
        });

        timeLayer.addTo(map);

        // Center the map initially to fit all bounds
        var initialBounds = geoJsonLayer.getBounds();
        map.fitBounds(initialBounds);

        // Adjust the view dynamically on time load
       map.timeDimension.on('timeload', function() {
           var visibleLayers = [];
           var currentTime = new Date(map.timeDimension.getCurrentTime()).toISOString().split('T')[0];

           // Find features for the current date
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
               map.fitBounds(currentBounds, {
                   padding: [10, 10], // Optional: Add padding around the bounds
                   maxZoom: 18 // Ensure it doesn't zoom in too much beyond max zoom level
               });
           }

           // Update the date display to remove time part
           var dateElement = document.querySelector('.leaflet-control-timecontrol.timecontrol-date');
           if (dateElement) {
               var newDate = currentTime; // Already formatted as YYYY-MM-DD
               dateElement.textContent = newDate;
           }
       });

    })
    .catch(error => console.error('Error loading GeoJSON data:', error));