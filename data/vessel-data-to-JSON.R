
# Load libraries ----------------------------------------------------------

library("DBI")
library("RPostgreSQL")
library("jsonlite")

# Get vessel data ---------------------------------------------------------

conn <- dbConnect(dbDriver("PostgreSQL"), dbname = "ais")  # Connect to PostgreSQL
sql.vesselsNames <- "SELECT name, mmsi, flag, flagcode FROM barcos;"
query.vesselsNames <- sqlInterpolate(conn, sql.vesselsNames)
getquery.vesselNames <- dbGetQuery(conn, query.vesselsNames)

# Create flag attribute link (revisar código de país NA para no eliminarlo como si fuese NA)
flags <- getquery.vesselNames$flagcode
flags[which(stringr::str_length(flags) != 4)] <- NA
flags <- stringr::str_extract(flags, "[A-Z]+")
flags <- stringr::str_trim(flags)

links <- vector()

for (i in 1:length(flags)) {
  
  if (is.na(flags[i]) | stringr::str_length(flags[i]) != 2) {links[[i]] <- paste0("img/ais.png")}
  if (!is.na(flags[i]) & stringr::str_length(flags[i]) == 2) {links[[i]] <- paste0("img/flags-svg/", stringr::str_to_lower(flags[i]), ".svg")}
}

# Convert to JSON ---------------------------------------------------------

getquery.vesselNames.t <- as.data.frame(rbind(getquery.vesselNames$name, links))
colnames(getquery.vesselNames.t) <- getquery.vesselNames$name
getquery.vesselNames.json <- toJSON(getquery.vesselNames.t[-1,], 'rows')

# Write to file -----------------------------------------------------------

write_json(getquery.vesselNames.json, path = "~/Documents/GitHub/AISVMS_vis/data/vessels.json")

# Cambios al archivo JSON
# agregar variable, eliminar paréntesis rectos y agregar ";" al final. No eliminar comillas
# Tiene que quedar así: vessels = "{\"1\":\".


# Load data from cat A ----------------------------------------------------

catA <- read.csv("data/fishing_vessels_ARG_URY.csv", header = TRUE)
catA <- subset(catA, category == 'A')

sql.vesselsNames <- paste0("SELECT name, mmsi FROM barcos WHERE mmsi IN (", stringr::str_c(catA$mmsi, collapse = ","), ") ORDER BY name;")
query.vesselsNames <- sqlInterpolate(conn, sql.vesselsNames)
getquery.vesselNames <- dbGetQuery(conn, query.vesselsNames)

# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 770576059;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'ATLANTIC RUTHANN' WHERE mmsi = 770576059;")

catA.t <- as.data.frame(rbind(as.character(getquery.vesselNames$name), "img/flags-svg/uy.svg"))
colnames(catA.t) <- as.character(getquery.vesselNames$name)
catA.json <- toJSON(catA.t[-1,], 'rows')
write_json(catA.json, path = "data/catA.json")

# Load data from cat B ----------------------------------------------------

catB <- read.csv("data/fishing_vessels_ARG_URY.csv", header = TRUE)
catB <- subset(catB, category == 'B')

sql.vesselsNames <- paste0("SELECT name, mmsi FROM barcos WHERE mmsi IN (", stringr::str_c(catB$mmsi, collapse = ","), ") ORDER BY name;")
query.vesselsNames <- sqlInterpolate(conn, sql.vesselsNames)
getquery.vesselNames <- dbGetQuery(conn, query.vesselsNames)

# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 770576238;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'AINOHA' WHERE mmsi = 770576238;")
# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 770576050;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'MAXAL II' WHERE mmsi = 770576050;")


catB.t <- as.data.frame(rbind(as.character(getquery.vesselNames$name), "img/flags-svg/uy.svg"))
colnames(catB.t) <- as.character(getquery.vesselNames$name)
catB.json <- toJSON(catB.t[-1,], 'rows')
write_json(catB.json, path = "data/catB.json")

# Load data from cat C ----------------------------------------------------

catC <- read.csv("data/fishing_vessels_ARG_URY.csv", header = TRUE)
catC <- subset(catC, category == 'C')
catC <- catC[-which(is.na(catC$mmsi)),]

sql.vesselsNames <- paste0("SELECT name, mmsi FROM barcos WHERE mmsi IN (", stringr::str_c(catC$mmsi, collapse = ","), ") ORDER BY name;")
query.vesselsNames <- sqlInterpolate(conn, sql.vesselsNames)
getquery.vesselNames <- dbGetQuery(conn, query.vesselsNames)

# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 770576238;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'AINOHA' WHERE mmsi = 770576238;")
# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 770576050;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'MAXAL II' WHERE mmsi = 770576050;")

catC.t <- as.data.frame(rbind(as.character(getquery.vesselNames$name), "img/flags-svg/uy.svg"))
colnames(catC.t) <- as.character(getquery.vesselNames$name)
catC.json <- toJSON(catC.t[-1,], 'rows')
write_json(catC.json, path = "data/catC.json")


