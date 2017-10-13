
# Load libraries ----------------------------------------------------------

library("DBI")
library("RPostgreSQL")
library("jsonlite")

# Get vessel data ---------------------------------------------------------

conn <- dbConnect(dbDriver("PostgreSQL"), dbname = "ais")  # Connect to PostgreSQL
sql.vesselsNames <- "SELECT name, mmsi, flagcode FROM barcos;"
query.vesselsNames <- sqlInterpolate(conn, sql.vesselsNames)
getquery.vesselNames <- dbGetQuery(conn, query.vesselsNames)

# Create flag attribute link (revisar código de país NA para no eliminarlo como si fuese NA)
flags <- getquery.vesselNames$flagcode
flags[which(stringr::str_length(flags) != 4)] <- NA
flags <- stringr::str_extract(flags, "[A-Z]+")

links <- vector()

for(i in 1:length(flags)) {
  
  if(is.na(flags[i])) links[[i]] <- paste0("../img/ais.png")
  if(!is.na(flags[i])) links[[i]] <- paste0("https://www.marinetraffic.com/img/flags/png40/", flags[i], ".png")
}
  
# Convert to JSON ---------------------------------------------------------

getquery.vesselNames.t <- as.data.frame(rbind(getquery.vesselNames$name, links))
colnames(getquery.vesselNames.t) <- getquery.vesselNames$name
getquery.vesselNames.json <- toJSON(getquery.vesselNames.t[-1,], 'rows')

# Write to file -----------------------------------------------------------

write_json(getquery.vesselNames.json, path = "~/Documents/GitHub/AISVMS_vis/data/vessels.json")

# Load data

json <- read_json("../../data/vessels.json")

# Cambios al archivo JSON
# agregar variable, eliminar paréntesis rectos y agregar ";" al final. No eliminar comillas
# Tiene que quedar así: vessels = "{\"1\":\".