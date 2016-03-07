// Leaflet providers
var OpenStreetMap_Mapnik = L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 19,
  attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
});

var MapQuestOpen_OSM = L.tileLayer('http://otile{s}.mqcdn.com/tiles/1.0.0/{type}/{z}/{x}/{y}.{ext}', {
  type: 'map',
  ext: 'jpg',
  attribution: 'Tiles Courtesy of <a href="http://www.mapquest.com/">MapQuest</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  subdomains: '1234'
});

var Stamen_Toner = L.tileLayer('http://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.{ext}', {
  attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  subdomains: 'abcd',
  minZoom: 0,
  maxZoom: 20,
  ext: 'png'
});

var Esri_WorldImagery = L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
  attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'
});

// Map definition
var map = L.map('map', {
  center: [-35.259, -53.844],
  zoom: 7,
  layers: [OpenStreetMap_Mapnik, MapQuestOpen_OSM, Stamen_Toner, Esri_WorldImagery]
});

// Basemaps
var baseMaps = {
  "OpenStreetMaps": OpenStreetMap_Mapnik,
  "MapQuestOpen - OSM": MapQuestOpen_OSM,
  "Stamen Toner": Stamen_Toner,
  "Esri World Imagery": Esri_WorldImagery
};

/// Add a layer control element to the map
layerControl = L.control.layers(baseMaps, null, {
  position: 'topleft'
});
layerControl.addTo(map);
