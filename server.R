# Shiny Server -------------------------------------------

shinyServer(function(input, output, session) {
  
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
    catACli <- input$catA
    catBCli <- input$catB
    catCCli <- input$catC
    catDCli <- input$catD
    catAlturaCli <- input$catAltura
    catCosterosCli <- input$catCosteros
    
    # Query threshold number of points
    if (is.null(catACli) || catACli == "") {
      catA <- qryVal.df$catA
    } 
    else {
      catA <- catACli
    }
    
    if (is.null(catBCli) || catBCli == "") {
      catB <- qryVal.df$catB
    } 
    else {
      catB <- catBCli
    }
    
    if (is.null(catCCli) || catCCli == "") {
      catC <- qryVal.df$catC
    } 
    else {
      catC <- catCCli
    }
    
    if (is.null(catDCli) || catDCli == "") {
      catD <- qryVal.df$catD
    } 
    else {
      catD <- catDCli
    }
    
    if (is.null(catAlturaCli) || catAlturaCli == "") {
      catAltura <- qryVal.df$catAltura
    } 
    else {
      catAltura <- catAlturaCli
    }
    
    if (is.null(catCosterosCli) || catCosterosCli == "") {
      catCosteros <- qryVal.df$catCosteros
    } 
    else {
      catCosteros <- catCosterosCli
    }
    
    # Query threshold number of points
    if (is.null(thresholdPointsCli) || thresholdPointsCli == "") {
      thresholdQuery <- qryVal.df$thresholdPoints
    } 
    else {
      thresholdQuery <- as.numeric(thresholdPointsCli)
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
    
    # Query vessel name
    if(!any(catA, catB, catC, catD, catAltura, catCosteros)) {
      
      if (searchVesselNameCli == "" || is.null(searchVesselNameCli) || length(searchVesselNameCli) == 0) {
        vesselNameQuery <- qryVal.df$searchVesselName
      }
      
      else {
        vesselNameQuery <- searchVesselNameCli
      }
      
      # Update search vessels input
      session$sendCustomMessage(type = "searchVessels", message = toJSON(vesselNameQuery))
      session$sendCustomMessage(type = "catVessels", message = toJSON(NULL))
      
    } 
    else {
      
      if (catVesselNameCli == "" || is.null(catVesselNameCli) || length(catVesselNameCli) == 0) {
        vesselNameQuery <- qryVal.df$searchVesselName
      } 
      
      else {
        vesselNameQuery <- as.character(catVesselNameCli)
        }
      
      # Update category vessels input
      session$sendCustomMessage(type = "catVessels", message = toJSON(vesselNameQuery))
      session$sendCustomMessage(type = "searchVessels", message = toJSON(NULL))
      
    }
    
    df <- data.frame('thresholdPoints' = thresholdQuery,
                     'dateFrom' = dateFromQuery,
                     'dateUntil' = dateUntilQuery,
                     'searchVesselName' = vesselNameQuery,
                     'vesselSpeedMin' = vesselSpeedMinQuery,
                     'vesselSpeedMax' = vesselSpeedMaxQuery,
                     'catA' = catA,
                     'catB' = catB,
                     'catC' = catC,
                     'catD' = catD,
                     'catAltura' = catAltura,
                     'catCosteros' = catCosteros)
    
    # Update data in global qryVal.df 
    qryVal.df <<- data.frame('thresholdPoints' = thresholdQuery,
                             'dateFrom' = dateFromQuery,
                             'dateUntil' = dateUntilQuery,
                             'searchVesselName' = vesselNameQuery,
                             'vesselSpeedMin' = vesselSpeedMinQuery / 10,
                             'vesselSpeedMax' = vesselSpeedMaxQuery / 10,
                             'catA' = catA,
                             'catB' = catB,
                             'catC' = catC,
                             'catD' = catD,
                             'catAltura' = catAltura,
                             'catCosteros' = catCosteros)
    
    return(df)
    
  })
  
  getClientConf <- reactive({
    
    message("*** Getting Client Config Parameters ***")
    
    # Map config options
    opacityConfCli <- input$opacity
    radiusConfCli <- input$radius
    colorGradientConfCli <- input$color
    blurConfCli <- input$blur
    
    # Query 
    if (is.null(opacityConfCli) || opacityConfCli == "") {
      opacityConf <- config.df$opacity
    } 
    else {
      opacityConf <- opacityConfCli
    }
    
    if (is.null(radiusConfCli) || radiusConfCli == "") {
      radiusConf <- config.df$radius
    } 
    else {
      radiusConf <- radiusConfCli
    }
    
    if (is.null(colorGradientConfCli) || colorGradientConfCli == "") {
      colorGradientConf <- config.df$colorGradient
    } 
    else {
      colorGradientConf <- colorGradientConfCli
    }
    
    if (is.null(blurConfCli) || blurConfCli == "") {
      blurConf <- config.df$blur
    } 
    else {
      blurConf <- blurConfCli
    }
    
    df <- data.frame('opacity' = opacityConf,
                     'radius' = radiusConf,
                     'colorGradient' = colorGradientConf,
                     'blur' = blurConf)
    
    # Update data in config.df
    config.df <<- df
    
    return(df)
    
  })
  
  getClientPlot <- reactive({
    
    # Plot input vars
    vesselSpeedMinCli <- input$vesselSpeedMinPlot
    vesselSpeedMaxCli <- input$vesselSpeedMaxPlot
    dateFromCli <- input$dateFromPlot 
    dateUntilCli <- input$dateUntilPlot    
    
    # Validation of inputs
    
    # Vessel speed Min / Max
    if (vesselSpeedMinCli == "" || is.null(vesselSpeedMinCli)) {
      vesselSpeedMinQuery <- as.numeric(as.character(qryVal.df$vesselSpeedMin)) 
    }
    else {
      vesselSpeedMinQuery <- as.numeric(vesselSpeedMinCli)
    }
    if (vesselSpeedMaxCli == "" || is.null(vesselSpeedMaxCli)) {
      vesselSpeedMaxQuery <- as.numeric(as.character(qryVal.df$vesselSpeedMax)) 
    }
    else {
      vesselSpeedMaxQuery <- as.numeric(vesselSpeedMaxCli)
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
    
    # Subset data based on input
    table <- subset(table, Velocidad >= vesselSpeedMinQuery & Velocidad <= vesselSpeedMaxQuery & Tiempo >= as.POSIXct(as.character(dateFromQuery)) & Tiempo <= as.POSIXct(as.character(dateUntilQuery)))
    
    # Random sampling if nrows exceeds 10.000 
    if (nrow(table) >= 10000) {
      table <- table[sample(x = 1:nrow(table), size = 10000),]
    }
    
    start.end <- c(min(table$Tiempo, na.rm = TRUE), max(table$Tiempo, na.rm = TRUE))
    ndays <- difftime(time1 = start.end[2], time2 = start.end[1], units = "days")
    
    # Create list 
    listInputPlot <- list()
    listInputPlot[[1]] <- table
    listInputPlot[[2]] <- start.end
    listInputPlot[[3]] <- ndays
    names(listInputPlot) <- c("plotData", "startEnd", "nDays")
    
    return(listInputPlot)
    
  })
  
  # Retrieve Data ----------------------------------------
  
  positionsQry <- function(thresholdQuery, dateFromQuery, dateUntilQuery, vesselNameQuery, vesselSpeedMinQuery, vesselSpeedMaxQuery) {
    
    message("**** Building Client Query ****")
    
    # Create a Progress object
    progress <- shiny::Progress$new(min = 0, max = 6)
    
    # Send show modal to client
    modal <- "open"
    session$sendCustomMessage(type = "modal", modal)
    
    # Close it on exit
    on.exit(progress$close())
    
    progress$set(message = "Recibiendo consulta", value = 0)
    
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
    progress$set(message = "Contando registros", value = 1)
    conn <- dbConnect(dbDriver("PostgreSQL"), dbname = "ais", user = "anonimo", host = '10.5.1.50', port = '5432')
    
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
      
      progress$set(message = paste0(getquery.positions.counts$count, " registros en total"), value = 2)
      Sys.sleep(time = 1)
      message("    *** Positions > thresholdQuery: Get positions ***")
      
      sql.positions <- paste0("SELECT ST_X(posiciones.wkb_geometry::geometry) AS x, 
                                      ST_Y(posiciones.wkb_geometry::geometry) AS y,
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
      progress$set(message = "Obteniendo muestra aleatoria", value = 3)
      Sys.sleep(time = 0.5)
      getquery.positions <- dbGetQuery(conn, eval(query.positions.expr))
      
    }
    else {
      
      message("   *** Positions < thresholdQuery: Get positions ***")
      sql.positions <- paste0("SELECT ST_X(posiciones.wkb_geometry::geometry) AS x, 
                                      ST_Y(posiciones.wkb_geometry::geometry) AS y,
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
      progress$set(message = paste0("Obteniendo ", getquery.positions.counts$count, " registros en total"), value = 4)
      getquery.positions <- dbGetQuery(conn, eval(query.positions.expr))
    }
    
    progress$set(message = "Desconectando de la Base de Datos", value = 5)
    message("Disconnect from PostgreSQL")
    dbDisconnect(conn)  # Disconnect
    
    # Make points df
    if (nrow(getquery.positions) > 0) {
      
      progress$set(message = "Construyendo mapa", value = 6)
      message("> Creating heatmap <")
      points <-
        cbind(st_coordinates(st_as_sf(getquery.positions, coords = c("x", "y"), crs = 4326, dim = "XY")),
              getquery.positions[, -c(1,2)])
    } 
    else {
      points <- NULL
    }
    
    #positionsQry.df <<- points
    progress$set(message = "Terminado!", value = 5)
    message("Finished")
    
    # Send hide modal to client
    modal <- "close"
    session$sendCustomMessage(type = "modal", modal)
    
    # Return
    return(points)
    
  }
  
  # Map -------------------------------------------------- 
  
  output$divHtml <- renderUI({
    
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
                      numberOfVessels, " ", stringBarco, "', 9500, 'rounded');", sep = "")
      
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
                     positions, " posiciones ', 8000, 'rounded'); \n", sep = "")
      toast2 <- paste("Materialize.toast('<i class=material-icons>info_outline </i>", 
                      numberOfVessels, "  ", stringBarco, "', 9500, 'rounded'); \n", sep = "")
      
      j <- paste0("[", render.df$Y, ",", render.df$X,"]", collapse = ",")
      j <- paste0("[", j, "]")
      
      mapa <- HTML(paste0("<script> \n", 
                          sprintf("var buildingsCoords = %s; \n", j), 
                          "buildingsCoords = buildingsCoords.map(function(p) {return [p[0], p[1]];}); \n
                         if(map.hasLayer(heat)) {map.removeLayer(heat);} \n
                         var heat = L.heatLayer(buildingsCoords, {minOpacity:", renderConfig.df$opacity, 
                          ", radius:", renderConfig.df$radius, ", ", renderConfig.df$colorGradient, ", blur:", renderConfig.df$blur, 
                          "}).addTo(map); \n", toast, toast2, "</script>"), sep = "")
    }
    
    return(mapa)
    
  })
  
  # Table of data ----------------------------------------
  
  output$table <- renderDataTable({
    
    # Send hide modal to client
    modal <- "open"
    session$sendCustomMessage(type = "modal", modal)
    
    # Create a Progress object
    progress <- shiny::Progress$new(min = 0, max = 1)
    
    # Send show modal to client
    modal <- "open"
    session$sendCustomMessage(type = "modal", modal)
    
    # Close it on exit
    on.exit(progress$close())
    
    progress$set(message = "Creando tabla", value = 0)
    
    
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
    
    progress$set(message = "Termiando", value = 1)
    
    # Send hide modal to client
    modal <- "close"
    session$sendCustomMessage(type = "modal", modal)
    
    return(table)
    
  })
  
  # ScatterPlot Speed ------------------------------------
  
  output$scatterPlotSpeed <- renderPlot({
    
    # Create a Progress object
    progress <- shiny::Progress$new(min = 0, max = 1)
    
    # Send show modal to client
    modal <- "open"
    session$sendCustomMessage(type = "modal", modal)
    
    # Close it on exit
    on.exit(progress$close())
    
    # Get input data
    plotInputs <- getClientPlot()
    
    progress$set(message = "Construyendo gráfica", value = 0)
    
    message("*** Rendering speed scatterplot ***")
    
    speedMin <- min(plotInputs$plotData$Velocidad, na.rm = TRUE)
    speedMax <- max(plotInputs$plotData$Velocidad, na.rm = TRUE)
    start.end <- plotInputs$startEnd
    
    # ggplot
    ggScatterPlot <- ggplot(plotInputs$plotData) + 
      geom_point(aes(x = Tiempo, y = Velocidad, color = Nombre), alpha = 0.5, shape = 19, stroke = 0.5, size = 2, show.legend = TRUE) + 
      scale_x_datetime(name = "Tiempo", date_labels = "%b %y", date_breaks = "1 month", date_minor_breaks = "1 week", limits = start.end) + 
      scale_y_continuous(name = "Velocidad (kn)", breaks = seq(speedMin, speedMax, by = 0.5), limits = c(speedMin, speedMax)) + 
      scale_color_discrete("Barcos") + 
      theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "bottom", 
            plot.margin = margin(t = 0, unit = "cm"))
    
    progress$set(message = "Finalizado", value = 1)
    
    # Send hide modal to client
    modal <- "close"
    session$sendCustomMessage(type = "modal", modal)
    
    return(ggScatterPlot)
    
  })
  
  # Histogram speed --------------------------------------
  
  output$plotHistSpeed <- renderPlot({
    
    # Create a Progress object
    progress <- shiny::Progress$new(min = 0, max = 1)
    
    # Send show modal to client
    modal <- "open"
    session$sendCustomMessage(type = "modal", modal)
    
    # Close it on exit
    on.exit(progress$close())
    
    # Get input data
    plotInputs <- getClientPlot()
    
    progress$set(message = "Construyendo gráfica", value = 0)
    
    message("*** Rendering Histogram of speeds ***")
    
    speedMin <- min(plotInputs$plotData$Velocidad, na.rm = TRUE)
    speedMax <- max(plotInputs$plotData$Velocidad, na.rm = TRUE) 
    
    # ggplot
    ggHistogramRight <- ggplot(plotInputs$plotData) + 
      geom_histogram(aes(Velocidad, fill = ..count..), alpha = 0.75, breaks = seq(speedMin, speedMax, by = 0.1), show.legend = FALSE) + 
      scale_x_continuous(name = "Velocidad (kn)", breaks = seq(speedMin, speedMax, by = 0.5), limits = c(speedMin, speedMax), labels = waiver()) +
      scale_y_continuous(name = "Frecuencia") + 
      scale_fill_distiller("Frecuencia velocidades", palette = "PuBu", direction = 1) + 
      coord_flip() + 
      theme(plot.margin = margin(t = 0, b = 2.3, unit = "cm"))
    
    progress$set(message = "Finalizado", value = 1)
    
    # Send hide modal to client
    modal <- "close"
    session$sendCustomMessage(type = "modal", modal)
    
    return(ggHistogramRight)
    
  })
  
  # Histogram signals ------------------------------------
  
  output$plotHistSignals <- renderPlot({
    
    message("*** Rendering Histogram of signals ***")
    
    # Create a Progress object
    progress <- shiny::Progress$new(min = 0, max = 1)
    
    # Send show modal to client
    modal <- "open"
    session$sendCustomMessage(type = "modal", modal)
    
    # Close it on exit
    on.exit(progress$close())
    
    # Get input data
    plotInputs <- getClientPlot()
    
    progress$set(message = "Construyendo gráfica", value = 0)
    
    message("*** Rendering Histogram of speeds ***")
    
    speedMin <- min(plotInputs$plotData$Velocidad, na.rm = TRUE)
    speedMax <- max(plotInputs$plotData$Velocidad, na.rm = TRUE) 
    start.end <- plotInputs$startEnd
    ndays <- plotInputs$nDays
    
    # ggplot
    ggHistogramTop <- ggplot(plotInputs$plotData) + 
      geom_histogram(aes(Tiempo, fill = ..count..), alpha = 0.75, bins = as.numeric(ndays)/4, show.legend = FALSE) + 
      scale_y_continuous(name = "Emisiones") +
      scale_x_datetime(name = "Tiempo", date_labels = "%b %y", date_breaks = "1 month", date_minor_breaks = "1 week", limits = start.end) + 
      scale_fill_distiller("Frecuencia emisiones", palette = "PuBu", direction = 1) + 
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    progress$set(message = "Finalizado", value = 1)
    
    # Send hide modal to client
    modal <- "close"
    session$sendCustomMessage(type = "modal", modal)
    
    return(ggHistogramTop)
    
  })
  
})