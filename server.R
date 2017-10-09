
# Packages -----------------------------------------------------

library("shiny")
library("fasttime")
library("lubridate")
library("DBI")
library("RPostgreSQL")

library("sf")
library("wkb")

#library("dplyr")
#library("dbplyr")
#library("pool")

# Global data -------------------------------------------------

# Conectar con PostgreSQL
conn <- dbConnect(dbDriver("PostgreSQL"), dbname = "ais")

# Initial values
dateFrom <- fastPOSIXct("2012-05-08 19:47:00 -03")  # dbGetQuery(conn, 'SELECT max(timestamp) FROM posiciones;')
dateUntil <- fastPOSIXct("2014-05-17 11:15:00 -03")  # dbGetQuery(conn, 'SELECT min(timestamp) FROM posiciones;')
dateFromQuery <- dateFrom
dateUntilQuery <- dateUntil

# Define number of points shown threshold
threshold <- 50000

# All vessel mmsi ids
vesselNames <- dbGetQuery(conn, "SELECT DISTINCT(mmsi) FROM barcos;")$mmsi

# Shiny Server -----------------------------------------------

shinyServer(function(input, output) {
  
  # Data --------------------------------------------------------
  
  positionsQry <- reactive({
    
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
    
    print("positionsQry.count...")
    positionsQry.count <- dbGetQuery(conn, paste("SELECT COUNT(*) FROM posiciones 
                                                  WHERE timestamp BETWEEN '", 
                                                 dateFromQuery, "' AND '", 
                                                 dateUntilQuery, "';", sep = ""))
    
    if(positionsQry.count$count > threshold) {
      
      print("positionsQry > threshold...")
      positionsQry <- dbGetQuery(conn, paste("SELECT * FROM posiciones 
                                              WHERE timestamp BETWEEN '", 
                                             dateFromQuery, "' AND '", 
                                             dateUntilQuery, "' ORDER BY RANDOM()
                                              LIMIT '", threshold, "' ;", sep = ""))
    } else {
      
      print("positionsQry < threshold...")
      positionsQry <- dbGetQuery(conn, paste("SELECT * FROM posiciones 
                                              WHERE timestamp BETWEEN '", 
                                             dateFromQuery, "' AND '", 
                                             dateUntilQuery, "';", sep = ""))
    }
    
    # Query vessel name
    
    if (input$searchVesselName == "") {
      
      if (is.null(input$selectVesselName)) {
        
        VesselNameQuery <- vesselNames
        
      } else {
        
        VesselNameQuery <- input$selectVesselName
        
      }
    } else {
      
      VesselNameQuery <- input$searchVesselName
      
    }
    
    if (length(VesselNameQuery) > 0) {
      
      positionsQry <- dbGetQuery(conn, paste("SELECT * FROM posiciones 
                                                WHERE timestamp BETWEEN '", 
                                             dateFromQuery, "' AND '", 
                                             dateUntilQuery, "' AND
                                                mmsi = '", VesselNameQuery, "';", sep = ""))
    } 
    
    # Disconnect
    print("Disconnecting...")
    dbDisconnect(conn)
    
    points <- cbind(readWKB(hex2raw(positionsQry$wkb_geometry))@coords, positionsQry[-c(1,2)])
    
    return(points)
    
  })
  
  # Point cloud -------------------------------------------------
  
  output$plot <- renderPlot({
    
    points <- sf::st_as_sfc(wkb::hex2raw(positionsQry$wkb_geometry))
    st_crs(points) <- st_crs(4326)
    
    plot <- plot(x = st_coordinates(points)[,1], y = st_coordinates(points)[,2], 
                 xlab = "Longitud", ylab = "Latitud", pch = 19, col = "black")
    
    return(plot)
    
  })
  
  # Mapa
  output$divHtml <- renderUI({
    
    radius <- input$radius
    colorGradient <- input$color
    opacity <- input$opacity
    blur <- input$blur
    
    positionsQry <- positionsQry()
        
    numberOfVessels <- length(unique(positionsQry$mmsi))
    
    # number of rows to toast Materialize.toast(message, displayLength,
    # className, completeCallback);
    toast <- paste("Materialize.toast('<i class=material-icons>location_on </i>", 
                   nrow(positionsQry), " posiciones ', 8000, 'rounded');", sep = "")
    toast2 <- paste("Materialize.toast('<i class=material-icons>info_outline </i>", 
                    numberOfVessels, " barcos ', 9500, 'rounded');", sep = "")
    
    j <- paste0("[", positionsQry[,"y"], ",", positionsQry[,"x"], "]", collapse = ",")
    j <- paste0("[", j, "]")
    
    mapa <- HTML(paste("<script>", sprintf("var buildingsCoords = %s;", 
                                           j), "buildingsCoords = buildingsCoords.map(function(p) {return [p[0], p[1]];});
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
    vesselNames2 <- vesselNames
    numberOfVessels <- length(vesselNames2)
    
    # Selected vessels names
    vesselNamesSelected <- unique(positionsQry$mmsi)
    
    # Mark as selected options the previously selected vessels
    
    if (numberOfVessels == length(vesselNamesSelected)) {
      
      options <- list()
      
      for (i in 1:numberOfVessels) {
        options[[i]] <- paste("<option value='", vesselNames2[i], 
                              "'>", vesselNames2[i], "</option>", sep = "")
      }
      
      options <- do.call("rbind", options)
      
    } else {
      
      listSelectedVessels <- list()
      
      for (i in 1:numberOfVessels) {
        
        listSelectedVessels[[i]] <- which(vesselNames2[i] == vesselNamesSelected)
        
      }
      
      listSelectedVessels <- which(sapply(listSelectedVessels, length) > 
                                     0)
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

