library(readr)
library(scales)
library(tidyverse)
library(cowplot)
library(knitr)
library(here)
library(lubridate)
library(car)
library(EnvStats)
library(lmtest)


# 1) Problemática del avance 1 --------------------

# Variables poco correlacionadas con la respuesta
# Gran cantidad de outliers
# Gran cantidad de parámetros

# 2) Proponer modelos múltiples -----------------------------------------------------------------

# CARGA DE DATOS SIN WEEKEND
datos <- read_csv(here::here("datos", "procesados", "2020-11-18_ONP-eduardo.csv"))

datos$dia_de_la_semana <- factor(datos$dia_de_la_semana, 
                                 levels=c("Lunes", "Martes", "Miércoles", "Jueves",
                                          "Viernes", "Sábado", "Domingo"),
                                 labels=c("Lunes", "Martes", "Miércoles", "Jueves",
                                          "Viernes", "Sábado", "Domingo"))
datos$tipo_noticia <- factor(datos$tipo_noticia,
                             levels=c("Entretenimiento", "Negocios", "Tecnología",
                                      "Mundo", "Estilo de vida", "Otro",
                                      "Redes sociales"),
                             labels=c("Entretenimiento", "Negocios", "Tecnología",
                                      "Mundo", "Estilo de vida", "Otro",
                                      "Redes sociales"))
datos <- select(datos, !is_weekend)
datos <- relocate(datos, shares, .after = last_col())
str(datos)

# ELIMINACIÓN DE VARIABLES CON PROBLEMAS DE MULTICOLINEALIDAD
# Primero, el modelo completo sin tipo_noticia ni dia_de_la_semana
lin.mod.completo <- lm(shares~. -tipo_noticia -dia_de_la_semana, data = datos)
summary(lin.mod.completo)

# Vamos eliminando variables con alto VIF
lista_vif <- vif(lin.mod.completo)
(indice <- which.max(lista_vif)) # LDA_03
datos <- datos[, -indice]

lin.mod.completo <- lm(shares~. -tipo_noticia -dia_de_la_semana, data=datos)
summary(lin.mod.completo)
lista_vif <- vif(lin.mod.completo)
(indice <- which.max(lista_vif)) # n_unique_tokens
datos <- datos[, -indice]

lin.mod.completo <- lm(shares~. -tipo_noticia -dia_de_la_semana,  data=datos)
summary(lin.mod.completo)
lista_vif <- vif(lin.mod.completo)
(indice <- which.max(lista_vif)) # n_non_stop_words
datos <- datos[, -indice]

lin.mod.completo <- lm(shares~. -tipo_noticia -dia_de_la_semana,  data=datos)
summary(lin.mod.completo)
lista_vif <- vif(lin.mod.completo)
(indice <- which.max(lista_vif)) # self_reference_avg_shares
datos <- datos[, -indice]

lin.mod.completo <- lm(shares~. -tipo_noticia -dia_de_la_semana,  data=datos)
summary(lin.mod.completo)
lista_vif <- vif(lin.mod.completo)
(indice <- which.max(lista_vif)) # rate_positive_words
datos <- datos[, -indice]

lin.mod.completo <- lm(shares~. -tipo_noticia -dia_de_la_semana,  data=datos)
summary(lin.mod.completo)
lista_vif <- vif(lin.mod.completo)
(indice <- which.max(lista_vif)) # kw_max_min
datos <- datos[, -indice]

lin.mod.completo <- lm(shares~. -tipo_noticia -dia_de_la_semana, data=datos)
summary(lin.mod.completo)
vif(lin.mod.completo)

rm(indice, lista_vif, lin.mod.completo)

# Ahora tenemos solamente variables con VIF menores a 10, donde eliminamos las variables
# LDA_03: 9.8*10^8, n_unique_tokens: 13431.6, n_non_stop_words: 2073.7,
# self_reference_avg_shares: 19.1, rate_positive_words: 17.92, kw_max_min: 11.1

# Primer modelo propuesto: modelo completo sin variables categóricas
lin.mod.1 <- lm(shares~. -dia_de_la_semana -tipo_noticia, data=datos)
summary(lin.mod.1) # R2 de 0.02082
AIC(lin.mod.1)     # AIC de 853932.9
BIC(lin.mod.1)     # BIC de 854276.4

