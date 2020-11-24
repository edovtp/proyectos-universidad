library(readr)
library(scales)
library(tidyverse)
library(cowplot)
library(knitr)
library(here)
library(lubridate)
library(car)


# 2) Proponer modelos múltiples --------------------------------------------------------------------

# CARGA DE DATOS SIN día_de_la_semana
datos <- read_csv(here::here("datos", "procesados", "2020-11-18_ONP-eduardo.csv"))
datos$tipo_noticia <- factor(datos$tipo_noticia,
                             levels=c("Entretenimiento", "Negocios", "Tecnología",
                                      "Mundo", "Estilo de vida", "Otro",
                                      "Redes sociales"),
                             labels=c("Entretenimiento", "Negocios", "Tecnología",
                                      "Mundo", "Estilo de vida", "Otro",
                                      "Redes sociales"))
datos <- select(datos, !dia_de_la_semana)
datos <- relocate(datos, shares, .after = last_col())

# ELIMINACIÓN DE VARIABLES CON PROBLEMAS DE MULTICOLINEALIDAD
# Primero, el modelo completo
lin.mod.completo <- lm(shares~., data = datos)
summary(lin.mod.completo)

# Vamos eliminando las variables con alto VIF
vif(lin.mod.completo)
lista_vif = vif(lin.mod.completo)[, 1]
(indice <- which.max(lista_vif)) # LDA_03
datos <- datos[, -indice]

lin.mod.completo <- lm(shares~. , data=datos)
summary(lin.mod.completo)
vif(lin.mod.completo)
lista_vif <- vif(lin.mod.completo)[, 1]
(indice <- which.max(lista_vif)) # n_unique_tokens
datos <- datos[, -indice]

lin.mod.completo <- lm(shares~.,  data=datos)
summary(lin.mod.completo)
vif(lin.mod.completo)
lista_vif <- vif(lin.mod.completo)[, 1]
(indice <- which.max(lista_vif)) # n_non_stop_words
datos <- datos[, -indice]

lin.mod.completo <- lm(shares~.,  data=datos)
summary(lin.mod.completo)
vif(lin.mod.completo)
lista_vif <- vif(lin.mod.completo)[, 1]
(indice <- which.max(lista_vif)) # tipo_noticia 94.8794
datos <- datos[, -indice]

lin.mod.completo <- lm(shares~.,  data=datos)
summary(lin.mod.completo)
vif(lin.mod.completo)
lista_vif <- vif(lin.mod.completo)[, 1]
(indice <- which.max(lista_vif)) # self_reference_avg_sharess
datos <- datos[, -indice]



# Elimino las variables con VIF > 10 vistas en exploratorio 1
drop <- c("LDA_03", "n_unique_tokens", "n_non_stop_words",
          "self_reference_avg_sharess", "rate_positive_words",
          "kw_max_min")
datos <- select(datos, !drop)

# Primer modelo propuesto: modelo completo sin variables categóricas
rm(drop)
lin.mod.1 <- lm(shares~. -tipo_noticia - is_weekend, data=datos)
summary(lin.mod.1) # R2 de 0.02082
AIC(lin.mod.1)     # AIC de 853932.9
BIC(lin.mod.1)     # BIC de 854276.4

# Segundo modelo propuesto: con variables categoricas
lin.mod.2 <- lm(shares~., data=datos)
summary(lin.mod.2) # R2 de 0.0214
AIC(lin.mod.2)     # AIC de 853916.5
BIC(lin.mod.2)     # BIC de 854320.1

## Ahora, usamos selección de modelos para hacer esto más fácil
# Forward
biggest <- formula(lm(shares~., data=datos))
lin.mod.forward <- step(lm(shares~1, data=datos), direction="forward", scope=biggest, trace=0)
summary(lin.mod.forward) # R2 de 0.02156
AIC(lin.mod.forward)     # AIC de 853892.1
BIC(lin.mod.forward)     # BIC de 854141.1

# Backward
lin.mod.backward <- step(lm(shares~., data=datos), direction="backward", trace=0)
summary(lin.mod.backward) # R2 de 0.02156
AIC(lin.mod.backward)     # AIC de 853892.1
BIC(lin.mod.backward)     # BIC de 854141.1

# Stepwise
lin.mod.stepwise <- step(lm(shares~., data=datos), direction="both", trace=0)
summary(lin.mod.stepwise) # R2 de 0.02157
AIC(lin.mod.stepwise)     # AIC de 853894.6
BIC(lin.mod.stepwise)     # BIC de 854169.4

# 3) Elegir el mejor modelo ------------------------------------------------------------------------

# Me quedo con el modelo backward usando is_weekend
lin.mod <- lin.mod.backward
rm(lin.mod.1, lin.mod.2, lin.mod.3, lin.mod.backward, lin.mod.backward.2,
   lin.mod.forward, lin.mod.forward.2, lin.mod.stepwise, lin.mod.stepwise.2)

# 4) Verificar supuestos ------------------------------------------------------------------------
# Normalidad (No podemos concluir normalidad)
ri <- rstandard(lin.mod)
hist(ri, breaks=100, probability=TRUE)
curve(dnorm(x), col="blue", lwd=2, add=TRUE)

qqnorm(ri, pch=19)
qqline(ri, col="red")

ks.test(ri, "pnorm")

# Boxcox
plot(lin.mod$fitted.values, datos$shares)
require(EnvStats)
lambda = boxcox(lin.mod, optimize = TRUE)$lambda
if (lambda == 0){
  datos_weekend$shares <- log(datos_weekend$shares)
} else {
  datos_weekend$shares <- (datos_weekend$shares^lambda - 1)/lambda
}

lin.mod <- lm(formula(lin.mod), data=datos_weekend)
ri <- rstandard(lin.mod)
hist(ri, breaks=100, probability = TRUE)
curve(dnorm(x), col="blue", lwd=2, add=TRUE)

qqnorm(ri, pch=19)
qqline(ri, col="red")

ks.test(ri, "pnorm")

# Independencia (Sí se sumple)
plot(ri, pch=19, type="b")
require(lmtest)
dwtest(lin.mod, alternative="two.sided")

# Homocedasticidad (No podemos concluir homocedasticidad)
plot(lin.mod$fitted.values, ri)
bptest(lin.mod)