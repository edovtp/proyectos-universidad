library(dplyr)
library(here)
library(lubridate)
library(readr)


# En ambos casos, estamos interesados solamente en las notas finales "G3"
# Además, creo que reason y nursery no son variables significativa para nuestro análisis

renombrar <- function(nombres_antiguos){
  nom_atributos <- c("escuela", "sexo", "edad", "tipo_hogar", "tamano_familia", "estado_padres", 
                     "educacion_madre", "educacion_padre", "trabajo_madre", "trabajo_padre", 
                     "apoderado", "tiempo_viaje", "tiempo_estudio", "reprobaciones",
                     "soporte_educacional", "soporte_familiar", "pago_extra", "actividades",
                     "ed_superior", "internet", "relacion_amorosa", "relacion_familiar",
                     "tiempo_libre", "salir", "alcohol_dia", "alcohol_fin_de_semana", 
                     "salud", "ausencias", "nota_final")
}

datos_matematicas <- read.csv(here::here("datos", "sin-procesar", "student-mat.csv")) %>% 
  select(!c(reason, nursery, G1, G2)) %>%
  rename_with(renombrar) %>%
  mutate(sexo = factor(ifelse(sexo == "F", "M", "H"))) %>%
  mutate(tamano_familia = factor(ifelse(tamano_familia == "LE3", "Mayor3", "IMenor3"))) %>%
  mutate(estado_padres = factor(ifelse(estado_padres == "T", "J", "S"))) %>%
  mutate(trabajo_madre = factor(ifelse(trabajo_madre == "teacher", "profesora",
                                       ifelse(trabajo_madre == "health", "salud", 
                                              ifelse(trabajo_madre == "services", "publico",
                                                     ifelse(trabajo_madre == "at_home",
                                                            "en_casa", "otro")))))) %>%
  mutate(trabajo_padre = factor(ifelse(trabajo_padre == "teacher", "profesor",
                                       ifelse(trabajo_padre == "health", "salud", 
                                              ifelse(trabajo_padre == "services", "publico", 
                                                     ifelse(trabajo_padre == "at_home",
                                                            "en_casa", "otro")))))) %>%
  mutate(apoderado = factor(ifelse(apoderado == "mother", "madre", "padre"))) %>%
  mutate(soporte_educacional = factor(ifelse(soporte_educacional == "yes", "si", "no"))) %>%
  mutate(soporte_familiar = factor(ifelse(soporte_familiar == "yes", "si", "no"))) %>%
  mutate(pago_extra = factor(ifelse(pago_extra == "yes", "si", "no"))) %>%
  mutate(actividades = factor(ifelse(actividades == "yes", "si", "no"))) %>%
  mutate(ed_superior = factor(ifelse(ed_superior == "yes", "si", "no"))) %>%
  mutate(internet = factor(ifelse(internet == "yes", "si", "no"))) %>%
  mutate(relacion_amorosa = factor(ifelse(relacion_amorosa == "yes", "si", "no")))

datos_portugues <- read.csv(here::here("datos", "sin-procesar", "student-por.csv")) %>% 
  select(!c(reason, nursery, G1, G2)) %>%
  rename_with(renombrar) %>%
  mutate(sexo = factor(ifelse(sexo == "F", "M", "H"))) %>%
  mutate(tamano_familia = factor(ifelse(tamano_familia == "LE3", "IMayor3", "IMenor3"))) %>%
  mutate(estado_padres = factor(ifelse(estado_padres == "T", "J", "S"))) %>%
  mutate(trabajo_madre = factor(ifelse(trabajo_madre == "teacher", "profesora",
                                       ifelse(trabajo_madre == "health", "salud", 
                                              ifelse(trabajo_madre == "services", "publico",
                                                     ifelse(trabajo_madre == "at_home",
                                                            "en_casa", "otro")))))) %>%
  mutate(trabajo_padre = factor(ifelse(trabajo_padre == "teacher", "profesor",
                                       ifelse(trabajo_padre == "health", "salud", 
                                              ifelse(trabajo_padre == "services", "publico", 
                                                     ifelse(trabajo_padre == "at_home",
                                                            "en_casa", "otro")))))) %>%
  mutate(apoderado = factor(ifelse(apoderado == "mother", "madre", "padre"))) %>%
  mutate(soporte_educacional = factor(ifelse(soporte_educacional == "yes", "si", "no"))) %>%
  mutate(soporte_familiar = factor(ifelse(soporte_familiar == "yes", "si", "no"))) %>%
  mutate(pago_extra = factor(ifelse(pago_extra == "yes", "si", "no"))) %>%
  mutate(actividades = factor(ifelse(actividades == "yes", "si", "no"))) %>%
  mutate(ed_superior = factor(ifelse(ed_superior == "yes", "si", "no"))) %>%
  mutate(internet = factor(ifelse(internet == "yes", "si", "no"))) %>%
  mutate(relacion_amorosa = factor(ifelse(relacion_amorosa == "yes", "si", "no")))

# Guardamos los csv respectivos

write_csv(datos_matematicas, here::here("datos", "procesados", paste0(today(), "_notas-mat.csv")))
write_csv(datos_portugues, here::here("datos", "procesados", paste0(today(), "_notas-por.csv")))