# Segundo modelo propuesto: con variables categoricas
lin.mod.2 <- lm(shares~., data=datos)
summary(lin.mod.2) # R2 de 0.02156
AIC(lin.mod.2)     # AIC de 853914.1
BIC(lin.mod.2)     # BIC de 854360.7

# Tercer modelo propuesto: Usado en regresión simple
lin.mod.3 <- lm(shares~kw_avg_avg, data=datos)
summary(lin.mod.3) # R2 de 0.01217
AIC(lin.mod.3)     # AIC de 854244.9
BIC(lin.mod.3)     # BIC de 854270.7

## Ahora, usamos selección de modelos para hacer esto más fácil
# Forward
biggest <- formula(lm(shares~., data=datos))
lin.mod.forward <- step(lm(shares~1, data=datos), direction="forward", scope=biggest, trace=0)
summary(lin.mod.forward) # R2 de 0.02174
AIC(lin.mod.forward)     # AIC de 853889.9
BIC(lin.mod.forward)     # BIC de 854181.9

# Backward
lin.mod.backward <- step(lm(shares~., data=datos), direction="backward", trace=0)
summary(lin.mod.backward) # R2 de 0.02174
AIC(lin.mod.backward)     # AIC de 853889.9
BIC(lin.mod.backward)     # BIC de 854181.9

# Stepwise
lin.mod.stepwise <- step(lm(shares~., data=datos), direction="both", trace=0)
summary(lin.mod.stepwise) # R2 de 0.02174
AIC(lin.mod.stepwise)     # AIC de 853889.9
BIC(lin.mod.stepwise)     # BIC de 854181.9


## Acá parece que hay un error: Los R2 tienen que ser iguales
# Un problema con estos modelos: siempre consideran intercepto:
# Forward
biggest <- formula(lm(shares~., data=datos))
lin.mod.forward.si <- step(lm(shares~-1, data=datos), direction="forward", scope=biggest, trace=0)
summary(lin.mod.forward.si) # R2 de 0.09859
AIC(lin.mod.forward.si)     # AIC de 853889.9
BIC(lin.mod.forward.si)     # BIC de 854181.9

# Backward
lin.mod.backward.si <- step(lm(shares~.-1, data=datos), direction="backward", trace=0)
summary(lin.mod.backward.si) # R2 de 0.09817
AIC(lin.mod.backward.si)     # AIC de 853904.3
BIC(lin.mod.backward.si)     # BIC de 854162

# Stepwise
lin.mod.stepwise.si <- step(lm(shares~.-1, data=datos), direction="both", trace=0)
summary(lin.mod.stepwise.si) # R2 de 0.09817
AIC(lin.mod.stepwise.si)     # AIC de 853904.3
BIC(lin.mod.stepwise.si)     # BIC de 854162

# 3) Elegir el mejor modelo ------------------------------------------------------------------------

# Me quedo con el modelo backward sin intercepto
lin.mod <- lin.mod.backward.si
rm(lin.mod.1, lin.mod.2, lin.mod.3, lin.mod.backward, lin.mod.backward.si,
   lin.mod.forward, lin.mod.forward.si, lin.mod.stepwise, lin.mod.stepwise.si, biggest)

# 4) Verificar supuestos ------------------------------------------------------------------------
# Normalidad (No podemos concluir normalidad)
# Problema: La gran mayoría de residuos son positivos -> El modelo tiende a subestimar demasiado
ri <- rstandard(lin.mod)
hist(ri, breaks=100, probability=TRUE)
curve(dnorm(x), col="blue", lwd=2, add=TRUE)

qqnorm(ri, pch=19)
qqline(ri, col="red")

# Independencia (Sí podemos concluir independencia)
plot(ri, pch=19, type="b")
dwtest(lin.mod, alternative="two.sided")

# Homocedasticidad (No podemos concluir homocedasticidad)
plot(lin.mod$fitted.values, ri, ylim=c(-10, 75))
bptest(lin.mod)

# Búsqueda de puntos de influencia
# DFFITS
ylab <- "|DFFITS|"
p <- length(lin.mod$coefficients)
n <- length(datos$shares)
cutoff <- 2*sqrt(p/n)
DFFITS_abs <- abs(dffits(lin.mod))
plot(DFFITS_abs, ylab=ylab, pch=19, col=ifelse(DFFITS_abs > cutoff, "blue", "black"),
     xlab="índice", main="Búsqueda de puntos de influencia sobre su valor ajustado")
