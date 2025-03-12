# wienerschnitzler-data

This repository contains georeferenced data enabling a precise, day-by-day visualization of Arthur Schnitzler's (1862–1931) whereabouts throughout his entire adult life.

Dieses Repository enthält georeferenzierte Daten, die eine taggenaue Darstellung der Aufenthaltsorte von Arthur Schnitzler (1862–1931) während seines gesamten Erwachsenenlebens ermöglichen.

Die Daten werden im Rahmen des Forschungsprojekts „Wiener Schnitzler – Schnitzlers Wien“ (Oktober 2024 bis Februar 2025) erstellt. Das Projekt wird mit einer Förderung der Stadt Wien Kultur unterstützt.

## XML Data

The repository includes three XML files containing the complete data ('./data/editions/xml'):

* __wienerschnitzler_complete.xml__: This is the main file. It contains an event element for each day, which includes one listPlace element with all the places visited on that day.
* __wienerschnitzler_complete_nested.xml__: Similar to the main file, but with nested structures. For example, the Vienna Ferris Wheel is nested within the Wurstelprater, which is nested within the Prater, which is located in the 2nd district. Only mentioned places are included in the hierarchy; if the Wurstelprater is not explicitly mentioned on a given day, it will not appear in the hierarchy of the Ferris Wheel.
* __wienerschnitzler_distinctPlaces.xml__: This is a transformation listing all places visited by Schnitzler, with the corresponding days as child elements.

In the folder ('./data/indices/') is __listplace.xml__ – an abbreviated version of the file with the same name that can be found in './input-data/'. In the same folder __partOf.xml__ contains information regarding places and the bigger entities they belong to (i.e. Vienna is part of Austria). The file __living-working-in.xml__ collects names of people that lived or worked in a house at a point in time.


## GeoJSON Data

Several derivative files are generated from the XML files above, mostly by referencing coordinates and idno values from the listplace.xml file found in the input-data folder. These files include:

* Files for each __day__, named using the ISO date format (e.g., 1888-01-24.geojson).
* Files for each __month__ (e.g., 1903-12.geojson).
* Files for each __year__ (e.g., 1890.geojson).
* Files for each __decade__ from 1870 to 1929 (e.g., 1920-1929.geojson).

Additionally, there are complete geoJSON files:

* __wienerschnitzler_complete_daily.geojson__: Uses days as the hierarchical structure.
* __wienerschnitzler_distinctPlaces.geojson__: Uses places as the hierarchical structure.


## Import Data ##

The main source for all the data is PMB – Personen der Moderne Basis, https://pmb.acdh.oeaw.ac.at/ – and more specifically https://pmb.acdh.oeaw.ac.at/media/

Running `python3 fetch-data-from-pmb.py` fetches several files from PMB, immediately transforms them and stores them in `./input-data/`:
* `listplace.xml` (main change: the attribute XML:id is changed from `place__XXXX` to `pmbXXXX`
* `living-working-in.xml`
* `relations.xml`

The latter file relations.xml is used to create the file `partOf.xml`. 

Now several XSL-Transformations have to take place, most of them in this order:

* transform partOf.xml to the cleaner version (i.e. `<item id="142812">
         <contains id="29620"/>
      </item>)`
* transform living-working-in.xml (this is slow as it fetches the names live from the PMB-website). It could be speeded up considerably if one would get the names out of the downloaded files itself but for exactness the slow process is preferable.
* transform relations.xml to wienerschnitzler_complete.xml
* transform wienerschnitzler_complete.xml to wienerschnitzler_complete_nested.xml (This has to be done in 2 steps: first run the transformation on the complete-file, then run the second transformation on the result complete_nested.xml-file)
* transform wienerschnitzler_complete to wienerschnitzler_distinctPlaces
* transform input-data/listplace.xml to data/editions/indices/listplace.xml (this abbreviates the listplace-file but is only up to date if the distinct-places-file was updated before)
