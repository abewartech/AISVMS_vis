library(dygraphs)
library(xts)
library(ggplot2)
library(gridExtra)

table <- positionsQry.df
table$speed <- table$speed / 10
table$course <- table$course / 10
table$heading <- table$heading / 10
colnames(table) <- c("Longitud", "Latitud", "Nombre", "MMSI", "Estado", "Velocidad", "Curso", "Orientación", "Tiempo")

if (nrow(table) >= 10000) {
  table <- table[sample(x = 1:nrow(table), size = 10000),]
}

# Plotly
p <- plot_ly(table, x = ~Tiempo, y = ~Velocidad, color = ~Nombre,
             type = 'scatter', mode = 'markers', 
             marker = list(size = 5, opacity = 0.8),
             symbols = 'circle', text = paste(" Barco:", table$Nombre, "<br> Velocidad:", table$Velocidad, "kn", '<br> Fecha:', table$Tiempo))

p %>%
  layout(title = "Perfil de Velocidad",
         xaxis = list(title = "Tiempo"),
         yaxis = list (title = "Velocidad (kn)"))


# ggplot2 independents

start.end <- c(min(table$Tiempo, na.rm = TRUE), max(table$Tiempo, na.rm = TRUE))
ndays <- difftime(time1 = start.end[2], time2 = start.end[1], units = "days")

ggScatterplot <- ggplot(table) + 
  geom_point(aes(x = Tiempo, y = Velocidad, color = Nombre), alpha = 0.5, shape = 19, size = 2, show.legend = TRUE) + 
  scale_x_datetime(name = "Tiempo", date_labels = "%b %y", date_breaks = "1 month", date_minor_breaks = "1 week", limits = start.end) + 
  scale_y_continuous(name = "Velocidad (kn)", breaks = seq(0, 11, by = 0.5), limits = c(0, 11)) + 
  scale_color_brewer("Barcos", palette = "Accent") + 
  theme_dark() + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.position = "bottom")

ggHistogramRight <- ggplot(table) + 
  geom_histogram(aes(Velocidad, fill = ..count..), alpha = 0.75, breaks = seq(0, 11, by = 0.2), show.legend = FALSE) + 
  scale_x_continuous(name = "Velocidad (kn)", breaks = seq(0, 11, by = 0.5), limits = c(0, 11)) +
  scale_y_continuous(name = "Frecuencia", position = "top") + 
  scale_fill_distiller("Frecuencia velocidades", palette = "PuBu", direction = 1) + 
  coord_flip() + 
  theme_dark()

ggHistogramTop <- ggplot(table) + 
  geom_histogram(aes(Tiempo, fill = ..count..), alpha = 0.75, bins = as.numeric(ndays), show.legend = FALSE) + 
  scale_y_continuous(name = "Emisiones") +
  scale_x_datetime(name = "Tiempo", date_labels = "%b %y", date_breaks = "1 month", date_minor_breaks = "1 week", limits = start.end) + 
  scale_fill_distiller("Frecuencia emisiones", palette = "PuBu", direction = 1) + 
  theme_dark() + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
  



# ggplotly
ggplotly(p = ggHistogramTop)
ggplotly(p = ggScatterplot)

# ggplot

start.end <- c(min(table$Tiempo, na.rm = TRUE), max(table$Tiempo, na.rm = TRUE))
ndays <- difftime(time1 = start.end[2], time2 = start.end[1], units = "days")

ggScatterplot <- ggplot(table) + 
  geom_point(aes(x = Tiempo, y = Velocidad, color = Nombre), alpha = 0.5, shape = 19, size = 2, show.legend = FALSE) + 
  scale_x_datetime(name = "Tiempo", date_labels = "%b %y", date_breaks = "1 month", date_minor_breaks = "1 week", limits = start.end) + 
  scale_y_continuous(name = "Velocidad (kn)", breaks = seq(0, 11, by = 0.5), limits = c(0, 11)) + 
  scale_color_brewer("Barcos", palette = "Accent") + 
  theme_dark() + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.position = "bottom", plot.margin = margin(r = -10, t = -10, unit = "cm"))

ggHistogramRight <- ggplot(table) + 
  geom_histogram(aes(Velocidad, fill = ..count..), alpha = 0.75, breaks = seq(0, 11, by = 0.2), show.legend = FALSE) + 
  scale_x_continuous(name = "", breaks = seq(0, 11, by = 0.5), limits = c(0, 11)) +
  scale_y_continuous(name = "Frecuencia", position = "top") + 
  scale_fill_distiller("Frecuencia velocidades", palette = "PuBu", direction = 1) + 
  coord_flip() + 
  theme_dark() + 
  theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank()) 

ggHistogramTop <- ggplot(table) + 
  geom_histogram(aes(Tiempo, fill = ..count..), alpha = 0.75, bins = as.numeric(ndays), show.legend = FALSE) + 
  scale_y_continuous(name = "Emisiones", position = "right") +
  scale_x_datetime(name = "Velocidad", date_labels = "%b %y", date_breaks = "1 month", date_minor_breaks = "1 week", limits = start.end, position = "top") + 
  scale_fill_distiller("Frecuencia emisiones", palette = "PuBu", direction = 1) + 
  theme_dark() + 
  theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank())

cowplot::plot_grid(ggHistogramTop, NULL, ggScatterplot, ggHistogramRight, ncol = 2, nrow = 2, rel_widths = c(4, 1), rel_heights = c(1, 4), align ='vh')


# ggplotly
ggplotly(p = ggHistogramTop)
ggplotly(p = ggScatterplot)


