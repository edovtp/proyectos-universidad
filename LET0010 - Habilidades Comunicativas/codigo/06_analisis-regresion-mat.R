library(here)
library(readr)
library(tidyverse)
library(car)
library(EnvStats)
library(DescTools)
library(lmtest)
library(ggthemes)


# REGRESIÓN MATEMÁTICAS -------------------------------------------------------------------------

datos_matematicas <- read_csv(here::here("datos", "procesados", "2020-11-26_notas-mat.csv"))
str(datos_matematicas)

variables_numericas <- c("edad", "educacion_madre", "educacion_padre", "tiempo_viaje",
                         "tiempo_estudio", "reprobaciones", "relacion_familiar", 
                         "tiempo_libre", "salir", "alcohol_dia", "alcohol_fin_de_semana",
                         "salud", "ausencias")
matriz_correlacion_mat <- cor(datos_matematicas[variables_numericas], datos_matematicas$nota_final)

reg_simple_mat <- lm(nota_final~reprobaciones, data=datos_matematicas)
summary(reg_simple_mat)

reg_multiple_mat <- lm(nota_final~., data=datos_matematicas)
summary(reg_multiple_mat)
AIC(reg_multiple_mat)
BIC(reg_multiple_mat)

# Selección automática de modelos
biggest <- formula(lm(nota_final~., data=datos_matematicas))
lin.mod.forward <- step(lm(nota_final~1, data=datos_matematicas), direction="forward", scope=biggest, trace=0)
summary(lin.mod.forward)
AIC(lin.mod.forward)
BIC(lin.mod.forward)

lin.mod.backward <- step(lm(nota_final~., data=datos_matematicas), direction = "backward", trace = 0)
summary(lin.mod.backward)
AIC(lin.mod.backward)
BIC(lin.mod.backward)

lin.mod.stepwise <- step(lm(nota_final~., data=datos_matematicas), direction="both", trace=0)
summary(lin.mod.stepwise)
AIC(lin.mod.stepwise)
BIC(lin.mod.stepwise)

# Usando add1
modelo <- lm(nota_final~1, data=datos_matematicas)
add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final~1 + reprobaciones)

add1(modelo, scope=biggest, test="Chisq")
modelo <- update(modelo, nota_final~1 + reprobaciones + educacion_madre)

add1(modelo, scope=biggest, test="Chisq")
modelo <- update(modelo, nota_final~1 + reprobaciones + educacion_madre + sexo)

add1(modelo, scope=biggest, test="Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + educacion_madre + sexo + salir)

add1(modelo, scope=biggest, test="Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + educacion_madre + sexo + salir + trabajo_madre)

add1(modelo, scope = biggest, test="Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + educacion_madre + sexo + salir +
                   trabajo_madre + relacion_amorosa)

add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + educacion_madre + sexo + salir +
                   trabajo_madre + relacion_amorosa + soporte_familiar)

add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + educacion_madre + sexo + salir +
                   trabajo_madre + relacion_amorosa + soporte_familiar + tiempo_estudio)

add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + educacion_madre + sexo + salir +
                   trabajo_madre + relacion_amorosa + soporte_familiar + tiempo_estudio +
                   ausencias)

add1(modelo, scope = biggest, test = "Chisq")

formula(modelo)

# Análisis de supuestos
ri <- tibble(rstandard(modelo)) %>% 
  rename("residuos" = `rstandard(modelo)`)


# Normalidad
ggplot(ri, aes(x = residuos, y = ..density..)) +
  geom_histogram(binwidth = 0.3, fill = colorblind_pal()(8)[3],
                 colour = "#009E73") +
  labs(title = "Distribución de los residuos del modelo",
       subtitle = "Modelo matemáticas", y = "densidad") +
  theme_minimal()

ggsave(here::here("figuras", "08_distribucion-residuos-matematicas.png"), width = 4.2, height = 3)

ri <- rstandard(modelo)

ks.test(ri, "pnorm")
JarqueBeraTest(as.vector(ri))

# Homocedasticidad
bptest(modelo)

# Independencia
dwtest(modelo)

# Transformacion
boxcox <- function(lambda){
  model <- lm(data = datos_matematicas, (nota_final^lambda - 1)/lambda ~ reprobaciones +
                educacion_madre + sexo + salir + trabajo_madre + relacion_amorosa +
                soporte_familiar + tiempo_estudio + ausencias)
  standardized_residuals <- rstandard(model)
  print(ks.test(standardized_residuals, "pnorm")$p.value)
}

grid <- seq(0.1, 3, 0.1)
for (lambda in grid) {
  print(lambda)
  boxcox(lambda)
  print(" ")
}

grid2 <- seq(1.5, 1.7, 0.01)
for (lambda in grid2){
  print(lambda)
  boxcox(lambda)
  print(" ")
}

# Lambda óptimo de 1.57

modelo_final <- lm(data = datos_matematicas, (nota_final^1.57 - 1)/1.57 ~ reprobaciones + 
                     educacion_madre + sexo + salir + trabajo_madre + relacion_amorosa + 
                     soporte_familiar + tiempo_estudio + ausencias)
summary(modelo_final)

# Análisis de supuestos
ri <- rstandard(modelo_final)

# Normalidad
hist(ri)
ks.test(ri, "pnorm")
JarqueBeraTest(ri)

# Homocedasticidad
bptest(modelo_final)

# Independencia
dwtest(modelo_final)
