library(readr)
library(here)


datos_matematicas <- read_csv(here::here("datos", "procesados", "2020-11-26_notas-mat.csv"))
datos_portugues <- read_csv(here::here("datos", "procesados", "2020-11-26_notas-por.csv"))

# Tenemos 29 variables en ambas bases 
ncol(datos_matematicas)

# Tenemos 395 estudiantes de matemáticas, 649 de portugués
nrow(datos_matematicas)
nrow(datos_portugues)

# Nombres de los atributos de los datos
names(datos_matematicas)

# Summary de los datos
summary(datos_matematicas)
summary(datos_portugues)

# Estadísticas de las notas
minimo_mat <- min(datos_matematicas$nota_final)
primer_cuartil_mat <- quantile(datos_matematicas$nota_final, 0.25)
media_mat <- mean(datos_matematicas$nota_final)
mediana_mat <- median(datos_matematicas$nota_final)
tercer_cuartil_mat <- quantile(datos_matematicas$nota_final, 0.75)
maximo_mat <- max(datos_matematicas$nota_final)

minimo_por <- min(datos_portugues$nota_final)
primer_cuartil_por <- quantile(datos_portugues$nota_final, 0.25)
media_por <- mean(datos_portugues$nota_final)
mediana_por <- median(datos_portugues$nota_final)
tercer_cuartil_por <- quantile(datos_portugues$nota_final, 0.75)
maximo_por <- max(datos_portugues$nota_final)