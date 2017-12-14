
# Load libraries ----------------------------------------------------------

library("DBI")
library("RPostgreSQL")
library("jsonlite")
library("tidyverse")

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

# Load data from cat D ----------------------------------------------------

catD <- read.csv("data/fishing_vessels_ARG_URY.csv", header = TRUE)
catD <- subset(catD, category == 'D')

sql.vesselsNames <- paste0("SELECT name, mmsi FROM barcos WHERE mmsi IN (", stringr::str_c(catD$mmsi, collapse = ","), ") ORDER BY name;")
query.vesselsNames <- sqlInterpolate(conn, sql.vesselsNames)
getquery.vesselNames <- dbGetQuery(conn, query.vesselsNames)

catD.t <- as.data.frame(rbind(as.character(getquery.vesselNames$name), "img/flags-svg/uy.svg"))
colnames(catD.t) <- as.character(getquery.vesselNames$name)
catD.json <- toJSON(catD.t[,], 'rows')
write_json(catD.json, path = "data/catD.json")



# Load data from altura ---------------------------------------------------

altura <- read.csv("data/fishing_vessels_ARG_URY.csv", header = TRUE)
altura <- altura[which(stringr::str_detect(altura$category, "ALTURA")),]
altura <- altura[-which(is.na(altura$mmsi)),]

sql.vesselsNames <- paste0("SELECT name, mmsi FROM barcos WHERE mmsi IN (", stringr::str_c(altura$mmsi, collapse = ","), ") ORDER BY name;")
query.vesselsNames <- sqlInterpolate(conn, sql.vesselsNames)
getquery.vesselNames <- dbGetQuery(conn, query.vesselsNames)

# select(altura, mmsi, name) %>% filter(mmsi == 701000785)
# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 701000785;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'CODEPECA III' WHERE mmsi = 701000785;")

# select(altura, mmsi, name) %>% filter(mmsi == 701000646)
# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 701000646;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'ALVER' WHERE mmsi = 701000646;")

# select(altura, mmsi, name) %>% filter(mmsi == 701007020)
# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 701007020;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'INFINITUS PEZ' WHERE mmsi = 701007020;")
# 
# select(altura, mmsi, name) %>% filter(mmsi == 701007017)
# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 701007017;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'CABO DE HORNOS' WHERE mmsi = 701007017;")
# 
# select(altura, mmsi, name) %>% filter(mmsi == 701000622)
# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 701000622;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'PETREL' WHERE mmsi = 701000622;")
# 
# select(altura, mmsi, name) %>% filter(mmsi == 701000706)
# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 701000706;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'MADRE DIVINA' WHERE mmsi = 701000706;")

altura.t <- as.data.frame(rbind(as.character(getquery.vesselNames$name), "img/flags-svg/ar.svg"))
colnames(altura.t) <- as.character(getquery.vesselNames$name)
altura.json <- toJSON(altura.t[-1,], 'rows')
write_json(altura.json, path = "data/altura.json")


# Load data from costeros -------------------------------------------------

costeros <- read.csv("data/fishing_vessels_ARG_URY.csv", header = TRUE)
costeros <- costeros[which(stringr::str_detect(costeros$category, "COSTEROS")),]
costeros <- costeros[-which(is.na(costeros$mmsi)),]

sql.vesselsNames <- paste0("SELECT name, mmsi FROM barcos WHERE mmsi IN (", stringr::str_c(costeros$mmsi, collapse = ","), ") ORDER BY name;")
query.vesselsNames <- sqlInterpolate(conn, sql.vesselsNames)
getquery.vesselNames <- dbGetQuery(conn, query.vesselsNames)

# select(costeros, mmsi, name) %>% filter(mmsi == 701006236)
# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 701006236;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'ALVAREZ ENTRENA IV' WHERE mmsi = 701006236;")
# 
# select(costeros, mmsi, name) %>% filter(mmsi == 701006197)
# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 701006197;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'SIEMPRE DON VICENTE' WHERE mmsi = 701006197;")
# 
# select(costeros, mmsi, name) %>% filter(mmsi == 701006502)
# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 701006502;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'NONO PASCUAL' WHERE mmsi = 701006502;")
#  
# select(costeros, mmsi, name) %>% filter(mmsi == 701006426)
# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 701006426;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'VIRGEN DEL MILAGRO' WHERE mmsi = 701006426;")
#  
# select(costeros, mmsi, name) %>% filter(mmsi == 701006162)
# dbGetQuery(conn, "SELECT name, mmsi FROM barcos WHERE mmsi = 701006162;")
# dbGetQuery(conn, "UPDATE barcos SET name = 'DON RAUL' WHERE mmsi = 701006162;")

costeros.t <- as.data.frame(rbind(as.character(getquery.vesselNames$name), "img/flags-svg/ar.svg"))
colnames(costeros.t) <- as.character(getquery.vesselNames$name)
costeros.json <- toJSON(costeros.t[-1,], 'rows')
write_json(costeros.json, path = "data/costeros.json")
