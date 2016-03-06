library("shiny")

# Load data
ais <- readRDS("data/ais.rds")
vms <- readRDS("data/vms.rds")

shinyServer(function(input, output) {
  
  output$plot <- renderPlot({
    
    plot(1:100)
    
  })
  
  
})