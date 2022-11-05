library(tmap)


# Mapa base Santiago
basemap <- tmaptools::read_osm(x = presidenciales_santiago, ext = 1.05)
saveRDS(basemap, file = "datos/basemap.rds")

# Gráficos de la tasa de participación
mapa_tasa_participacion <- function(año, vuelta){
  titulo_plot <- paste("Participación electoral año", año, "-",
                       ifelse(vuelta == 1, "primera", "segunda"), "vuelta")
  
  tm_shape(basemap) +
    tm_rgb() +
    tm_shape(presidenciales_santiago) +
    tm_borders() +
    tm_fill(paste("tasa_participación", año, vuelta, sep = "_"),
            title = "Tasa de participación", breaks = seq(0.3, 0.8, 0.05),
            legend.format = list(text.separator = "-",
                                 fun=function(x) paste0(
                                   formatC(x*100, digits = 0, format="f"), "%"))) +
    tm_layout(main.title = titulo_plot,
              legend.outside = TRUE, legend.title.size = 1.5, legend.outside.size = 0.18,
              legend.text.size = 1)
}

mapa_tasa_participacion(2013, 1)
mapa_tasa_participacion(2013, 2)
mapa_tasa_participacion(2017, 1)
mapa_tasa_participacion(2017, 2)

# Gráficos con covariables
## Ingreso medio
mapa_ingreso_medio <- tm_shape(basemap) +
  tm_rgb() +
  tm_shape(presidenciales_santiago) +
  tm_borders() +
  tm_fill("ingreso_medio", title = "Ingreso medio",
          legend.format = list(text.separator = "a"),
          breaks = c(500, 750, 1000, 1250, 1500, 1750, 2000, 2250, 2500, 2750, 3000)) +
  tm_layout(legend.title.size = 2, legend.bg.color = "gray95",
            legend.frame = TRUE, legend.outside = TRUE, legend.text.size = 1.5,
            main.title = "Ingreso medio año 2017")

## Proporcion gasto en educación
mapa_gasto_educacion <- tm_shape(basemap) +
  tm_rgb() +
  tm_shape(presidenciales_santiago) +
  tm_borders() +
  tm_fill("tasa_gasto_educacion", title = "% Gasto educación",
          legend.format = list(text.separator = "-", 
                               fun=function(x) paste0(
                                 formatC(x*100, digits = 0, format="f"), "%"))) +
  tm_layout(legend.title.size = 2, legend.bg.color = "gray95", legend.frame = TRUE,
            legend.outside = TRUE, main.title = "Gasto municipal en educación, año 2017",
            legend.text.size = 1.3)

mapa_gasto_educacion

## Porcentaje de hacinamiento
mapa_hacinamiento <- tm_shape(basemap) +
  tm_rgb() +
  tm_shape(presidenciales_santiago) +
  tm_borders() +
  tm_fill("porcentaje_hacinamiento", title = "% de hacinamiento",
          legend.format = list(text.separator = "-", 
                               fun=function(x) paste0(
                                 formatC(x, digits = 0, format="f"), "%"))) +
  tm_layout(legend.title.size = 2, legend.bg.color = "gray95", legend.frame = TRUE,
            legend.outside = TRUE)

## Porcentaje de pobreza
mapa_pobreza <- tm_shape(basemap) +
  tm_rgb() +
  tm_shape(presidenciales_santiago) +
  tm_borders() +
  tm_fill("porcentaje_pobreza", title = "% de pobreza",
          legend.format = list(text.separator = "a")) +
  tm_layout(legend.title.size = 2, legend.bg.color = "gray95", legend.frame = TRUE,
            legend.outside = TRUE)

## Mapa completo
arreglo <- tmap_arrange(mapa_ingreso_medio, mapa_gasto_educacion,
                        mapa_pobreza, mapa_hacinamiento)

tmap_save(tm = arreglo, "www/arreglo.png", width = 2100, height = 1600)
