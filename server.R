library("shiny")

# Load data
# 1 million rows
ais <- readRDS("data/aisData.rds")
# vms <- readRDS("data/vms.rds")

shinyServer(function(input, output) {
  
  output$plot <- renderPlot({
    
    plot <- plot(x = ais$LON[1:1000], y = ais$LAT[1:1000], xlab = "Longitud", ylab = "Latitud", pch = 19, col = "black")
    return(plot)
    
  })
  
  
  output$divHtml <- renderUI({
    
   radius <- input$radius
   colorGradient <- input$color
   opacity <- input$opacity
   blur <- input$blur

    # TIMESTAMP >= input$dateFrom & TIMESTAMP <= input$dateUntil
    # substring()
    
    dfSubset <- subset(x = ais[1:100000,], select = c("LON", "LAT", "SPEED"))
    
    nrow(dfSubset)
    
    j <- paste0("[", dfSubset[, "LAT"], ",", dfSubset[, "LON"], ",", dfSubset[, "SPEED"], "]", collapse = ",")
    j <- paste0("[", j, "]")
    
    mapa <- HTML(
      paste(
        "<script>",
        sprintf("var buildingsCoords = %s;", j),
        "buildingsCoords = buildingsCoords.map(function(p) {
          return [p[0], p[1]];});
          if(map.hasLayer(heat)) {
          map.removeLayer(heat);  
                                };
          var heat = L.heatLayer(buildingsCoords, {minOpacity:", opacity,", radius:", radius, colorGradient, ", blur:", blur,"}).addTo(map);
          </script>"
      ), sep = "")
    
    return(mapa)
    
  })
  
})
