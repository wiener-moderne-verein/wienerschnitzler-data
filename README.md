# wienerschnitzler-data

This repository contains georeferenced data enabling a precise, day-by-day visualization of Arthur Schnitzler's (1862–1931) whereabouts throughout his entire adult life.

Dieses Repository enthält georeferenzierte Daten, die eine taggenaue Darstellung der Aufenthaltsorte von Arthur Schnitzler (1862–1931) während seines gesamten Erwachsenenlebens ermöglichen.

Die Daten werden im Rahmen des Forschungsprojekts „Wiener Schnitzler – Schnitzlers Wien“ (Oktober 2024 bis Februar 2025) erstellt. Das Projekt wird mit einer Förderung der Stadt Wien Kultur unterstützt.

## XML Data

The repository includes three XML files containing the complete data:

* __wienerschnitzler_complete.xml__: This is the main file. It contains an event element for each day, which includes one listPlace element with all the places visited on that day.
* __wienerschnitzler_complete_nested.xml__: Similar to the main file, but with nested structures. For example, the Vienna Ferris Wheel is nested within the Wurstelprater, which is nested within the Prater, which is located in the 2nd district. Only mentioned places are included in the hierarchy; if the Wurstelprater is not explicitly mentioned on a given day, it will not appear in the hierarchy of the Ferris Wheel.
* __wienerschnitzler_distinctPlaces.xml__: This is a transformation listing all places visited by Schnitzler, with the corresponding days as child elements.

## geoJSON Data

Several derivative files are generated from the XML files above, mostly by referencing coordinates and idno values from the listplace.xml file found in the input-data folder. These files include:

* Files for each __day__, named using the ISO date format (e.g., 1888-01-24.geojson).
* Files for each __month__ (e.g., 1903-12.geojson).
* Files for each __year__ (e.g., 1890.geojson).
* Files for each __decade__ from 1870 to 1929 (e.g., 1920-1929.geojson).

Additionally, there are complete geoJSON files:

* __wienerschnitzler_complete_daily.geojson__: Uses days as the hierarchical structure.
* __wienerschnitzler_distinctPlaces.geojson__: Uses places as the hierarchical structure.
