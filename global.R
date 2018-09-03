# Packages -----------------------------------------------

library(shiny)
library(DBI)
library(RPostgreSQL)
#library(jsonlite)
library(sf)
#library(leaflet)
library(ggplot2)

# Disable scientific notation 
options(scipen = 999)

# Global variables ---------------------------------------

# Initial query values - default
qryVal.df <- data.frame('thresholdPoints' = 200000,
                        'dateFrom' = "2012-05-08",
                        'dateUntil' = "2014-05-17",
                        'searchVesselName' = "ALDEBARAN I",
                        'vesselSpeedMin' = 0,
                        'vesselSpeedMax' = 15, 
                        'catA' = FALSE,
                        'catB' = FALSE,
                        'catC' = FALSE,
                        'catD' = FALSE,
                        'catAltura' = FALSE,
                        'catCosteros' = FALSE)

# Initial config values for heatmap - default
config.df <- data.frame('opacity' = 0.8,
                        'radius' = 1,
                        'colorGradient' = "gradient: {0.4:'blue',0.6:'cyan',0.7:'lime',0.8:'yellow',1:'red'}",
                        'blur' = 1)


# Query values -  customization
qryValCustom.df <- qryVal.df

# Config values -  customization 
configCustom.df <- config.df

# Empty df to push data from DB
positionsQry.df <- data.frame()

# Shapefiles
# limitesURY <- read_sf("data/shp/c100Polygon.shp")
