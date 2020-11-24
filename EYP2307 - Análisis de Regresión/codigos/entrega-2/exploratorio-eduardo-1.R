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

# 1) Problemática del avance 1 -----------------------------------------------------------

# Variables poco correlacionadas con la respuesta de manera individual
# Gran cantidad de outliers en nuestra base de datos
# Gran cantidad de parámetros

# 2) Proponer modelos múltiples ----------------------------------------------------------

# Carga de datos sin weekend, lo decido eliminar ya que se pierde información ------------
# al usar solo weekend, pero ahora tenemos más parámetros a estimar
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

# Eliminación de variables con problemas de multicolinealidad ----------------------------

# Eliminamos entonces 6 variables predictoras
drop <- c("LDA_03", "n_unique_tokens", "n_non_stop_words",
          "self_reference_avg_sharess", "rate_positive_words", "kw_max_min")
datos <- select(datos, !drop)
# Quedamos finalmente con 40 variables predictoras

# Propuestas de modelos ------------------------------------------------------------------
# 1.- Modelo completo sin variables categóricas
lin.mod.1 <- lm(shares~. -dia_de_la_semana -tipo_noticia, data=datos)
summary(lin.mod.1) # R2 de 0.02082
AIC(lin.mod.1)     # AIC de 853932.9
BIC(lin.mod.1)     # BIC de 854276.4

# 2.- Modelo completo sin variables categóricas
lin.mod.2 <- lm(shares~., data=datos)
summary(lin.mod.2) # R2 de 0.02158
AIC(lin.mod.2)     # AIC de 853914.1
BIC(lin.mod.2)     # BIC de 854360.7

# 3.- Modelo obtenido en el primer avance
lin.mod.3 <- lm(shares~kw_avg_avg, data=datos)
summary(lin.mod.3) # R2 de 0.01217
AIC(lin.mod.3)     # AIC de 854244.9
BIC(lin.mod.3)     # BIC de 854270.7

# Ahora usando criterios de selección de modelos
# 4.- Forward
biggest <- formula(lm(shares~., data=datos))
lin.mod.forward <- step(lm(shares~1, data=datos), direction="forward", scope=biggest, trace=0)
summary(lin.mod.forward) # R2 de 0.02174
AIC(lin.mod.forward)     # AIC de 853889.9
BIC(lin.mod.forward)     # BIC de 854181.9

# 5.- Backward
lin.mod.backward <- step(lm(shares~., data=datos), direction="backward", trace=0)
summary(lin.mod.backward) # R2 de 0.02174
AIC(lin.mod.backward)     # AIC de 853889.9
BIC(lin.mod.backward)     # BIC de 854181.9

# 6.- Stepwise
lin.mod.stepwise <- step(lm(shares~., data=datos), direction="both", trace=0)
summary(lin.mod.stepwise) # R2 de 0.02174
AIC(lin.mod.stepwise)     # AIC de 853889.9
BIC(lin.mod.stepwise)     # BIC de 854181.9

# Los tres modelos consideran variables categóricas -> No tiene sentido usar intercepto
# Contiene también exactamente las mismas variables

# 3) Elección del mejor modelo ---------------------------------------------------------------

# Nos quedamos finalmente con el modelo forward
lin.mod <- lin.mod.forward

# 4) Verificar supuestos ---------------------------------------------------------------------

# Primera verificación -----------------------------------------------------------------------

# Normalidad
# No podemos concluir normalidad, donde notamos que la gran mayoría de residuos son positivos,
# esto es, el modelo tiende a subestimar demasiado
ri <- rstandard(lin.mod)
hist(ri, breaks=100, probability = TRUE)
curve(dnorm(x), col="blue", lwd=2, add=TRUE)

qqnorm(ri, pch=19)
qqline(ri, col="red", lty=2)

ks.test(ri, "pnorm")

plot(lin.mod$fitted.values, datos$shares)
max(lin.mod$fitted.values)

# Independencia (Sí podemos concluir)
plot(ri, pch=19, type="b")
dwtest(lin.mod, alternative="two.sided")

# Homocedasticidad (No podemos concluir)
plot(lin.mod$fitted.values, ri, ylim=c(-10, 75))
abline(h=0, col="red", lty=2)
bptest(lin.mod)

# Transformación de Box-Cox primero (siempre es mejor mantener todos los datos) -----------------
plot(lin.mod$fitted.values, datos$shares)
lambda <- boxcox(lin.mod, optimize=TRUE)$lambda # -0.1410851
datos$shares2 <- (datos$shares^lambda -1)/lambda
lin.mod.boxcox <- lm(shares2 ~ kw_avg_avg + tipo_noticia + self_reference_min_shares + 
                       num_hrefs + kw_max_avg + kw_min_avg + kw_min_min + avg_negative_polarity + 
                       n_tokens_title + average_token_length + global_subjectivity + 
                       kw_min_max + LDA_02 + num_self_hrefs + dia_de_la_semana + 
                       n_tokens_content + self_reference_max_shares + global_rate_positive_words + 
                       min_positive_polarity + num_keywords + abs_title_sentiment_polarity + 
                       abs_title_subjectivity, data=datos)
