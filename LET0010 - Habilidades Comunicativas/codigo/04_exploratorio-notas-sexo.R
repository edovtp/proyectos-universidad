library(ggplot2)
library(here)
library(dplyr)
library(ggthemes)
library(hrbrthemes)
library(readr)


# Primero genero un boxplot para ver las diferencias de notas entre hombres 
# y mujeres separados por escuela

datos_matematicas <- read_csv(here::here("datos", "procesados", "2020-11-26_notas-mat.csv"))
head(notas_matematicas)

datos_matematicas %>%
  ggplot(mapping = aes(x = sexo, y = nota_final, fill = sexo)) +
  geom_boxplot() + 
  scale_fill_manual(values = colorblind_pal()(3)[-1]) +
  scale_x_discrete(labels = c("Hombre", "Mujer")) +
  theme_minimal() +
  ylim(c(0, 20)) +
  theme(legend.position = "none") +
  labs(title = "Diagramas de caja de las notas en matemáticas",
       subtitle = "Separados por sexo",
       x = "", y = "Nota final")

ggsave(here::here("figuras", "03_diferencia-notas-mat-sexo.png"), width = 4.5, height = 3)

datos_portugues <- read_csv(here::here("datos", "procesados", "2020-11-16_notas-por.csv"))
head(notas_portugues)

datos_portugues %>%
  ggplot(mapping = aes(x = sexo, y = nota_final, fill = sexo)) +
  geom_boxplot() +
  scale_fill_manual(values = colorblind_pal()(3)[-1]) +
  scale_x_discrete(labels = c("Hombre", "Mujer")) +
  theme_minimal() + 
  ylim(c(0, 20)) +
  theme(legend.position = "none") +
  labs(title = "Diagramas de caja de las notas en portugués",
       subtitle = "Separados por sexo",
       x = "", y = "Nota final")

ggsave(here::here("figuras", "04_diferencia-notas-por-sexo.png"), width = 4.5, height = 3)
