library(readr)
library(scales)
library(tidyverse)
library(cowplot)
library(knitr)
library(here)


# 2) Proponer modelos múltiples

# Carga de datos sin variables categóricas
datos <- read_csv(here::here("datos", "procesados", "2020-11-20_ONP-eduardo.csv"))
