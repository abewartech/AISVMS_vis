# Shiny Server -------------------------------------------

shinyServer(function(input, output) {
  
  # Get client inputs ------------------------------------ 
  
  getClientQry <- reactive({
    
    message("*** Getting Client Query Parameters ***")
    
    # Get values from client
    thresholdPointsCli <- input$thresholdPoints
    dateFromCli <- input$dateFrom
    dateUntilCli <- input$dateUntil
    searchVesselNameCli <- input$searchVesselName
    vesselSpeedMinCli <- input$vesselSpeedMin
    vesselSpeedMaxCli <- input$vesselSpeedMax
    
    # Query threshold number of points
    if (is.null(thresholdPointsCli) || thresholdPointsCli == "") {
      thresholdQuery <- qryVal.df$thresholdPoints
    } 
    else {
      thresholdQuery <- as.numeric(thresholdPointsCli) * 1000000
    }
    
    # Query datetime From / Until
    if (dateFromCli == "" || is.null(dateFromCli) || dateFromCli == "08 Junio, 2012") {
      dateFromQuery <- qryVal.df$dateFrom
    }
    else {
      dateFromQuery <- dateFromCli
    }
    
    if (dateUntilCli == "" || is.null(dateUntilCli) || dateUntilCli == "17 Mayo, 2014") {
      dateUntilQuery <- qryVal.df$dateUntil
    }
    else {
      dateUntilQuery <- dateUntilCli
    }
    
    # Query vessel name
    if (searchVesselNameCli == "" || is.null(searchVesselNameCli)) {
      vesselNameQuery <- qryVal.df$searchVesselName
    }
    else {
      vesselNameQuery <- searchVesselNameCli
    }
    
    # Query vessel speed Min / Max
    if (vesselSpeedMinCli == "" || is.null(vesselSpeedMinCli)) {
      vesselSpeedMinQuery <- qryVal.df$vesselSpeedMin * 10
    }
    else {
      vesselSpeedMinQuery <- as.numeric(vesselSpeedMinCli) * 10
    }
    if (vesselSpeedMaxCli == "" || is.null(vesselSpeedMaxCli)) {
      vesselSpeedMaxQuery <- qryVal.df$vesselSpeedMax * 10
    }
    else {
      vesselSpeedMaxQuery <- as.numeric(vesselSpeedMaxCli) * 10
    }
    
    
    df <- data.frame('thresholdPoints' = thresholdQuery,
                     'dateFrom' = dateFromQuery,
                     'dateUntil' = dateUntilQuery,
                     'searchVesselName' = vesselNameQuery,
                     'vesselSpeedMin' = vesselSpeedMinQuery,
                     'vesselSpeedMax' = vesselSpeedMaxQuery)
    
    return(df)
    
  })
  
  getClientConf <- reactive({
    
    message("*** Getting Client Config Parameters ***")
    
    # Map config options
    opacityConf <- input$opacity
    radiusConf <- input$radius
    colorGradientConf <- input$color
    blurConf <- input$blur
    
    df <- data.frame('opacity' = opacityConf,
                     'radius' = radiusConf,
                     'colorGradient' = colorGradientConf,
                     'blur' = blurConf)
    
    return(df)
    
  })
  
  # Data -------------------------------------------------
  
  positionsQry <- function(thresholdQuery, dateFromQuery, dateUntilQuery, vesselNameQuery, vesselSpeedMinQuery, vesselSpeedMaxQuery) {
    
    message("**** Building Client Query ****")
    
    # Create a Progress object
    progress <- shiny::Progress$new(min=0, max=4)
    
    # Close it on exit
    on.exit(progress$close())
    
    progress$set(message = "Tomando datos del cliente...", value = 0)
    
    message("")
    message("************************************")
    message("    Query parameters from client    ")
    message(paste0("thresholdPointsCli: ", thresholdQuery))
    message(paste0("dateFromCli: ", dateFromQuery))
    message(paste0("dateUntilCli: ", dateUntilQuery))
    message(paste0("searchVesselNameCli: ", vesselNameQuery))
    message(paste0("vesselSpeedMinCli: ", vesselSpeedMinQuery))
    message(paste0("vesselSpeedMaxCli: ", vesselSpeedMaxQuery))
    message("************************************")
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
    
    progress$set(message = "Desconectando de la BD...", value = 3)
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
    
    #positionsQry.df <<- points
    progress$set(message = "Terminado!", value = 4)
    message("Finished")
    
    # Return
    return(points)
    
  }
  
  # Mapa ------------------------------------------------- 
  
  output$divHtml <- renderUI({
    
    input$btnReplay
    
    # Default df
    render.df <- positionsQry.df
    renderConfig.df <- configCustom.df
    
    # Check if same query and config values
    sameQuery <- identical(getClientQry(), qryValCustom.df) 
    sameConfig <- identical(getClientConf(), configCustom.df)
    
    if (sameQuery) {message("*** Same query ***")}
    if (!sameQuery) {message("*** New query ***")}
    if (sameConfig) {message("*** Same config ***")}
    if (!sameConfig) {message("*** New config ***")}
    
    if (!sameQuery) {
      
      qryValCustom.df <<- getClientQry()
      
      # Call query
      render.df <- positionsQry(qryValCustom.df$thresholdPoints, 
                                qryValCustom.df$dateFrom, 
                                qryValCustom.df$dateUntil, 
                                qryValCustom.df$searchVesselName, 
                                qryValCustom.df$vesselSpeedMin, 
                                qryValCustom.df$vesselSpeedMax)
      
      positionsQry.df <<- render.df
      
      }
    if (!sameConfig) {
      
      configCustom.df <<- getClientConf()
      
      # Call query
      renderConfig.df <- configCustom.df
    }  
    
    if (nrow(render.df) <= 0 || is.null(render.df)) {
      
      numberOfVessels <- 0
      positions <- 0
      
      if (numberOfVessels > 1) {stringBarco <- " barcos "}
      if (numberOfVessels <= 1) {stringBarco <- " barco "}
      
      toast <- paste("Materialize.toast('<i class=material-icons>location_on </i>", 
                     positions, " posiciones ', 8000, 'rounded');", sep = "")
      toast2 <- paste("Materialize.toast('<i class=material-icons>info_outline </i>", 
                      numberOfVessels, stringBarco, "', 9500, 'rounded');", sep = "")
      
      # Remove latest heat layer and show toasts
      mapa <- HTML(paste0("<script>",
                          "if (map.hasLayer(heat)) {map.removeLayer(heat);} 
                           else {var heat = L.heatLayer([[50.5, 30.5, 1000], [50.6, 30.4, 1000]], {radius: 30}).addTo(map);}",
                          toast, toast2,
                          "</script>"))
    } 
    else {
      
      positions <- nrow(render.df)
      numberOfVessels <- length(unique(render.df$mmsi))
      
      if (numberOfVessels > 1) {stringBarco <- " barcos "}
      if (numberOfVessels <= 1) {stringBarco <- " barco "}
      
      toast <- paste("Materialize.toast('<i class=material-icons>location_on </i>", 
                     positions, " posiciones ', 8000, 'rounded');", sep = "")
      toast2 <- paste("Materialize.toast('<i class=material-icons>info_outline </i>", 
                      numberOfVessels, stringBarco, "', 9500, 'rounded');", sep = "")
      
      j <- paste0("[", render.df$y, ",", render.df$x,"]", collapse = ",")
      j <- paste0("[", j, "]")
      
      mapa <- HTML(paste("<script>", 
                         sprintf("var buildingsCoords = %s;", j), 
                         "buildingsCoords = buildingsCoords.map(function(p) {return [p[0], p[1]];});
                         if(map.hasLayer(heat)) {map.removeLayer(heat);};
                         var heat = L.heatLayer(buildingsCoords, {minOpacity:", renderConfig.df$opacity, 
                         ", radius:", renderConfig.df$radius, renderConfig.df$colorGradient, ", blur:", renderConfig.df$blur, 
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

