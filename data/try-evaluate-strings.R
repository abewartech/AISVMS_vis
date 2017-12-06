# Try evaluate strings

# Connection
conn <- dbConnect(dbDriver("PostgreSQL"), dbname = "ais")

# Parameters
vesselNameQuery <- c("ATLANTIC BEATRICE", "ATLANTIC JANE", "ATLANTIC MARGARET", "ATLANTIC RUTHANN", "CORAL", "MARIAMME", "NILTO I", "PROMOPES I", "PROMOPES 2", "ZAANDAM", "ZURITA")
numberOfVessels <- length(vesselNameQuery)

vesselSpeedMinQuery <- 0
vesselSpeedMaxQuery <- 200
dateFromQuery <- "2012-05-08"
dateUntilQuery <- "2014-05-17"

vessels <- paste0("?vesselName", 1:numberOfVessels)
vessels <- stringr::str_c(vessels, collapse = ", ")
vessels <- paste0("(", vessels, ")")

# sql query
sql.positions.counts <- paste0("SELECT COUNT(*) 
                                FROM posiciones, barcos 
                                WHERE posiciones.mmsi = barcos.mmsi
                                AND barcos.name IN ", vessels,
                               " AND posiciones.speed BETWEEN ?vesselSpeedMin AND ?vesselSpeedMax
                                AND posiciones.timestamp BETWEEN ?dateFrom AND ?dateUntil;")

vesselsExpr <- paste0("vesselName", 1:numberOfVessels," = vesselNameQuery[", 1:numberOfVessels, "]")
vesselExpr <- stringr::str_c(vesselsExpr, collapse = ", ")

# sql interpolate
query.positions.counts.expr <- paste0("sqlInterpolate(conn, sql.positions.counts, ", vesselExpr, ", vesselSpeedMin = as.character(vesselSpeedMinQuery), vesselSpeedMax = as.character(vesselSpeedMaxQuery), dateFrom = as.character(dateFromQuery), dateUntil = as.character(dateUntilQuery))")
  
query.positions.counts.expr <- parse(text = query.positions.counts.expr)

# evaluate
getquery.positions.counts <- dbGetQuery(conn, eval(query.positions.counts.expr))
  
    