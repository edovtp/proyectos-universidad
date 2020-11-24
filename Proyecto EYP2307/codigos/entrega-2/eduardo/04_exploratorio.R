library(readr)
library(scales)
library(tidyverse)
library(cowplot)
library(knitr)
library(here)
library(lubridate)
library(car)


# 2) Proponer modelos múltiples -----------------------------------------------------------------

# CARGA DE DATOS SIN WEEKEND
datos <- read_csv(here::here("datos", "procesados", "2020-11-20_ONP-eduardo.csv"))
datos <- select(datos, !is_weekend)

# ELIMINACIÓN DE VARIABLES CON PROBLEMAS DE MULTICOLINEALIDAD
# Primero, el modelo completo
lin.mod.completo <- lm(shares~.-1, data=datos)
summary(lin.mod.completo)

# Vamos eliminando variables con alto VIF
vif(lin.mod.completo)
(indice <- which.max(vif(lin.mod.completo)))
