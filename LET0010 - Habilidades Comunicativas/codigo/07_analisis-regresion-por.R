library(here)
library(readr)
library(tidyverse)
library(car)
library(EnvStats)
library(DescTools)
library(lmtest)


# REGRESIÓN PORTUGUÉS -------------------------------------------------------------------------

datos_portugues <- read_csv(here::here("datos", "procesados", "2020-11-26_notas-por.csv"))

variables_numericas <- c("edad", "educacion_madre", "educacion_padre", "tiempo_viaje",
                         "tiempo_estudio", "reprobaciones", "relacion_familiar", 
                         "tiempo_libre", "salir", "alcohol_dia", "alcohol_fin_de_semana",
                         "salud", "ausencias")
matriz_correlacion_por <- cor(datos_portugues[variables_numericas], datos_portugues$nota_final)

reg_simple_por <- lm(nota_final~reprobaciones, data=datos_portugues)
summary(reg_simple_por)

reg_multiple_por <- lm(nota_final~., data=datos_portugues)
summary(reg_multiple_por)
AIC(reg_multiple_por)
BIC(reg_multiple_por)

# Selección automática de modelos
biggest <- formula(lm(nota_final~., data=datos_portugues))
lin.mod.forward <- step(lm(nota_final~1, data=datos_portugues), direction="forward", scope=biggest, trace=0)
summary(lin.mod.forward)
AIC(lin.mod.forward)
BIC(lin.mod.forward)

lin.mod.backward <- step(lm(nota_final~., data=datos_portugues), direction = "backward", trace = 0)
summary(lin.mod.backward)
AIC(lin.mod.backward)
BIC(lin.mod.backward)

lin.mod.stepwise <- step(lm(nota_final~., data=datos_portugues), direction="both", trace=0)
summary(lin.mod.stepwise)
AIC(lin.mod.stepwise)
BIC(lin.mod.stepwise)

# Usando add1
modelo <- lm(nota_final~1, data=datos_portugues)
add1(modelo, scope = biggest, test="Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones)

add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + escuela)

add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + escuela + ed_superior)

add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + escuela + ed_superior + 
                   tiempo_estudio)

add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + escuela + ed_superior +
                   tiempo_estudio + soporte_educacional)

add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + escuela + ed_superior +
                   tiempo_estudio + soporte_educacional + alcohol_dia)

add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + escuela + ed_superior + 
                   tiempo_estudio + soporte_educacional + alcohol_dia + educacion_madre)

add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + escuela + ed_superior + 
                   tiempo_estudio + soporte_educacional + alcohol_dia + educacion_madre +
                   salud)

add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + escuela + ed_superior + 
                   tiempo_estudio + soporte_educacional + alcohol_dia + educacion_madre +
                   salud + sexo)

add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + escuela + ed_superior + 
                   tiempo_estudio + soporte_educacional + alcohol_dia + educacion_madre +
                   salud + sexo + apoderado)

add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + escuela + ed_superior + 
                   tiempo_estudio + soporte_educacional + alcohol_dia + educacion_madre +
                   salud + sexo + apoderado + relacion_amorosa)

add1(modelo, scope = biggest, test = "Chisq")
modelo <- update(modelo, nota_final ~ 1 + reprobaciones + escuela + ed_superior + 
                   tiempo_estudio + soporte_educacional + alcohol_dia + educacion_madre +
                   salud + sexo + apoderado + relacion_amorosa + edad)

add1(modelo, scope = biggest, test = "Chisq")
formula(modelo)

# Análisis de supuestos
ri <- rstandard(modelo)

# Normalidad
hist(ri)
ks.test(ri, "pnorm")
JarqueBeraTest(ri)

# Homocedasticidad
bptest(modelo)

# Independencia
dwtest(modelo)

# Transformacion
boxcox <- function(lambda){
  model <- lm(data = datos_portugues, (nota_final^lambda - 1)/lambda ~ reprobaciones + escuela +
                ed_superior +
                tiempo_estudio + soporte_educacional + alcohol_dia + educacion_madre + salud +
                sexo + apoderado + relacion_amorosa + edad)
  standardized_residuals <- rstandard(model)
  print(ks.test(standardized_residuals, "pnorm")$p.value)
}

grid <- seq(0.1, 3, 0.1)
for (lambda in grid) {
  print(lambda)
  boxcox(lambda)
  print(" ")
}

grid2 <- seq(1.2, 1.4, 0.01)
for (lambda in grid2){
  print(lambda)
  boxcox(lambda)
  print(" ")
}

# Lambda óptimo de 1.34

modelo_final <- lm(data = datos_portugues, (nota_final^1.34 - 1)/1.34 ~ reprobaciones +
                     escuela + ed_superior +
                     tiempo_estudio + soporte_educacional + alcohol_dia + educacion_madre + salud +
                     sexo + apoderado + relacion_amorosa + edad)
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
