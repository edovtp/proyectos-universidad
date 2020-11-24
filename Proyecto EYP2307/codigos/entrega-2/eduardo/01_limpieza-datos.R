library(readr)
library(here)
library(lubridate)

# LIMPIEZA DE DATOS 1
datos <- read_csv(here::here("datos", "sin-procesar", "popularidad_noticias.csv"))
drop <- c("weekday_is_monday", "weekday_is_tuesday",
          "weekday_is_wednesday", "weekday_is_thursday",
          "weekday_is_friday", "weekday_is_saturday", "weekday_is_sunday",
          "data_channel_is_lifestyle", "data_channel_is_entertainment",
          "data_channel_is_bus", "data_channel_is_socmed",
          "data_channel_is_tech", "data_channel_is_world",
          "url", "timedelta")
datos <- select(datos, !drop)

# write_csv(datos, here::here("datos", "procesados", paste0(today(), "_ONP-eduardo.csv")))
rm(drop)

# LIMPIEZA DE DATOS 2
datos <- read_csv(here::here("datos", "sin-procesar", "popularidad_noticias.csv"))
drop <- c("dia_de_la_semana", "tipo_noticia", "url", "timedelta")
datos <- select(datos, !drop)

write_csv(datos, here::here("datos", "procesados", paste0(today(), "_ONP-eduardo.csv")))