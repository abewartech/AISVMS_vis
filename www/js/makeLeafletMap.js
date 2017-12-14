// Leaflet providers
/*
var OpenStreetMap_Mapnik = L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 19,
  attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
});
*/

/*
var MapQuestOpen_OSM = L.tileLayer('http://otile{s}.mqcdn.com/tiles/1.0.0/{type}/{z}/{x}/{y}.{ext}', {
  type: 'map',
  ext: 'jpg',
  attribution: 'Tiles Courtesy of <a href="http://www.mapquest.com/">MapQuest</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  subdomains: '1234'
});
*/

/*
var Stamen_Toner = L.tileLayer('http://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.{ext}', {
  attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  subdomains: 'abcd',
  minZoom: 0,
  maxZoom: 20,
  ext: 'png'
});
*/


var MapBoxHybridSatellite = L.tileLayer('http://{s}.tiles.mapbox.com/v3/guzman.lgoi91mh/{z}/{x}/{y}.png', {
  attribution: '<a href=https://www.mapbox.com/about/maps/> &copy; Mapbox &copy; OpenStreetMap</a>'
});

var CartoDB_DarkMatter = L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png', {
	attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="http://cartodb.com/attributions">CartoDB</a>',
	subdomains: 'abcd',
	maxZoom: 19
});


var Esri_WorldImagery = L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
  attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'
});

/*
var HERE_normalDay = L.tileLayer('https://{s}.{base}.maps.cit.api.here.com/maptile/2.1/{type}/{mapID}/normal.day/{z}/{x}/{y}/{size}/{format}?app_id={app_id}&app_code={app_code}&lg={language}', {
	attribution: 'Map &copy; 1987-2014 <a href="http://developer.here.com">HERE</a>',
	subdomains: '1234',
	mapID: 'newest',
	app_id: '<your app_id>',
	app_code: '<your app_code>',
	base: 'base',
	maxZoom: 20,
	type: 'maptile',
	language: 'eng',
	format: 'png8',
	size: '256'
});
*/

/*
var HERE_hybridDay = L.tileLayer('https://{s}.{base}.maps.cit.api.here.com/maptile/2.1/{type}/{mapID}/hybrid.day/{z}/{x}/{y}/{size}/{format}?app_id={app_id}&app_code={app_code}&lg={language}', {
	attribution: 'Map &copy; 1987-2014 <a href="http://developer.here.com">HERE</a>',
	subdomains: '1234',
	mapID: 'newest',
	app_id: '<your app_id>',
	app_code: '<your app_code>',
	base: 'aerial',
	maxZoom: 20,
	type: 'maptile',
	language: 'eng',
	format: 'png8',
	size: '256'
});
*/

var Esri_OceanBasemap = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/Ocean_Basemap/MapServer/tile/{z}/{y}/{x}', {
	attribution: 'Tiles &copy; Esri &mdash; Sources: GEBCO, NOAA, CHS, OSU, UNH, CSUMB, National Geographic, DeLorme, NAVTEQ, and Esri',
	maxZoom: 13
});

// Map definition
var map = L.map('map', {
  center: [-35.259, -53.844],
  zoom: 7,
  layers: [CartoDB_DarkMatter,Esri_WorldImagery,Esri_OceanBasemap,MapBoxHybridSatellite]
});

// Basemaps
var baseMaps = {
  //"OpenStreetMaps": OpenStreetMap_Mapnik,
  //"MapQuestOpen - OSM": MapQuestOpen_OSM,
  //"HERE Hybrid": HERE_hybridDay, 
  //"HERE Normal": HERE_normalDay,
  "ESRI World Imagery": Esri_WorldImagery, 
  "CartoDB DarkMatter": CartoDB_DarkMatter,
  "ESRI Ocean Basemap": Esri_OceanBasemap,
  "MapBox Hybrid Satellite": MapBoxHybridSatellite
};

/// Add a layer control element to the map
layerControl = L.control.layers(baseMaps, null, {
  position: 'topleft'
});
layerControl.addTo(map);
