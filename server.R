
# Packages -----------------------------------------------

library("shiny")
library("fasttime")
library("lubridate")
library("DBI")
library("RPostgreSQL")
library("sf")
library("wkb")

# Disable scientific notation 
options(scipen = 999)

# Global data --------------------------------------------

# Initial date values
dateFrom <- fastPOSIXct("2012-05-08 19:47:00 -03")
dateUntil <- fastPOSIXct("2014-05-17 11:15:00 -03")
dateFromQuery <- dateFrom
dateUntilQuery <- dateUntil

# First map data
vista_inicial = TRUE

# All vessel mmsi
conn <- dbConnect(dbDriver("PostgreSQL"), dbname = "ais")  # Connect to PostgreSQL
sql.vesselsNames <- "SELECT DISTINCT(mmsi) FROM barcos;"
query.vesselsNames <- sqlInterpolate(conn, sql.vesselsNames)
getquery.vesselNames <- dbGetQuery(conn, query.vesselsNames)

# Shiny Server -------------------------------------------

shinyServer(function(input, output) {
  
  # Data -------------------------------------------------
  
  positionsQry <- reactive({
    
    # Manage threshold number of points
    if (is.null(input$thresholdPoints) || input$thresholdPoints == "") {
      threshold <- 10000
    } 
    else {
      threshold <- as.numeric(input$thresholdPoints)
    }
    
    # First view
    if (vista_inicial) {
      
      # Conectar con PostgreSQL
      message("*** Vista inicial ***")
      message("Connect to PostgreSQL")
      conn <- dbConnect(dbDriver("PostgreSQL"), dbname = "ais")
      sql.positions <- "SELECT * FROM vista_inicial LIMIT ?threshold;"
      query.positions <- sqlInterpolate(conn, sql.positions, threshold = threshold)
      getquery.positions <- dbGetQuery(conn, query.positions)
      message("Disconnect from PostgreSQL")
      dbDisconnect(conn)  # Disconnect
      
      # Set flag to FALSE
      vista_inicial <<- FALSE
      
    } 
    else {
      
      # Query time
      if (input$dateFrom == "" || is.null(input$dateFrom)) {
        dateFromQuery <- dateFrom
      }
      else {
        dateFromQuery <- input$dateFrom
      }
      if (input$dateUntil == "" || is.null(input$dateUntil)) {
        dateUntilQuery <- dateUntil
      }
      else {
        dateUntilQuery <- input$dateUntil
      }
      
      message("*** Get positions count from query ***")
      message("Connect to PostgreSQL")
      conn <- dbConnect(dbDriver("PostgreSQL"), dbname = "ais")
      sql.positions.counts <- "SELECT COUNT(*) FROM posiciones 
      WHERE timestamp BETWEEN ?dateFrom AND ?dateUntil;"
      query.positions.counts <- sqlInterpolate(conn, sql.positions.counts, 
                                               dateFrom = as.character(dateFromQuery), 
                                               dateUntil = as.character(dateUntilQuery))
      getquery.positions.counts <- dbGetQuery(conn, query.positions.counts)
      
      if (getquery.positions.counts$count > threshold) {
        
        message("    *** Positions > Threshold: Get positions ***")
        sql.positions <- "SELECT * FROM posiciones 
                          WHERE timestamp BETWEEN ?dateFrom AND ?dateUntil
                          ORDER BY RANDOM() LIMIT ?threshold;"
        query.positions <- sqlInterpolate(conn, sql.positions, 
                                          dateFrom = as.character(dateFromQuery), 
                                          dateUntil = as.character(dateUntilQuery), 
                                          threshold = as.character(threshold))
        getquery.positions <- dbGetQuery(conn, query.positions)
        
      }
      else {
        
        message("   *** Positions < Threshold: Get positions ***")
        sql.positions <- "SELECT * FROM posiciones 
                          WHERE timestamp BETWEEN ?dateFrom AND ?dateUntil;"
        query.positions <- sqlInterpolate(conn, sql.positions, 
                                          dateFrom = as.character(dateFromQuery), 
                                          dateUntil = as.character(dateUntilQuery))
        getquery.positions <- dbGetQuery(conn, query.positions)
        
      }
      
      # Query vessel name
      
      # if (input$searchVesselName == "") {
      #   
      #   if (is.null(input$selectVesselName)) {
      #     
      #     VesselNameQuery <- getquery.vesselNames$mmsi
      #     
      #   } else {
      #     
      #     VesselNameQuery <- input$selectVesselName
      #     
      #   }
      # } else {
      #   
      #   VesselNameQuery <- input$searchVesselName
      #   
      # }
      
      # if (length(VesselNameQuery) > 0) {
      #   
      #   sql.positions <- "SELECT * FROM posiciones 
      #   WHERE timestamp BETWEEN ?dateFrom AND ?dateUntil
      #   AND mmsi = ?mmsi;"
      #   query.positions <- sqlInterpolate(conn, sql.positions, 
      #                                     dateFrom = as.character(dateFromQuery), 
      #                                     dateUntil = as.character(dateUntilQuery), 
      #                                     mmsi = VesselNameQuery)
      #   getquery.positions <- dbGetQuery(conn, query.positions)
      #   
      # }
      
      message("Disconnect from PostgreSQL")
      dbDisconnect(conn)  # Disconnect
    }
    
    # Make points df
    if (nrow(getquery.positions) > 0) {
      
      points <- cbind(readWKB(hex2raw(getquery.positions$wkb_geometry))@coords, 
                      getquery.positions[-c(1, 2)])
    } 
    else {
      
      points <- NULL
      
    }
    
    # Return
    return(points)
    
  })
  
  # Point cloud ------------------------------------------
  
  output$plot <- renderPlot({
    
    positionsQry <- positionsQry()
    
    plot <- plot(x = positionsQry$x, 
                 y = positionsQry$y, 
                 xlab = "Longitud", 
                 ylab = "Latitud", pch = 19, col = "black")
    
    return(plot)
    
  })
  
  # Mapa ------------------------------------------------- 
  
  output$divHtml <- renderUI({
    
    # Plot options
    radius <- input$radius
    colorGradient <- input$color
    opacity <- input$opacity
    blur <- input$blur
    
    # Get data
    positionsQry <- positionsQry()
    
    if (is.null(positionsQry)) {
      
      numberOfVessels <- 0
      positions <- 0
      
      toast <- paste("Materialize.toast('<i class=material-icons>location_on </i>", 
                     positions, " posiciones ', 8000, 'rounded');", sep = "")
      toast2 <- paste("Materialize.toast('<i class=material-icons>info_outline </i>", 
                      numberOfVessels, " barcos ', 9500, 'rounded');", sep = "")
      
      mapa <- HTML(paste("<script>", toast, toast2, "</script>"), sep = "")
      
    } 
    
    else {
      
      positions <- nrow(positionsQry)
      numberOfVessels <- length(unique(positionsQry$mmsi))
      
      # number of rows to toast Materialize.toast(message, displayLength,
      # className, completeCallback);
      toast <- paste("Materialize.toast('<i class=material-icons>location_on </i>", 
                     positions, " posiciones ', 8000, 'rounded');", sep = "")
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
    }
    
    return(mapa)
    
  })
  
  # Table of data ----------------------------------------
  
  output$table <- renderDataTable({
    
    if (is.null(positionsQry)) {
      return(NULL)
    } 
    else {
      return(positionsQry())
    }
    
  })
  
  # Select vessel name -----------------------------------
  
  #' output$selectVesselName <- renderUI({
  #'   
  #'   # Subset
  #'   positionsQry <- positionsQry()
  #'   
  #'   # All vessels names and total number
  #'   vesselNames2 <- positionsQry$mmsi
  #'   numberOfVessels <- length(vesselNames2)
  #'   
  #'   # Selected vessels names
  #'   vesselNamesSelected <- unique(positionsQry$mmsi)[1:10]
  #'   
  #'   # Mark as selected options the previously selected vessels
  #'   
  #'   if (numberOfVessels == length(vesselNamesSelected)) {
  #'     
  #'     options <- list()
  #'     
  #'     for (i in 1:numberOfVessels) {
  #'       options[[i]] <- paste("<option value='", vesselNames2[i], "'>", 
  #'                             vesselNames2[i], "</option>", sep = "")
  #'     }
  #'     
  #'     options <- do.call("rbind", options)
  #'     
  #'   } else {
  #'     
  #'     listSelectedVessels <- list()
  #'     
  #'     for (i in 1:numberOfVessels) {
  #'       
  #'       listSelectedVessels[[i]] <- which(vesselNames2[i] == vesselNamesSelected)
  #'       
  #'     }
  #'     
  #'     listSelectedVessels <- which(sapply(listSelectedVessels, length) > 0)
  #'     lengthListSelectedVessels <- length(listSelectedVessels)
  #'     
  #'     options <- list()
  #'     
  #'     for (i in 1:numberOfVessels) {
  #'       
  #'       encontrado <- FALSE
  #'       
  #'       j <- 1
  #'       
  #'       while (j <= lengthListSelectedVessels & !encontrado) {
  #'         
  #'         if (i == listSelectedVessels[j]) {
  #'           
  #'           encontrado <- TRUE
  #'           # print('encontrado')
  #'           
  #'         }
  #'         
  #'         j <- j + 1
  #'         
  #'       }
  #'       
  #'       if (encontrado) {
  #'         options[[i]] <- paste("<option value='", vesselNames2[i], 
  #'                               "' selected>", vesselNames2[i], "</option>", sep = "")
  #'       }
  #'       
  #'       if (!encontrado) {
  #'         options[[i]] <- paste("<option value='", vesselNames2[i], 
  #'                               "'>", vesselNames2[i], "</option>", sep = "")
  #'       }
  #'     }
  #'     
  #'     options <- do.call("rbind", options)
  #'   }
  #'   
  #'   select <- HTML(c("<div id='selectVesselName2' class='input-field col s12'>", 
  #'                    "<select multiple name='selectVesselName2'>", "<option value='' disabled>Nombre del barco</option>", 
  #'                    options, "</select>", "</div>", "<script>$('select').material_select();</script>"))
  #'   
  #'   #'<script>$('#selectVesselName2').material_select('destroy'); </script>'
  #'   #'<script>$('#selectVesselName2').material_select();</script>'
  #'   
  #'   return(select)
  #'   
  #' })
  
})

