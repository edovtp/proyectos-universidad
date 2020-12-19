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

# Quito el negro del paquete colourblind

n <- length(unique(datos_matematicas$escuela))

datos_matematicas %>%
  ggplot(mapping = aes(x = escuela, y = nota_final, fill = escuela)) +
  geom_boxplot() + 
  scale_fill_manual(values = colorblind_pal()(n + 1)[-1]) +
  scale_x_discrete(labels= c("Gabriel Pereira", "Mousinho da Silveira")) +
  theme_minimal() +
  theme(legend.position = "none") +
  ylim(c(0, 20)) +
  labs(title = "Diagramas de caja de las notas en matemáticas",
       subtitle = "Separado por escuela",
       x = "",
       y = "Nota final")

ggsave(here::here("figuras", "05_diferencia-notas-mat-escuela.png"), width = 4.5, height = 3)

datos_portugues <- read_csv(here::here("datos", "procesados", "2020-11-26_notas-por.csv"))
head(notas_portugues)

n <- length(unique(datos_portugues$escuela))

datos_portugues %>%
  ggplot(mapping = aes(x = escuela, y = nota_final, fill = escuela)) +
  geom_boxplot() +
  scale_fill_manual(values = colorblind_pal()(n + 1)[-1]) +
  scale_x_discrete(labels = c("Gabriel Pereira", "Mousinho da Silveira")) +
  theme_minimal() + 
  ylim(c(0, 20)) +
  theme(legend.position = "none") +
  labs(title = "Diagramas de caja de las notas en portugués",
       subtitle = "Separado por escuela", 
       x = "",
       y = "Nota final")

ggsave(here::here("figuras", "06_diferencia-notas-por-escuela.png"), width = 4.5, height = 3)
