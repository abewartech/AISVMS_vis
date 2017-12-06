library(dygraphs)
library(DBI)
library(RPostgreSQL)
library(xts)

# Connection to DB
conn <- dbConnect(dbDriver("PostgreSQL"), dbname = "ais")

# Select vessels from DB
qry1 <- paste0(
"SELECT posiciones.mmsi, barcos.name, posiciones.speed, posiciones.timestamp 
FROM posiciones, barcos 
WHERE barcos.mmsi = posiciones.mmsi AND
barcos.name IN ('PROMAR XXI','PROMAR XXII');"
)
barcos <- dbGetQuery(conn, qry1)

# Sample
barcos.sample <- barcos[sample(1:nrow(barcos), 8000),]
barcos.sample$speed <- barcos.sample$speed/10
barcos.sample <- barcos.sample[-which(barcos.sample$speed > 15),]

# Convertir a xts
barcos.xts <- as.xts(barcos.sample, order.by = barcos.sample$timestamp, dateFormat = "POSIXct")

# Plot
v1 <- subset(barcos.xts, subset = name == "PROMAR XXI", select = speed)
v2 <- subset(barcos.xts, subset = name == "PROMAR XXII", select = speed)
v <- cbind(v1, v2)

dygraph(barcos.xts[,3], main = "PROMAR XXI y PROMAR XXII") %>%
  # dySeries("speed", drawPoints = TRUE, pointSize = 4, strokeWidth = 0, 
  #          label = "PROMAR XXI") %>%
  # dySeries("speed.1", drawPoints = TRUE, pointSize = 4, strokeWidth = 0, 
  #          label = "PROMAR XXII") %>%   
dyAxis("y", label = "Velocidad (kn)") %>%
  dyOptions(drawGrid = TRUE,  drawPoints = TRUE, 
            pointSize = 4, strokeWidth = 0) %>%
  dyEvent(x = '2013-04-30 00:00:00', label = "Puerto", labelLoc = "top",
          color = "grey", strokePattern = "solid") %>%
  dyHighlight(highlightCircleSize = 5,
              highlightSeriesBackgroundAlpha = 0.5, highlightSeriesOpts = list(),
              hideOnMouseOut = TRUE) %>%
  dyRangeSelector()


# Encontrar puntos en puerto