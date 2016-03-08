library("shiny")

# Load data
# 1 million rows
ais <- readRDS("data/aisData.rds")
# vms <- readRDS("data/vms.rds")

shinyServer(function(input, output) {
  
  # Datos
  ais_df <- reactive({
    
    # TIMESTAMP >= input$dateFrom & TIMESTAMP <= input$dateUntil
    # substring()
    
    ais_df <- subset(x = ais[1:100000,], select = c("LON", "LAT", "SPEED"))
    
    return(ais_df)
    
  })
  
  
  # Plot de puntos
  output$plot <- renderPlot({
    
    ais_df <- ais_df()
    
    plot <- plot(x = ais_df$LON[1:10000], y = ais_df$LAT[1:10000], xlab = "Longitud", ylab = "Latitud", pch = 19, col = "black")
    
    return(plot)
    
  })
  
  # Mapa
  output$divHtml <- renderUI({
    
   radius <- input$radius
   colorGradient <- input$color
   opacity <- input$opacity
   blur <- input$blur
   
   ais_df <- ais_df()
   
   j <- paste0("[", ais_df[, "LAT"], ",", ais_df[, "LON"], ",", ais_df[, "SPEED"], "]", collapse = ",")
   j <- paste0("[", j, "]")
   
   mapa <- HTML(
     paste(
       "<script>",
       sprintf("var buildingsCoords = %s;", j),
"buildingsCoords = buildingsCoords.map(function(p) {return [p[0], p[1]];});
if(map.hasLayer(heat)) {map.removeLayer(heat);};
var heat = L.heatLayer(buildingsCoords, {minOpacity:", opacity,", radius:", radius, colorGradient, ", blur:", blur,"}).addTo(map);
</script>"), sep = "")
   
   return(mapa)
   })
  
  # Tabla de datos consultados
  
  output$table <- renderDataTable({
    ais_df()
    })
    
})
