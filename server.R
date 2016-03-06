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
  
  
})