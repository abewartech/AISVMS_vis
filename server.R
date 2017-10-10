
# Packages -----------------------------------------------------

library("shiny")
library("fasttime")
library("lubridate")
library("DBI")
library("RPostgreSQL")
library("sf")
library("wkb")

# Global data -------------------------------------------------

# Initial date values
dateFrom <- fastPOSIXct("2012-05-08 19:47:00 -03")
dateUntil <- fastPOSIXct("2014-05-17 11:15:00 -03")
dateFromQuery <- dateFrom
dateUntilQuery <- dateUntil

# Define number of points shown threshold
threshold <- 1000

# First map data
vista_inicial = TRUE

# All vessel mmsi
conn <- dbConnect(dbDriver("PostgreSQL"), dbname = "ais")  # Connect to PostgreSQL
sql.vesselsNames <- "SELECT DISTINCT(mmsi) FROM barcos;"
query.vesselsNames <- sqlInterpolate(conn, sql.vesselsNames)
getquery.vesselNames <- dbGetQuery(conn, query.vesselsNames)
# dbDisconnect(conn)  # Disconnect 

print("Vista inicial...")
sql.positions <- "SELECT * FROM vista_inicial LIMIT ?threshold;"
query.positions <- sqlInterpolate(conn, sql.positions, threshold = threshold)
getquery.positions <- dbGetQuery(conn, query.positions)
print("Disconnecting...")
positionsQry <- cbind(readWKB(hex2raw(getquery.positions$wkb_geometry))@coords, 
                getquery.positions[-c(1, 2)])
dbDisconnect(conn)  # Disconnect

# Shiny Server -----------------------------------------------

