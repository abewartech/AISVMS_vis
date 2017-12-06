# Load libraries
library("DBI")
library("RPostgreSQL")

# Load data from text file 
fishing_vessels_ARG_URY <- data.table::fread(input = "data/fishing-vessels-ARG-URY.txt", sep = "\t", strip.white = TRUE, blank.lines.skip = TRUE, header = TRUE, showProgress = TRUE)

# Change column names
colnames(fishing_vessels_ARG_URY) <- c("name", "signal", "registration", "country", "category", "length", "port")

# Get MMSI from DB looking by name
conn <- dbConnect(dbDriver("PostgreSQL"), dbname = "ais")

vesselNames <- stringr::str_replace_all(fishing_vessels_ARG_URY$name, "'", replacement = "`")
vesselNames <-  stringr::str_c(paste0("'", vesselNames, "'"), collapse = ", ")

# Select names and mmsi
qry1 <- paste0("SELECT name, mmsi FROM barcos WHERE barcos.name IN (", vesselNames, ");")
name.mmsi <- dbGetQuery(conn, qry1)

# Merge selection with fishing_vessels_ARG_URY (add found mmsi)
fishing_vessels_ARG_URY <- merge.data.frame(fishing_vessels_ARG_URY, name.mmsi, by = "name", all.x = TRUE)

# write.csv(fishing_vessels_ARG_URY, "fishing_vessels_ARG_URY.csv", row.names = FALSE)

# Get MMSI by scrapping MarineTraffic
vesselNames2 <- fishing_vessels_ARG_URY[which(is.na(fishing_vessels_ARG_URY$mmsi)),'name']
vesselNames2 <- stringr::str_replace_all(vesselNames2, "'", replacement = "`")
vesselNames2 <- stringr::str_replace_all(vesselNames2, " ", replacement = "%20")

# Scraping libraries
library('httr')
library('rvest')
library('stringr')

# Empty list
scrapVesselMMSI <- list()

# Download all the results
for (i in vesselNames2) {

  message(i)
    
  # 1. specify URL
  url <- paste("https://www.marinetraffic.com/en/ais/index/ships/all/shipname:", i, "/status:all", sep = "")
  message(paste("- Getting data from: ", url, sep = ""))
  
  # 2. download static HTML behind the URL
  x <- GET(url, add_headers('user-agent' = 'r'))
  
  if (x$status_code == 200)  {
    
    message("- Status: OK")
    
    # 3. parse static HTML behind the URL into an XML file
    url_parsed <- x %>% read_html()
    
    # 4. extract specific nodes with CSS (or XPath)
    #nodes1 <- html_nodes(url_parsed, '.search_index_link')
    tempDF <- html_table(url_parsed, header = TRUE)
  
  } 
  else {
    warning(paste("- Status error: ", url, " couldn't be downloaded"))
    tempDF <- -999
  }
  
  # Agregar datos a la lista
  scrapVesselMMSI <- append(scrapVesselMMSI, tempDF)
  
  message("\n")
  
}

# Find best match and sendt to data frame
scrapVesselMMSI.df <- matrix(ncol = 12)
colnames(scrapVesselMMSI.df) <- c("Flag", "Vessel ID", "MMSI", "Vessel Name", "Photo", "Type", "Latest Position", "Current Port", "Last Known Port", "Area", "Destination / Reported ETA", "My Fleet")    
scrapVesselMMSI.df <- as.data.frame(scrapVesselMMSI.df)

for (i in 1:length(scrapVesselMMSI)) {
  
  vessel <- stringr::str_replace_all(vesselNames2[[i]], "%20", " ")
  message(paste0(i, " - ", vessel))
  
  if (scrapVesselMMSI[[i]][1] != -999 | is.na(scrapVesselMMSI[[i]][1])) {
    
    tempdf <- subset(scrapVesselMMSI[[i]], `Vessel Name` == vessel)
  }
  else {
    tempdf <- data.frame()
  }
  
  if (nrow(tempdf) != 0) {
    
    for (j in 1:nrow(tempdf)) {
      
      if (tempdf$Area[j] == "East Coast South Ame" & !is.na(tempdf$Area[j])) {
        row <- tempdf[j,]
        break
      }
      
      else {
        row <- tempdf[1,]
      }
    }
  }
  
  else {
    row <- matrix(ncol = 12)
    colnames(row) <- c("Flag", "Vessel ID", "MMSI", "Vessel Name", "Photo", "Type", "Latest Position", "Current Port", "Last Known Port", "Area", "Destination / Reported ETA", "My Fleet")    
    row <- as.data.frame(row)
    row[1,4] <- vessel
  }
  
  scrapVesselMMSI.df <- rbind(scrapVesselMMSI.df, row)
}

rownames(scrapVesselMMSI.df) <- as.character(1:nrow(scrapVesselMMSI.df))

# Merge 
name.mmsi.scrap <- subset(scrapVesselMMSI.df, select = c(`Vessel Name`, MMSI))
colnames(name.mmsi.scrap) <- c("name", "mmsi")

# Merge selection with fishing_vessels_ARG_URY (add found mmsi)
fishing_vessels_ARG_URY <- merge.data.frame(fishing_vessels_ARG_URY, name.mmsi.scrap, by = "name", all.x = TRUE)






qry2 <- paste0("SELECT name, mmsi FROM barcos WHERE barcos.name LIKE '%", 'RAQUEL', "%' ;")





qry1 <- paste0("SELECT * FROM barcos WHERE barcos.mmsi IN (", '701019000', ");")
dbGetQuery(conn, qry1)


dbGetQuery(conn, "CREATE TABLE ctmfm ()")




# Seleccionar por categorías
catA <- subset(fishing_vessels_ARG_URY, categoría == "A", "nombre")
catA <- c("ATLANTIC BEATRICE", "ATLANTIC JANE", "ATLANTIC MARGARET", "ATLANTIC RUTHANN", "CORAL", "MARIAMME", "NILTO I", "PROMOPES I", "PROMOPES 2", "ZAANDAM", "ZURITA")



unique(fishing_vessels_ARG_URY$categoría)




