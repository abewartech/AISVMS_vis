# Shiny Server -------------------------------------------

shinyServer(function(input, output) {
  
  # Get client inputs ------------------------------------ 
  
  getClientQry <- reactive({
    
    message("*** Getting Client Query Parameters ***")
    
    # Get values from client
    thresholdPointsCli <- input$thresholdPoints
    dateFromCli <- input$dateFrom
    dateUntilCli <- input$dateUntil
    searchVesselNameCli <- unlist(stringr::str_split(input$searchVesselName, "\n"))
    searchVesselNameCli <- searchVesselNameCli[-length(searchVesselNameCli)]
    catVesselNameCli <- unlist(stringr::str_split(input$catVesselName, "\n"))
    catVesselNameCli <- catVesselNameCli[-length(catVesselNameCli)]
    vesselSpeedMinCli <- input$vesselSpeedMin
    vesselSpeedMaxCli <- input$vesselSpeedMax
    catA <- input$catA
    catB <- input$catB
    catC <- input$catC
    catD <- input$catD
    
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
    if(!any(catA, catB, catC)) {
      if (searchVesselNameCli == "" || is.null(searchVesselNameCli)) {
        vesselNameQuery <- qryVal.df$searchVesselName
      }
      else {
        vesselNameQuery <- searchVesselNameCli
      }
    } else {
      vesselNameQuery <- as.character(catVesselNameCli)
      print(vesselNameQuery)
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
    
    print(vesselNameQuery)
    
    df <- data.frame('thresholdPoints' = thresholdQuery,
                     'dateFrom' = dateFromQuery,
                     'dateUntil' = dateUntilQuery,
                     'searchVesselName' = vesselNameQuery,
                     'vesselSpeedMin' = vesselSpeedMinQuery,
                     'vesselSpeedMax' = vesselSpeedMaxQuery,
                     'catA' = catA,
                     'catB' = catB,
                     'catC' = catC,
                     'catD' = catD)
    
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
  
  # Retrieve Data ----------------------------------------
  
  positionsQry <- function(thresholdQuery, dateFromQuery, dateUntilQuery, vesselNameQuery, vesselSpeedMinQuery, vesselSpeedMaxQuery) {
    
    message("**** Building Client Query ****")
    
    # Create a Progress object
    progress <- shiny::Progress$new(min = 0, max = 4)
    
    # Close it on exit
    on.exit(progress$close())
    
    progress$set(message = "Tomando datos del cliente...", value = 0)
    
    message("")
    message("************************************")
    message("    Query parameters from client    ")
    message(paste0("thresholdPointsCli: ", thresholdQuery))
    message(paste0("dateFromCli: ", dateFromQuery))
    message(paste0("dateUntilCli: ", dateUntilQuery))
    for (v in vesselNameQuery) {
      message(paste0("searchVesselNameCli: ", v)) 
    }
    message(paste0("vesselSpeedMinCli: ", vesselSpeedMinQuery))
    message(paste0("vesselSpeedMaxCli: ", vesselSpeedMaxQuery))
    message("************************************")
    message("")
    
    # Vessel name query
    vesselNameQuery <- as.character(vesselNameQuery)
    nVessels <- length(vesselNameQuery)
    
    for (i in 1:nVessels) {
      if (is.na(vesselNameQuery[i])) {
        vesselNameQuery[i] <- as.character(" ")
      } 
      else {
        vesselNameQuery[i] <- as.character(vesselNameQuery[i])
      }
    }
    
    # Count returned points in query
    message("*** Get positions count from query ***")
    message("Connect to PostgreSQL")
    progress$set(message = "Contando elementos...", value = 1)
    conn <- dbConnect(dbDriver("PostgreSQL"), dbname = "ais")
    
    # Build query string
    vessels <- paste0("?vesselName", 1:nVessels)
    vessels <- stringr::str_c(vessels, collapse = ", ")
    vessels <- paste0("(", vessels, ")")
    
    sql.positions.counts <- paste0("SELECT COUNT(*) FROM posiciones, barcos 
                                   WHERE posiciones.mmsi = barcos.mmsi AND barcos.name IN ", vessels, " 
                                   AND posiciones.speed BETWEEN ?vesselSpeedMin AND ?vesselSpeedMax 
                                   AND posiciones.timestamp BETWEEN ?dateFrom AND ?dateUntil;")
    
    vesselsExpr <- paste0("vesselName", 1:nVessels," = vesselNameQuery[", 1:nVessels, "]")
    vesselExpr <- stringr::str_c(vesselsExpr, collapse = ", ")
    
    # sql interpolate
    query.positions.counts.expr <- paste0("sqlInterpolate(conn, sql.positions.counts, ", vesselExpr, ", 
                                          vesselSpeedMin = as.character(vesselSpeedMinQuery), 
                                          vesselSpeedMax = as.character(vesselSpeedMaxQuery), 
                                          dateFrom = as.character(dateFromQuery), 
                                          dateUntil = as.character(dateUntilQuery))")
    
    # Parse text to expression
    query.positions.counts.expr <- parse(text = query.positions.counts.expr)
    
    # Evaluate expression
    getquery.positions.counts <- dbGetQuery(conn, eval(query.positions.counts.expr))
    
    if (getquery.positions.counts$count > thresholdQuery) {
      
      message("    *** Positions > thresholdQuery: Get positions ***")
      progress$set(message = "Obteniendo datos...", value = 2)
      
      sql.positions <- paste0("SELECT posiciones.wkb_geometry,
                               barcos.name,
                               posiciones.mmsi,
                               posiciones.status,
                               posiciones.speed,
                               posiciones.course,
                               posiciones.heading,
                               posiciones.timestamp
                        FROM posiciones, barcos 
                        WHERE posiciones.mmsi = barcos.mmsi
                        AND barcos.name IN ", vessels, " AND posiciones.speed BETWEEN ?vesselSpeedMin AND ?vesselSpeedMax
                        AND posiciones.timestamp BETWEEN ?dateFrom AND ?dateUntil
                        ORDER BY RANDOM() LIMIT ?threshold;")
      
      # sql interpolate
      query.positions.expr <- paste0("sqlInterpolate(conn, sql.positions, ", vesselExpr, ", 
                                     vesselSpeedMin = as.character(vesselSpeedMinQuery), 
                                     vesselSpeedMax = as.character(vesselSpeedMaxQuery), 
                                     dateFrom = as.character(dateFromQuery), 
                                     dateUntil = as.character(dateUntilQuery), 
                                     threshold = as.character(thresholdQuery))")
      
      # Parse text to expression
      query.positions.expr <- parse(text = query.positions.expr)
      
      # Evaluate expression
      getquery.positions <- dbGetQuery(conn, eval(query.positions.expr))
      
    }
    else {
      
      message("   *** Positions < thresholdQuery: Get positions ***")
      progress$set(message = "Obteniendo datos...", value = 2)
      sql.positions <- paste0("SELECT posiciones.wkb_geometry,
                               barcos.name,
                              posiciones.mmsi,
                              posiciones.status,
                              posiciones.speed,
                              posiciones.course,
                              posiciones.heading,
                              posiciones.timestamp
                              FROM posiciones, barcos 
                              WHERE posiciones.mmsi = barcos.mmsi
                              AND barcos.name IN ", vessels, " AND posiciones.speed BETWEEN ?vesselSpeedMin AND ?vesselSpeedMax
                              AND posiciones.timestamp BETWEEN ?dateFrom AND ?dateUntil;")
      
      # sql interpolate
      query.positions.expr <- paste0("sqlInterpolate(conn, sql.positions, ", vesselExpr, ", 
                                     vesselSpeedMin = as.character(vesselSpeedMinQuery), 
                                     vesselSpeedMax = as.character(vesselSpeedMaxQuery), 
                                     dateFrom = as.character(dateFromQuery), 
                                     dateUntil = as.character(dateUntilQuery))")
      
      # Parse text to expression
      query.positions.expr <- parse(text = query.positions.expr)
      
      # Evaluate expression
      getquery.positions <- dbGetQuery(conn, eval(query.positions.expr))
      
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
      render.df <- positionsQry(qryValCustom.df$thresholdPoints[1], 
                                qryValCustom.df$dateFrom[1], 
                                qryValCustom.df$dateUntil[1], 
                                qryValCustom.df$searchVesselName, 
                                qryValCustom.df$vesselSpeedMin[1], 
                                qryValCustom.df$vesselSpeedMax[1])
      
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
    
    # Add shp layers - REQUIERES FIXING
    shp <- HTML(paste0("<script>", "var limitesURY = new L.Shapefile('data/shp/limites-URY.zip', {style:function(feature){return {color:'black',fillColor:'red',fillOpacity:.75}}}); console.log(limitesURY); limitesURY.addTo(map);", "</script>"))
    
    return(mapa)
    
  })
  
  # Table of data ----------------------------------------
  
  output$table <- renderDataTable({
    
    if (is.null(positionsQry.df)) {
      table <- data.frame("Longitud" = NA, "Latitud" = NA, "Nombre" = NA, 
                          "MMSI" = NA, "Estado" = NA, "Velocidad" = NA, 
                          "Curso" = NA, "Orientación" = NA, "Tiempo" = NA)
    } 
    else {
      table <- positionsQry.df
      table$speed <- table$speed / 10
      table$course <- table$course / 10
      table$heading <- table$heading / 10
      colnames(table) <- c("Longitud", "Latitud", "Nombre", "MMSI", "Estado", "Velocidad", "Curso", "Orientación", "Tiempo")
    }
    
    return(table)
    
  })
  
  # Line Chart -------------------------------------------
  
  output$plotSpeed <- renderPlotly({
    
    message("*** Rendering speed plot ***")
    
    if (is.null(positionsQry.df)) {
      table <- data.frame("Longitud" = NA, "Latitud" = NA, "Nombre" = NA, 
                          "MMSI" = NA, "Estado" = NA, "Velocidad" = NA, 
                          "Curso" = NA, "Orientación" = NA, "Tiempo" = NA)
    } 
    else {
      table <- positionsQry.df
      table$speed <- table$speed / 10
      table$course <- table$course / 10
      table$heading <- table$heading / 10
      colnames(table) <- c("Longitud", "Latitud", "Nombre", "MMSI", "Estado", "Velocidad", "Curso", "Orientación", "Tiempo")
    }

    # Random sampling if nrows exceeds 10.000 
    if (nrow(table) >= 10000) {
      table <- table[sample(x = 1:nrow(table), size = 10000),]
    }
    
    p <- plot_ly(table, x = ~Tiempo, y = ~Velocidad, color = ~Nombre,
                 type = 'scatter', mode = 'markers', 
                 marker = list(size = 5, opacity = 0.8),
                 symbols = 'circle', text = paste(" Barco:", table$Nombre, "<br> Velocidad:", table$Velocidad, "kn", '<br> Fecha:', table$Tiempo))
    
    p %>%
      layout(title = "Perfil de Velocidad",
             xaxis = list(title = "Tiempo"),
             yaxis = list (title = "Velocidad (kn)"))
  })
  
})