summary(lin.mod.boxcox) # R2 de 0.125
AIC(lin.mod.boxcox)     # AIC de 14291.98
BIC(lin.mod.boxcox)     # BIC de 14583.96

# Segunda verificación -----------------------------------------------------------------------

# Normalidad (No podemos concluir normalidad, y ahora notamos muchos residuos negativos)
ri <- rstandard(lin.mod.boxcox)
hist(ri, breaks=100, probability = TRUE)
curve(dnorm(x), col="blue", lwd=2, add=TRUE)

qqnorm(ri, pch=19)
qqline(ri, col="red", lty=2)

ks.test(ri, "pnorm")

plot(lin.mod.boxcox$fitted.values, datos$shares2)

# Independencia (No podemos concluir independencia)
plot(ri, pch=19, type="b")
dwtest(lin.mod.boxcox, alternative="two.sided")

# Homocedasticidad (No podemos concluir homocedasticidad)
plot(lin.mod$fitted.values, ri, ylim=c(-10, 75))
abline(h=0, col="red", lty=2)
bptest(lin.mod.boxcox)

# Análisis de puntos de influencia --------------------------------------------------------------
# DFFITS
p <- length(lin.mod.boxcox$coefficients)
n <- length(datos$shares2)
cutoff <- 2*sqrt(p/n)
DFFITS_abs <- abs(dffits(lin.mod.boxcox))
dffits_altos <- names(which(DFFITS_abs > cutoff)) # 2079 en total

plot(DFFITS_abs, ylab="|DFFITS|", pch=19, col=ifelse(DFFITS_abs > cutoff, "blue", "black"),
     xlab="índice", main="Búsqueda de puntos de influencia sobre su valor ajustado")
abline(h=cutoff, col="red", lwd=2, lty=2)

# Distancia de Cook
Di <- cooks.distance(lin.mod.boxcox)
plot(Di, pch=19, ylab="Distancia de Cook", ylim=c(0, 1), main="Búsqueda usando distancia de Cook")
abline(h=1, col="red", lty=2, lwd=2) # eseprable al ser n muy grande

# COVRATIO
COVRATIO <- covratio(lin.mod.boxcox)
indices_covratio <- names(which(COVRATIO > 1 + 3*p/n | COVRATIO < 1 - 3*p/n)) # 2210 en total

xlab <- "índice"
title <- "Búsqueda de puntos de influencia usando COVRATIO"
plot(COVRATIO, pch=19, ylab="COVRATIO", xlab=xlab, main=title, col=ifelse(COVRATIO > 1+3*p/n | COVRATIO < 1-3*p/n, "blue", "black"))
abline(h=1, col="blue", lty=2, lwd=2)
abline(h=1+3*p/n, col="red", lty=2, lwd=2)
abline(h=1-3*p/n, col="red", lty=2, lwd=2)

# Vemos la unión de ambos conjuntos. Consideramos estas como las más problemáticas y 
# las eliminamos
interseccion <- intersect(dffits_altos, indices_covratio)
length(interseccion) # 1254 observaciones en total
indices_influencia <- as.numeric(interseccion)
temp <- datos
datos <- datos[-indices_influencia, ]

# Ajustamos el mismo modelo anterior nuevamente
lin.mod <- lm(formula(lin.mod.boxcox), data=datos)
summary(lin.mod) # R2 de 0.1631
AIC(lin.mod)     # AIC de 1821.317
BIC(lin.mod)     # BIC de 2112.205

# Vemos la unión de ambos conjuntos. Consideramos estas como las más problemáticas y las eliminamos
union <- union(dffits_altos, indices_covratio)
length(union) # 3035 observaciones en total
indices_influencia <- as.numeric(union)
temp <- datos
datos <- datos[-indices_influencia, ]

# Ajustamos el mismo modelo anterior nuevamente
lin.mod <- lm(formula(lin.mod.boxcox), data=datos)
summary(lin.mod) # R2 de 0.184
AIC(lin.mod)     # AIC de -4154.534
BIC(lin.mod)     # BIC de -3865.26

drop1(lin.mod, test="Chisq")
# Tercera verificación -----------------------------------------------------------------------

# Normalidad (Seguimos sin poder concluir normalidad)
ri <- rstandard(lin.mod)
hist(ri, breaks=100, probability = TRUE)
curve(dnorm(x), col="blue", lwd=2, add=TRUE)

qqnorm(ri, pch=19)
qqline(ri, col="red", lty=2)

ks.test(ri, "pnorm")

plot(lin.mod$fitted.values, datos$shares2)

# Independencia (No podemos concluir independencia)
plot(ri, pch=19, type="b")
dwtest(lin.mod, alternative="two.sided")

# Homocedasticidad (No podemos concluir homocedasticidad)
plot(lin.mod$fitted.values, ri, ylim=c(-10, 75))
abline(h=0, col="red", lty=2)
bptest(lin.mod)
