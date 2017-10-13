-- SQL queries

-- sql.positions.counts
SELECT COUNT(*) 
FROM posiciones, barcos 
WHERE barcos.name = ?vesselName
AND posiciones.mmsi = barcos.mmsi
AND posiciones.speed BETWEEN ?vesselSpeedMin AND ?vesselSpeedMax
AND posiciones.timestamp BETWEEN ?dateFrom AND ?dateUntil;

-- sql.positions
SELECT posiciones.wkb_geometry,
       posiciones.mmsi,
       posiciones.status,
       posiciones.speed,
       posiciones.course,
       posiciones.heading,
       posiciones.timestamp
FROM posiciones, barcos 
WHERE barcos.name = ?vesselName
AND posiciones.mmsi = barcos.mmsi
AND posiciones.speed BETWEEN ?vesselSpeedMin AND ?vesselSpeedMax
AND posiciones.timestamp BETWEEN ?dateFrom AND ?dateUntil
ORDER BY RANDOM() LIMIT ?thresholdQuery;

