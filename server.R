
# Packages -----------------------------------------------

library("shiny")
#library("fasttime")
library("lubridate")
library("DBI")
library("RPostgreSQL")
library("sf")
library("wkb")

# Disable scientific notation 
options(scipen = 999)

# Global variables ---------------------------------------

# Initial data values
dateFrom <- "2012-05-08"
dateUntil <- "2014-05-17"
threshold <- 1000000
vesselsNames <- " "
vesselSpeedMin <- 3
vesselSpeedMax <- 9

# Query values
dateFromQuery <- dateFrom
dateUntilQuery <- dateUntil
thresholdQuery <- threshold
vesselNameQuery <- vesselsNames
vesselSpeedMinQuery <- vesselSpeedMin
vesselSpeedMaxQuery <- vesselSpeedMax

positionsQry.df <- data.frame()

# Shiny Server -------------------------------------------

shinyServer(function(input, output) {
  
  # Data -------------------------------------------------
  
  positionsQry <- reactive({
    
    # Create a Progress object
    progress <- shiny::Progress$new(min=0, max=4)
    
    # Close it on exit
    on.exit(progress$close())
    
    # Get values from client
    progress$set(message = "Tomando datos del cliente...", value = 0)
    thresholdPointsCli <- input$thresholdPoints
    dateFromCli <- input$dateFrom
    dateUntilCli <- input$dateUntil
    searchVesselNameCli <- input$searchVesselName
    vesselSpeedMinCli <- input$vesselSpeedMin
    vesselSpeedMaxCli <- input$vesselSpeedMax
    
    # Query threshold number of points
    if (is.null(thresholdPointsCli) || thresholdPointsCli == "") {
      thresholdQuery <- threshold
    } 
    else {
      thresholdQuery <<- as.numeric(thresholdPointsCli) * 1000000
    }
    
    # Query datetime From / Until
    if (dateFromCli == "" || is.null(dateFromCli)) {
      dateFromQuery <- dateFrom
    }
    else {
      dateFromQuery <<- dateFromCli
    }
    
    if (dateUntilCli == "" || is.null(dateUntilCli)) {
      dateUntilQuery <- dateUntil
    }
    else {
      dateUntilQuery <<- dateUntilCli
    }
    
    # Query vessel name
    if (searchVesselNameCli == "" || is.null(searchVesselNameCli)) {
      vesselNameQuery <- vesselsNames
    }
    else {
      vesselNameQuery <<- searchVesselNameCli
    }
    
    # Query vessel speed Min / Max
    if (vesselSpeedMinCli == "" || is.null(vesselSpeedMinCli)) {
      vesselSpeedMinQuery <- vesselSpeedMin * 10
    }
    else {
      vesselSpeedMinQuery <<- as.numeric(vesselSpeedMinCli) * 10
    }
    if (vesselSpeedMaxCli == "" || is.null(vesselSpeedMaxCli)) {
      vesselSpeedMaxQuery <- vesselSpeedMax * 10
    }
    else {
      vesselSpeedMaxQuery <<- as.numeric(vesselSpeedMaxCli) * 10
    }
    
    message("*** Query parameters from client ***")
    message(paste0("thresholdPointsCli: ", thresholdQuery))
    message(paste0("dateFromCli: ", dateFromQuery))
    message(paste0("dateUntilCli: ", dateUntilQuery))
    message(paste0("searchVesselNameCli: ", vesselNameQuery))
    message(paste0("vesselSpeedMinCli: ", vesselSpeedMinQuery))
    message(paste0("vesselSpeedMaxCli: ", vesselSpeedMaxQuery))
    message("")
    
    # Count returned points in query
    message("*** Get positions count from query ***")
    message("Connect to PostgreSQL")
    progress$set(message = "Contando elementos...", value = 1)
    conn <- dbConnect(dbDriver("PostgreSQL"), dbname = "ais")
    sql.positions.counts <- "SELECT COUNT(*) 
                             FROM posiciones, barcos 
                             WHERE barcos.name = ?vesselName
                             AND posiciones.mmsi = barcos.mmsi
                             AND posiciones.speed BETWEEN ?vesselSpeedMin AND ?vesselSpeedMax
                             AND posiciones.timestamp BETWEEN ?dateFrom AND ?dateUntil;"
    query.positions.counts <- sqlInterpolate(conn, sql.positions.counts, 
                                             dateFrom = as.character(dateFromQuery), 
                                             dateUntil = as.character(dateUntilQuery),
                                             vesselName = as.character(vesselNameQuery),
                                             vesselSpeedMin = as.character(vesselSpeedMinQuery), 
                                             vesselSpeedMax = as.character(vesselSpeedMaxQuery))
    getquery.positions.counts <- dbGetQuery(conn, query.positions.counts)
    
    if (getquery.positions.counts$count > thresholdQuery) {
      
      message("    *** Positions > thresholdQuery: Get positions ***")
      progress$set(message = "Obteniendo datos...", value = 2)
      sql.positions <- "SELECT posiciones.wkb_geometry,
                               barcos.name,
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
                        ORDER BY RANDOM() LIMIT ?thresholdQuery;"
      query.positions <- sqlInterpolate(conn, sql.positions, 
                                        dateFrom = as.character(dateFromQuery), 
                                        dateUntil = as.character(dateUntilQuery),
                                        vesselName = as.character(vesselNameQuery),
                                        threshold = as.character(thresholdQuery),
                                        vesselSpeedMin = as.character(vesselSpeedMinQuery), 
                                        vesselSpeedMax = as.character(vesselSpeedMaxQuery))
      getquery.positions <- dbGetQuery(conn, query.positions)
      
    }
    else {
      
      message("   *** Positions < thresholdQuery: Get positions ***")
      progress$set(message = "Obteniendo datos...", value = 2)
      sql.positions <- "SELECT posiciones.wkb_geometry,
                               barcos.name,
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
                        AND posiciones.timestamp BETWEEN ?dateFrom AND ?dateUntil;"
      query.positions <- sqlInterpolate(conn, sql.positions, 
                                        dateFrom = as.character(dateFromQuery), 
                                        dateUntil = as.character(dateUntilQuery), 
                                        vesselName = as.character(vesselNameQuery), 
                                        vesselSpeedMin = as.character(vesselSpeedMinQuery), 
                                        vesselSpeedMax = as.character(vesselSpeedMaxQuery))
      getquery.positions <- dbGetQuery(conn, query.positions)
      
    }
    
    progress$set(message = "Desconectando de la base de datos...", value = 3)
    message("Disconnect from PostgreSQL")
    dbDisconnect(conn)  # Disconnect
    
    # Make points df
    if (nrow(getquery.positions) > 0) {
      
      message("Creating points")
      points <- cbind(readWKB(hex2raw(getquery.positions$wkb_geometry))@coords, 
                      getquery.positions[,-1])
    } 
    else {
      points <- NULL
    }
    
    positionsQry.df <<- points
    progress$set(message = "Terminado!", value = 4)
    message("Finished")
    
    # Return
    return(points)
    
  })
  
  # Mapa ------------------------------------------------- 
  
  output$divHtml <- renderUI({
    
    # Plot options
    radius <- input$radius
    colorGradient <- input$color
    opacity <- input$opacity
    blur <- input$blur
    
    if (dateFromQuery != as.character(input$dateFrom) || 
        dateUntilQuery != as.character(input$dateUntil) ||
        thresholdQuery !=  input$thresholdPoints ||
        vesselNameQuery != input$searchVesselName ||
        vesselSpeedMinQuery != input$vesselSpeedMin ||
        vesselSpeedMaxQuery != input$vesselSpeedMax) {
      
      # Call query
      positionsQry <- positionsQry()
      
    } 
    
    else  {
      positionsQry <- positionsQry.df
    }
    
    if (nrow(positionsQry) <= 0 || is.null(positionsQry)) {
      
      numberOfVessels <- 0
      positions <- 0
      
      toast <- paste("Materialize.toast('<i class=material-icons>location_on </i>", 
                     positions, " posiciones ', 8000, 'rounded');", sep = "")
      toast2 <- paste("Materialize.toast('<i class=material-icons>info_outline </i>", 
                      numberOfVessels, " barcos ', 9500, 'rounded');", sep = "")
      
      # Remove latest heat layer and show toasts
      mapa <- HTML(paste0("<script>",
                         "if(map.hasLayer(heat)) {map.removeLayer(heat);};",
                          toast, toast2,
                         "</script>"))
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
    
    if (is.null(positionsQry.df)) {
      table <- data.frame("Longitud" = NA, "Latitud" = NA, "Nombre" = NA, 
                          "MMSI" = NA, "Estado" = NA, "Velocidad" = NA, 
                          "Curso" = NA, "Orientación" = NA, "Tiempo" = NA)
      return(table)
    } 
    else {
      table <- positionsQry.df
      table$speed <- table$speed / 10
      table$course <- table$course / 10
      table$heading <- table$heading / 10
      colnames(table) <- c("Longitud", "Latitud", "Nombre", "MMSI", "Estado", "Velocidad", "Curso", "Orientación", "Tiempo")
      return(table)
    }
    
  })
  
  # Point cloud ------------------------------------------
  
  output$plot <- renderPlot({
    
    plot <- plot(x = positionsQry.df$x, 
                 y = positionsQry.df$y, 
                 xlab = "Longitud", 
                 ylab = "Latitud", pch = 19, 
                 col = "black", cex = 0.5)
    
    return(plot)
    
  })
  
})

