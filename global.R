# Packages -----------------------------------------------

library("shiny")
library("DBI")
library("RPostgreSQL")
library("sf")
library("wkb")
library("plotly")
#library("fasttime")
#library("lubridate")

# Disable scientific notation 
options(scipen = 999)

# Global variables ---------------------------------------

# Initial query values - default
qryVal.df <- data.frame('thresholdPoints' = 1000000,
                        'dateFrom' = "2012-05-08",
                        'dateUntil' = "2014-05-17",
                        'searchVesselName' = "ALDEBARAN I",
                        'vesselSpeedMin' = 0,
                        'vesselSpeedMax' = 20)

# Initial config values for heatmap - default
config.df <- data.frame('opacity' = 0.8,
                        'radius' = 1,
                        'colorGradient' = "''",
                        'blur' = 1)


# Query values -  customization
qryValCustom.df <- qryVal.df

# Config values -  customization 
configCustom.df <- config.df

# Empty df to push data from DB
positionsQry.df <- data.frame()

# Fishing Vessels categories from URY
catA <- c("ATLANTIC BEATRICE", "ATLANTIC JANE", "ATLANTIC MARGARET", "ATLANTIC RUTHANN", "CORAL", "MARIAMME", "NILTO I", "PROMOPES I", "PROMOPES 2", "ZAANDAM", "ZURITA")
