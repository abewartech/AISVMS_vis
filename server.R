# Packages ----------------------------------------------------------------
library("shiny")
library("fasttime")

# Global data -------------------------------------------------------------

ais <- readRDS("data/aisData.rds") # 1 million rows
ais <- subset(x = ais[1:100000,], select = c("LON", "LAT", "TIMESTAMP"))
ais$TIMESTAMP <- fastPOSIXct(x = ais$TIMESTAMP)

# Initial values
dateFrom <- min(ais$TIMESTAMP)
dateUntil <- max(ais$TIMESTAMP)
dateFromQuery <- dateFrom
dateUntilQuery <- dateUntil


# vms <- readRDS("data/vms.rds")

# Shiny Server ------------------------------------------------------------

shinyServer(function(input, output) {
   

  # Data --------------------------------------------------------------------
  
  ais_df <- reactive({
    
    # Query time
    if(input$dateFrom == ""){
      dateFromQuery <- dateFrom
    } else {
      dateFromQuery <- input$dateFrom
    }
    if(input$dateUntil == ""){
      dateUntilQuery <- dateUntil
    } else {
      dateUntilQuery <- input$dateUntil
    }
    
    ais_df <- subset(x = ais, subset = TIMESTAMP >= dateFromQuery & TIMESTAMP <= dateUntilQuery, select = c("LON", "LAT", "TIMESTAMP"))
    
    return(ais_df)
    
  })


  # Point cloud -------------------------------------------------------------

  output$plot <- renderPlot({
    
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

   print(nrow(ais_df))
   print(dateFromQuery)
   print(dateUntilQuery)
   
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



