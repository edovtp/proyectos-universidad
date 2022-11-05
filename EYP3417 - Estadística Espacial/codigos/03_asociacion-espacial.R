library(spdep)
library(ggplot2)
library(rgeoda)
library(patchwork)


# Vemos los vecinos de Santiago
vecinos_santiago <- spdep::poly2nb(presidenciales_santiago, queen = TRUE)

lineas_vecinos <- listw2lines(nb2listw(vecinos_santiago),
                              coords = presidenciales_santiago$geometry)

tm_shape(basemap) +
  tm_rgb() +
  tm_shape(presidenciales_santiago) +
  tm_polygons(col = "lightblue") +
  tm_shape(lineas_vecinos) +
  tm_lines() +
  tm_layout(main.title = "Vecinos de Santiago")

# Gráficos de Moran
grafico_moran <- function(año, vuelta){
  titulo <- paste(ifelse(vuelta == 1, "Primera", "Segunda"), "vuelta", año)
  subtitulo <- "Densidad aproximada del estadístico de Moran, junto al valor observado"
  
  moran_test <- spdep::moran.mc(presidenciales_santiago$tasa_participación_2013_1,
                                listw = nb2listw(vecinos_santiago, style = "B"),
                                nsim = 5000)
  
  simulaciones <- moran_test$res
  simulaciones <- simulaciones[seq_len(length(simulaciones) - 1)]
  observado <- moran_test$statistic
  
  ggplot(as_tibble(simulaciones)) +
    geom_density(aes(x = value)) +
    geom_vline(xintercept = observado, lwd = 1, lty = "dashed", col = "turquoise") +
    xlim(-0.5, 0.5) +
    labs(title = titulo, subtitle = subtitulo, y = "Densidad", x = "I")
}

grafico_moran(2013, 1)
grafico_moran(2013, 2)
grafico_moran(2017, 1)
grafico_moran(2017, 2)

# Gráficos de Geary
grafico_geary <- function(año, vuelta){
  titulo <- paste(ifelse(vuelta == 1, "Primera", "Segunda"), "vuelta", año)
  subtitulo <- "Densidad aproximada del estadístico de Geary, junto al valor observado"
  
  geary_test <- spdep::geary.mc(presidenciales_santiago$tasa_participación_2013_1,
                                listw = nb2listw(vecinos_santiago, style = "B"),
                                nsim = 5000)
  
  simulaciones <- geary_test$res
  simulaciones <- simulaciones[seq_len(length(simulaciones) - 1)]
  observado <- geary_test$statistic
  
  ggplot(as_tibble(simulaciones)) +
    geom_density(aes(x = value)) +
    geom_vline(xintercept = observado, lwd = 1, lty = "dashed", col = "turquoise") +
    xlim(0.45, 1.6) +
    labs(title = titulo, subtitle = subtitulo, y = "Densidad", x = "C")
}

grafico_geary(2013, 1)
grafico_geary(2013, 2)
grafico_geary(2017, 1)
grafico_geary(2017, 2)

# Gráfico conjunto de Moran y de Geary
moran_2017 <- grafico_moran(2017, 1)
geary_2017 <- grafico_geary(2017, 1)

pathchwork_autocorrelacion <- moran_2017 / geary_2017

pathchwork_autocorrelacion + plot_annotation(title = "Participación electoral año 2017")

# Autocorrelación local
aux <- spdep::localG_perm(presidenciales_santiago$votos_2013_1,
              listw = nb2listw(include.self(vecinos_santiago), style = "B"),
              return_internals = TRUE)


pesos_rgeoda <- rgeoda::queen_weights(presidenciales_santiago)
gstar_rgeoda <- rgeoda::local_gstar(
  pesos_rgeoda, presidenciales_santiago["tasa_participación_2017_1"], permutations = 2000)
lisa_colors <- lisa_colors(gstar_rgeoda)
lisa_labels <- lisa_labels(gstar_rgeoda)
lisa_clusters <- lisa_clusters(gstar_rgeoda)

plot(st_geometry(presidenciales_santiago),
     col = sapply(lisa_clusters, function(x){lisa_colors[[x+1]]}))


# # Coeficiente de Moran
# ## 2013 - Primera vuelta
# plot(spdep::moran.mc(presidenciales_santiago$tasa_participación_2013_1,
#                 listw = nb2listw(vecinos_santiago, style = "B"),
#                 nsim = 5000))
# 
# ## 2013 - Segunda vuelta
# spdep::moran.mc(presidenciales_santiago$tasa_participación_2013_2, 
#                 listw = nb2listw(vecinos_santiago, style = "B"),
#                 nsim = 2000)
# 
# ##  2017 - Primera vuelta
# spdep::moran.mc(presidenciales_santiago$tasa_participación_2017_1,
#                 listw = nb2listw(vecinos_santiago, style = "B"),
#                 nsim = 2000)
# 
# ## 2017 - Segunda vuelta
# spdep::moran.mc(presidenciales_santiago$tasa_participación_2017_2,
#                 listw = nb2listw(vecinos_santiago, style = "B"),
#                 nsim = 2000)
# 
# # Coeficiente de Geary's
# spdep::geary.mc(presidenciales_santiago$tasa_participación_2013_1,
#                 listw = nb2listw(vecinos_santiago, style = "B"),
#                 nsim = 2000)
# 
# spdep::geary.mc(presidenciales_santiago$tasa_participación_2013_2, 
#                 listw = nb2listw(vecinos_santiago, style = "B"),
#                 nsim = 2000)
# 
# spdep::geary.mc(presidenciales_santiago$tasa_participación_2017_1,
#                 listw = nb2listw(vecinos_santiago, style = "B"),
#                 nsim = 2000)
# 
# spdep::geary.mc(presidenciales_santiago$tasa_participación_2017_2,
#                 listw = nb2listw(vecinos_santiago, style = "B"),
#                 nsim = 2000)
#
