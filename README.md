# wienerschnitzler-data
This repository contains georeferenced data that allows for the precise, day-by-day visualization of Arthur Schnitzler's (1862–1931) whereabouts throughout his entire adult life.

Dieses Repositorium enthält georeferenzierte Daten, die es erlauben, den Aufenthaltsort von Arthur Schnitzler (1862–1931) für sein ganzes Erwachenenleben taggenau darzustellen.

Die Daten werden im Zuge des Forschungsprojekts »Wiener Schnitzler – Schnitzlers Wien« (Oktober 2024 und Februar 2025) erstellt. Gefördert von der Stadt Wien Kultur mit einer Projektförderung. 

## XML-Data

Three different files contain unabdridged data:

* wienerschnitzler_complete.xml: this is the main file. it contains an element "event" for each day containing *one* listPlace with all places from the day
* wienerschnitzler-complete_nested.xml: same as above with the difference, that the places are nested. I.e. the Vienna ferris wheel is located in the Wurstelprater is located in the Prater is located in the 2nd district … Only mentioned places are nested within each other. So if the Wurstelprater is not mentioned on the same day it would not appear in the hierarchy of the ferris wheel.
* wienerschnitzler_distinctPlaces.xml: is a transformation that lists all the places and the days Schnitzler visited them as a child-element

## geoJSON-Data


