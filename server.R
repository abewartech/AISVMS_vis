# Packages ----------------------------------------------------------------
library("shiny")
library("fasttime")

# Global data -------------------------------------------------------------
ais <- readRDS("data/aisData.rds") # 1 million rows
# vms <- readRDS("data/vms.rds")

# Shiny Server ------------------------------------------------------------

shinyServer(function(input, output) {
  
  # Data --------------------------------------------------------------------
  
  ais_df <- reactive({
    
    # TIMESTAMP >= input$dateFrom & TIMESTAMP <= input$dateUntil
    # substring()
    
    ais_df <- subset(x = ais[1:100000,], select = c("LON", "LAT", "TIMESTAMP"))
    ais_df$TIMESTAMP <- fastPOSIXct(x = ais_df$TIMESTAMP)
    
    # Query
    if(input$dateFrom != ""){
      
      ais_df <- subset(x = ais_df, subset = TIMESTAMP , select = c("LON", "LAT", "TIMESTAMP"))
      
    } else {
      
      print(paste("Vacía.", input$dateFrom))
      
    }
    
    
    
    return(ais_df)
    
  })


# Point cloud -------------------------------------------------------------

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
   
   j <- paste0("[", ais_df[, "LAT"], ",", ais_df[, "LON"], "]", collapse = ",")
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
  
  # Table of data -----------------------------------------------------------  
  
  output$table <- renderDataTable({
    ais_df()
    })
    
})



