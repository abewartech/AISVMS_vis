library("shiny")

# Load data
# ais <- readRDS("data/ais.rds")
# vms <- readRDS("data/vms.rds")

shinyServer(function(input, output) {
  
  output$plot <- renderPlot({
    
    plot <- plot(x = 1:100, y = 1:100, xlab = "Longitud", ylab = "Latitud")
    return(plot)
    
  })
  
  
})