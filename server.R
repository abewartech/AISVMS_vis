# Packages ----------------------------------------------------------------
library("shiny")
library("fasttime")
library("lubridate")

# Global data -------------------------------------------------------------

ais <- readRDS("data/aisData.rds") # 1 million rows
colnames(ais)[1] <- c("MMSI")
ais <- subset(x = ais[1:500000, ], select = c("LON", "LAT", "TIMESTAMP", "MMSI"))
ais$TIMESTAMP <- fastPOSIXct(x = ais$TIMESTAMP)

# Initial values
dateFrom <- min(ais$TIMESTAMP)
dateUntil <- max(ais$TIMESTAMP)
dateFromQuery <- dateFrom
dateUntilQuery <- dateUntil

# Not all vessel names
vesselNames <- unique(ais$MMSI)[1:100]

# vms <- readRDS("data/vms.rds")

# Shiny Server ------------------------------------------------------------

shinyServer(function(input, output) {
  
  
  # Data --------------------------------------------------------------------
  
  ais_df <- reactive({
    
    # Query time
    if(input$dateFrom == "")
    {
      dateFromQuery <- dateFrom
    } 
    else
    {
      dateFromQuery <- input$dateFrom
    }
    if(input$dateUntil == "")
    {
      dateUntilQuery <- dateUntil
    }
    else 
    {
      dateUntilQuery <- input$dateUntil
    }
    
    ais_df <- subset(x = ais, subset = TIMESTAMP >= dateFromQuery & TIMESTAMP <= dateUntilQuery, select = c("LON", "LAT", "TIMESTAMP", "MMSI"))
    
    # Query vessel name
    if(input$searchVesselName == "") 
    {
      if(is.null(input$selectVesselName))
      {
        VesselNameQuery <- vesselNames
      } 
      else
      {
        VesselNameQuery <- input$selectVesselName
      }
    }
    else 
    {
      VesselNameQuery <- input$searchVesselName
    }
    
    if(length(VesselNameQuery) == 1) 
    {
      ais_df <- subset(x = ais_df, subset = MMSI == VesselNameQuery, select = c("LON", "LAT", "TIMESTAMP", "MMSI"))
    } 
    else 
    {
      listQueriedVesselsNames <- list()
      for(i in 1:length(VesselNameQuery)) 
      {
        listQueriedVesselsNames[[i]] <- subset(x = ais_df, subset = MMSI == VesselNameQuery[i], select = c("LON", "LAT", "TIMESTAMP", "MMSI"))
      }
      ais_df <- do.call("rbind", listQueriedVesselsNames)
    }
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
    
    numberOfVessels <- length(unique(ais_df$MMSI))
    
    # number of rows to toast
    # Materialize.toast(message, displayLength, className, completeCallback);
    toast <- paste("Materialize.toast('<i class=material-icons>location_on </i>", nrow(ais_df), " posiciones ', 8000, 'rounded');", sep = "")
    toast2 <- paste("Materialize.toast('<i class=material-icons>info_outline </i>", numberOfVessels, " barcos ', 9500, 'rounded');", sep = "")
    
    j <- paste0("[", ais_df[, "LAT"], ",", ais_df[, "LON"], "]", collapse = ",")
    j <- paste0("[", j, "]")
    
    mapa <- HTML(
      paste(
        "<script>",
        sprintf("var buildingsCoords = %s;", j),
        "buildingsCoords = buildingsCoords.map(function(p) {return [p[0], p[1]];});
if(map.hasLayer(heat)) {map.removeLayer(heat);};
var heat = L.heatLayer(buildingsCoords, {minOpacity:", opacity,", radius:", radius, colorGradient, ", blur:", blur,"}).addTo(map);",
        toast,
        toast2,
        "</script>"), sep = "")
    
    return(mapa)
    
  })
  
  # Table of data -----------------------------------------------------------  
  
  output$table <- renderDataTable({
    ais_df()
  })
  
  
  # Select vessel name ------------------------------------------------------
  
  output$selectVesselName <- renderUI({
    
    # Subset
    ais_df <- ais_df()
    
    # All vessels names and total number
    vesselNames2 <- vesselNames
    numberOfVessels <- length(vesselNames2)
    
    # Selected vessels names
    vesselNamesSelected <- unique(ais_df$MMSI)
    
    # Mark as selected options the previously selected vessels
    
    if(numberOfVessels == length(vesselNamesSelected)) {
      
      options <- list()
      
      for(i in 1:numberOfVessels){
        options[[i]] <- paste("<option value='", vesselNames2[i], "'>", vesselNames2[i], "</option>", sep = "")
      }
      
      options <- do.call("rbind", options)
      
    } else {
      
      listSelectedVessels <- list()
      
      for(i in 1:numberOfVessels) {
        
        listSelectedVessels[[i]] <- which(vesselNames2[i] == vesselNamesSelected)
        
      }
      
      listSelectedVessels <- which(sapply(listSelectedVessels, length) > 0)
      lengthListSelectedVessels <- length(listSelectedVessels)
      
      options <- list()
      
      for(i in 1:numberOfVessels){
        
        encontrado <- FALSE
        
        j <- 1
        
        while(j <= lengthListSelectedVessels & !encontrado) {
          
          if(i == listSelectedVessels[j]) {
            encontrado <- TRUE
            #print("encontrado")
          }
          
          j <- j + 1
          
        }
        
        if(encontrado){
          options[[i]] <- paste("<option value='", vesselNames2[i], "' selected>", vesselNames2[i], "</option>", sep = "")
        }
        
        if(!encontrado){
          options[[i]] <- paste("<option value='", vesselNames2[i], "'>", vesselNames2[i], "</option>", sep = "")
        }
      }
      
      options <- do.call("rbind", options)
    }
    
    select <- HTML(c("<div id='selectVesselName2' class='input-field col s12'>",
                     "<select multiple name='selectVesselName2'>",
                     "<option value='' disabled>Nombre del barco</option>",
                     options,
                     "</select>",
                     "</div>",
                     "<script>$('select').material_select();</script>"))
    
    #"<script>$('#selectVesselName2').material_select('destroy'); </script>"
    #"<script>$('#selectVesselName2').material_select();</script>"
    
    return(select)
    
  })
  
  
})





