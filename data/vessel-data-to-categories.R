library(readr)

# Cargar datos 
fishing_vessels_ARG_URY <- read_delim("data/fishing-vessels-ARG-URY.txt", "\t", escape_double = FALSE, trim_ws = TRUE)

# Cambiar nombre de columnas
colnames(fishing_vessels_ARG_URY) <- c("nombre", "señal", "matrícula", "país", "categoría", "eslora", "puerto")

# Seleccionar por categorías

catA <- subset(fishing_vessels_ARG_URY, categoría == "A", "nombre")

catA <- c("ATLANTIC BEATRICE", "ATLANTIC JANE", "ATLANTIC MARGARET", "ATLANTIC RUTHANN", "CORAL", "MARIAMME", "NILTO I", "PROMOPES I", "PROMOPES 2", "ZAANDAM", "ZURITA")



unique(fishing_vessels_ARG_URY$categoría)


