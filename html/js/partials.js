 // Funktion, um Partials zu laden
 function loadPartial(selector, filePath) {
    fetch(filePath)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
            return response.text();
        })
        .then(data => {
            document.querySelector(selector).innerHTML = data;
        })
        .catch(error => {
            console.error(`Error loading partial: ${filePath}`, error);
        });
}

// Partials laden
loadPartial('#navbar', './partials/html_navbar.html');
loadPartial('#footer', './partials/html_footer.html');