shinyServer(function(input, output) {
  
  # Data --------------------------------------------------------
  
  positionsQry <- reactive({
    
    # Conectar con PostgreSQL
    conn <- dbConnect(dbDriver("PostgreSQL"), dbname = "ais")
    
    if (vista_inicial) {
      
      print("Vista inicial...")
      sql.positions <- "SELECT * FROM vista_inicial LIMIT ?threshold;"
      query.positions <- sqlInterpolate(conn, sql.positions, threshold = threshold)
      getquery.positions <- dbGetQuery(conn, query.positions)
      print("Disconnecting...")
      dbDisconnect(conn)  # Disconnect
      points <- cbind(readWKB(hex2raw(getquery.positions$wkb_geometry))@coords, 
                      getquery.positions[-c(1, 2)])
      
      return(points)
      
    } else {
      
      # Query time
      if (input$dateFrom == "") {
        
        dateFromQuery <- dateFrom
        
      } else {
        
        dateFromQuery <- input$dateFrom
        
      }
      
      if (input$dateUntil == "") {
        
        
        dateUntilQuery <- dateUntil
        
      } else {
        
        dateUntilQuery <- input$dateUntil
        
      }
      
      print("getquery.positions.count...")
      sql.positions.counts <- "SELECT COUNT(*) FROM posiciones 
      WHERE timestamp BETWEEN ?dateFrom AND ?dateUntil;"
      query.positions.counts <- sqlInterpolate(conn, sql.positions.counts, 
                                               dateFrom = as.character(dateFromQuery), 
                                               dateUntil = as.character(dateUntilQuery))
      getquery.positions.counts <- dbGetQuery(conn, query.positions.counts)
      
      if (getquery.positions.counts$count > threshold) {
        
        print("getquery.positions > threshold...")
        sql.positions <- "SELECT * FROM posiciones 
        WHERE timestamp BETWEEN ?dateFrom AND ?dateUntil
        ORDER BY RANDOM() LIMIT ?threshold;"
        query.positions <- sqlInterpolate(conn, sql.positions, 
                                          dateFrom = as.character(dateFromQuery), 
                                          dateUntil = as.character(dateUntilQuery), 
                                          threshold = as.character(threshold))
        getquery.positions <- dbGetQuery(conn, query.positions)
        
      } else {
        
        print("getquery.positions < threshold...")
        sql.positions <- "SELECT * FROM posiciones 
        WHERE timestamp BETWEEN ?dateFrom AND ?dateUntil;"
        query.positions <- sqlInterpolate(conn, sql.positions, 
                                          dateFrom = as.character(dateFromQuery), 
                                          dateUntil = as.character(dateUntilQuery))
        getquery.positions <- dbGetQuery(conn, query.positions)
        
      }
      
      # Query vessel name
      
      if (input$searchVesselName == "") {
        
        if (is.null(input$selectVesselName)) {
          
          VesselNameQuery <- getquery.vesselNames$mmsi
          
        } else {
          
          VesselNameQuery <- input$selectVesselName
          
        }
      } else {
        
        VesselNameQuery <- input$searchVesselName
        
      }
      
      if (length(VesselNameQuery) > 0) {
        
        sql.positions <- "SELECT * FROM posiciones 
        WHERE timestamp BETWEEN ?dateFrom AND ?dateUntil
        AND mmsi = ?mmsi;"
        query.positions <- sqlInterpolate(conn, sql.positions, 
                                          dateFrom = as.character(dateFromQuery), 
                                          dateUntil = as.character(dateUntilQuery), 
                                          mmsi = VesselNameQuery)
        getquery.positions <- dbGetQuery(conn, query.positions)
        
      }
      
      # Disconnect
      print("Disconnecting...")
      dbDisconnect(conn)
      
      points <- cbind(readWKB(hex2raw(getquery.positions$wkb_geometry))@coords, 
                      getquery.positions[-c(1, 2)])
      
      return(points)
    }
    
  })
  
  # Point cloud -------------------------------------------------
  
  output$plot <- renderPlot({
    
    positionsQry <- positionsQry()
    
    plot <- plot(x = positionsQry$x, 
                 y = positionsQry$y, 
                 xlab = "Longitud", 
                 ylab = "Latitud", pch = 19, col = "black")
    
    return(plot)
    
  })
  
  # Mapa -------------------------------------------------------- 
  
  output$divHtml <- renderUI({
    
    radius <- input$radius
    colorGradient <- input$color
    opacity <- input$opacity
    blur <- input$blur
    
    positionsQry <- positionsQry()
    
    print("divHtml")
    
    numberOfVessels <- length(unique(positionsQry$mmsi))
    
    # number of rows to toast Materialize.toast(message, displayLength,
    # className, completeCallback);
    toast <- paste("Materialize.toast('<i class=material-icons>location_on </i>", 
                   nrow(positionsQry), " posiciones ', 8000, 'rounded');", sep = "")
    toast2 <- paste("Materialize.toast('<i class=material-icons>info_outline </i>", 
                    numberOfVessels, " barcos ', 9500, 'rounded');", sep = "")
    
    j <- paste0("[", positionsQry[, "y"], ",", positionsQry[, "x"],"]", 
                collapse = ",")
    j <- paste0("[", j, "]")
    
    mapa <- HTML(paste("<script>", 
                       sprintf("var buildingsCoords = %s;", j), 
                       "buildingsCoords = buildingsCoords.map(function(p) {return [p[0], p[1]];});
                       if(map.hasLayer(heat)) {map.removeLayer(heat);};
                       var heat = L.heatLayer(buildingsCoords, {minOpacity:", 
                       opacity, ", radius:", radius, colorGradient, ", blur:", blur, 
                       "}).addTo(map);", toast, toast2, "</script>"), sep = "")
    
    return(mapa)
    
  })
  
  # Table of data ---------------------------------------------
  
  output$table <- renderDataTable({
    
    positionsQry()
    
  })
  
  
  # Select vessel name -----------------------------------
  
  output$selectVesselName <- renderUI({
    
    # Subset
    positionsQry <- positionsQry()
    
    # All vessels names and total number
    vesselNames2 <- positionsQry$mmsi
    numberOfVessels <- length(vesselNames2)
    
    # Selected vessels names
    vesselNamesSelected <- unique(positionsQry$mmsi)
    
    # Mark as selected options the previously selected vessels
    
    if (numberOfVessels == length(vesselNamesSelected)) {
      
      options <- list()
      
      for (i in 1:numberOfVessels) {
        options[[i]] <- paste("<option value='", vesselNames2[i], "'>", 
                              vesselNames2[i], "</option>", sep = "")
      }
      
      options <- do.call("rbind", options)
      
    } else {
      
      listSelectedVessels <- list()
      
      for (i in 1:numberOfVessels) {
        
        listSelectedVessels[[i]] <- which(vesselNames2[i] == vesselNamesSelected)
        
      }
      
      listSelectedVessels <- which(sapply(listSelectedVessels, length) > 0)
      lengthListSelectedVessels <- length(listSelectedVessels)
      
      options <- list()
      
      for (i in 1:numberOfVessels) {
        
        encontrado <- FALSE
        
        j <- 1
        
        while (j <= lengthListSelectedVessels & !encontrado) {
          
          if (i == listSelectedVessels[j]) {
            
            encontrado <- TRUE
            # print('encontrado')
            
          }
          
          j <- j + 1
          
        }
        
        if (encontrado) {
          options[[i]] <- paste("<option value='", vesselNames2[i], 
                                "' selected>", vesselNames2[i], "</option>", sep = "")
        }
        
        if (!encontrado) {
          options[[i]] <- paste("<option value='", vesselNames2[i], 
                                "'>", vesselNames2[i], "</option>", sep = "")
        }
      }
      
      options <- do.call("rbind", options)
    }
    
    select <- HTML(c("<div id='selectVesselName2' class='input-field col s12'>", 
                     "<select multiple name='selectVesselName2'>", "<option value='' disabled>Nombre del barco</option>", 
                     options, "</select>", "</div>", "<script>$('select').material_select();</script>"))
    
    #'<script>$('#selectVesselName2').material_select('destroy'); </script>'
    #'<script>$('#selectVesselName2').material_select();</script>'
    
    return(select)
    
  })
})

