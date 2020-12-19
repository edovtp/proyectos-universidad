library(readr)
library(here)
library(ggthemes)
library(scales)
library(ggplot2)
library(tidyverse)


# Vemos la forma en que distribuyen las notas de ambas asignaturas
datos_matematicas <- read_csv(here::here("datos", "procesados", "2020-11-26_notas-mat.csv"))

datos_matematicas %>%
  ggplot(mapping = aes(y = ..prop.., x = nota_final)) +
  geom_bar(fill = colorblind_pal()(8)[3]) +
  theme_minimal() +
  ylim(0, 0.165) + 
  labs(title = "Gráfico de barras del área de matemáticas",
       x = "Nota final", y = "Proporción", subtitle = "Proporción de estudiantes por nota final")

ggsave(here::here("figuras", "01_notas-mat.png"), width = 4.2, height = 3)


datos_portugues <- read_csv(here::here("datos", "procesados", "2020-11-26_notas-por.csv"))

datos_portugues %>%
  ggplot(mapping = aes(y = ..prop.., x = nota_final)) +
  geom_bar(fill = colorblind_pal()(8)[3]) +
  theme_minimal() +
  ylim(0, 0.165) +
  labs(title = "Gráfico de barras del área de portugués",
       x = "Nota final", y = "Proporción", subtitle = "Proporción de estudiantes por nota final")

ggsave(here::here("figuras", "02_notas-por.png"), width = 4.2, height = 3)

# Porcentaje de reprobación de ambos 
table(datos_matematicas$nota_final < 10)/length(datos_matematicas$nota_final)
table(datos)