abline(h=cutoff, col="red", lwd=2, lty=2)

dffits_altos <- names(which(DFFITS_abs > cutoff)) # 571 en total

# Distancia de Cook
Di <- cooks.distance(lin.mod)
xlab <- "indice"
title <- "Búsqueda usando distancia de Cook"
plot(Di, pch=19, ylab="Distancia de Cook", ylim=c(0, 1), main = title, xlab=xlab)
abline(h=1, col="red", lty=2, lwd=2) # Esperable al ser n muy grande

# COVRATIO
COVRATIO <- covratio(lin.mod)
xlab <- "índice"
title <- "Búsqueda de puntos de influencia usando COVRATIO"
plot(COVRATIO, pch=19, ylab="COVRATIO", xlab=xlab, main=title, col=ifelse(COVRATIO > 1+3*p/n | COVRATIO < 1-3*p/n, "blue", "black"))
abline(h=1, col="blue", lty=2, lwd=2)
abline(h=1+3*p/n, col="red", lty=2, lwd=2)
abline(h=1-3*p/n, col="red", lty=2, lwd=2)

indices_covratio <- names(which(COVRATIO > 1 + 3*p/n | COVRATIO < 1 - 3*p/n)) # 1575 en total

# Vemos la unión de ambos conjuntos
ambos <- union(dffits_altos, indices_covratio)
length(ambos)  # 1682 observaciones en total

# Consideramos estas como las más problemáticas y las eliminamos
indices_influencia <- as.numeric(ambos)
datos <- datos[-indices_influencia, ]

# Ajustamos el modelo nuevamente
lin.mod <- lm(shares~n_tokens_title + n_tokens_content + num_hrefs + 
                num_self_hrefs + average_token_length + num_keywords + kw_min_min + 
                kw_min_max + kw_min_avg + kw_max_avg + kw_avg_avg + self_reference_min_shares + 
                self_reference_max_shares + LDA_02 + global_subjectivity + 
                global_rate_positive_words + min_positive_polarity + avg_negative_polarity + 
                abs_title_subjectivity + abs_title_sentiment_polarity + dia_de_la_semana + 
                tipo_noticia - 1, data=datos)
summary(lin.mod) # R2 de 0.4186
AIC(lin.mod) # 721807.1
BIC(lin.mod) # 722097.6

# Verificamos los supuestos otra vez
# Normalidad (Sigue sin complirse)
ri <- rstandard(lin.mod)
hist(ri, breaks=100, probability=TRUE)
curve(dnorm(x), col="blue", lwd=2, add=TRUE)

qqnorm(ri, pch=19)
qqline(ri, col="red")

ks.test(ri, "pnorm")

# Independencia (Sí se cumple, valor-p no tan bajo)
plot(ri, pch=19, type="b")
dwtest(lin.mod, alternative="two.sided")

# Homocedasticidad (No podemos concluir homocedasticidad)
plot(lin.mod$fitted.values, ri)
bptest(lin.mod)

# Probamos con box-cox
plot(lin.mod$fitted.values, datos$shares)
lambda = boxcox(lin.mod, optimize = TRUE)$lambda
datos2 <- datos
datos2$shares <- (datos$shares^lambda- 1)/lambda
lin.mod.boxcox <- lm(shares~., data=datos2)
summary(lin.mod.boxcox)

# Vemos los supuestos
# Normalidad
ri <- rstandard(lin.mod.boxcox)
hist(ri, breaks=100, probability=TRUE)
curve(dnorm(x), col="blue", lwd=2, add=TRUE)

qqnorm(ri, pch=19)
qqline(ri, col="red")

ks.test(ri, "pnorm")

# Independencia (No se cumple)
plot(ri, pch=19, type="b")
dwtest(lin.mod.boxcox, alternative="two.sided")

# Homocedasticidad (No podemos concluir homocedasticidad)
plot(lin.mod$fitted.values, ri)
bptest(lin.mod.boxcox)

## Idea para la conclusión: Considerar modelo con errores de colas más pesadas y/o asimétricas