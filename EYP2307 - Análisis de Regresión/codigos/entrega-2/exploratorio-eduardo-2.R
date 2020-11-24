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
library(glmnet)
library(DescTools)

# 1) Problemática del avance 1 -----------------------------------------------------------

# Variables poco correlacionadas con la respuesta de manera individual
# Gran cantidad de outliers en nuestra base de datos
# Gran cantidad de parámetros

# 2) Proponer modelos múltiples ----------------------------------------------------------

## Carga de datos sin weekend, lo decido eliminar ya que se pierde información ------------
## al usar solo weekend, pero ahora tenemos más parámetros a estimar
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

## Eliminación de variables con problemas de multicolinealidad ----------------------------

# Eliminamos entonces 6 variables predictoras
drop <- c("LDA_03", "n_unique_tokens", "n_non_stop_words",
          "self_reference_avg_sharess", "rate_positive_words", "kw_max_min")
datos <- select(datos, !drop)
# Quedamos finalmente con 40 variables predictoras

# n_tokens_title -> cuadratica
# n_non_stop_unique_tokens <- cuadratica
# global_sentiment_polarity <- cuadrática
# max_positive_polarity <- cuadrática
# max_negative_polarity <- cuadŕatica

# problema con n_non_stop_unique_tokens, valor extremadamente inusual, ocupo la mediana
datos[31038,]$n_non_stop_unique_tokens <- median(datos$n_non_stop_unique_tokens)
# problemas con average_token_length -> valores iguales a 0
# Acordarme de esto en la conclusión.

## Propuestas de modelos ------------------------------------------------------------------
# 1.- Modelo completo sin variables categóricas
lin.mod.1 <- lm(shares~. -dia_de_la_semana -tipo_noticia, data=datos)
summary(lin.mod.1) # R2 de 0.02082
AIC(lin.mod.1)     # AIC de 853932.9
BIC(lin.mod.1)     # BIC de 854276.4

# 2.- Modelo completo con variables categóricas
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
lin.mod.backward <- step(lm(shares~. + I(max_positive_polarity^2) + I(max_negative_polarity^2), data=datos), direction="backward", trace=1)
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

# Cualquier modelo nos sirve
lin.mod <- lin.mod.forward

# 4) Verificar supuestos ---------------------------------------------------------------------

## Primera verificación -----------------------------------------------------------------------

# Normalidad
# No podemos concluir normalidad, donde notamos que la gran mayoría de residuos son positivos,
# esto es, el modelo tiende a subestimar demasiado
ri <- rstandard(lin.mod)
hist(ri, breaks=100, probability = TRUE)
curve(dnorm(x), col="blue", lwd=2, add=TRUE)

qqnorm(ri, pch=19)
qqline(ri, col="red", lty=2)

ks.test(ri, "pnorm")
JarqueBeraTest(ri)

plot(lin.mod$fitted.values, datos$shares)
max(lin.mod$fitted.values)

# Independencia (Sí podemos concluir)
plot(ri, pch=19, type="b")
dwtest(lin.mod, alternative="two.sided")

# Homocedasticidad (No podemos concluir)
plot(lin.mod$fitted.values, ri, ylim=c(-10, 75))
abline(h=0, col="red", lty=2)
bptest(lin.mod)

## Transformación de Box-Cox primero (siempre es mejor mantener todos los datos) -----------------
plot(lin.mod$fitted.values, datos$shares)
lambda <- boxcox(lin.mod, optimize=TRUE, objective.name = "Shapiro-Wilk")$lambda # -0.1413983
plot(boxcox(lin.mod, lambda = seq(-2, 2, len = 1000), objective.name = "Shapiro-Wilk"),
     xlab = expression(lambda), ylab = "Shapiro-Wilk",
     main = "Lambda óptimo para la transformación de Box-Cox")
abline(v = lambda, col = "red", lty = 2, lwd=2)

datos$shares2 <- (datos$shares^lambda -1)/lambda
lin.mod.boxcox <- lm(shares2 ~ kw_avg_avg + tipo_noticia + self_reference_min_shares + 
                       num_hrefs + kw_max_avg + kw_min_avg + kw_min_min + avg_negative_polarity + 
                       n_tokens_title + average_token_length + global_subjectivity + 
                       kw_min_max + LDA_02 + num_self_hrefs + dia_de_la_semana + 
                       n_tokens_content + self_reference_max_shares + global_rate_positive_words + 
                       min_positive_polarity + num_keywords + abs_title_sentiment_polarity + 
                       abs_title_subjectivity, data=datos)
summary(lin.mod.boxcox) # R2 de 0.125
AIC(lin.mod.boxcox)     # AIC de 14102.11
BIC(lin.mod.boxcox)     # BIC de 14394.09

## Segunda verificación -----------------------------------------------------------------------

# Normalidad (No podemos concluir normalidad, y ahora notamos muchos residuos negativos)
ri <- rstandard(lin.mod.boxcox)
hist(ri, breaks=100, probability = TRUE)
curve(dnorm(x), col="blue", lwd=2, add=TRUE)

qqnorm(ri, pch=19)
qqline(ri, col="red", lty=2)

ks.test(ri, "pnorm")
JarqueBeraTest(ri)

plot(lin.mod.boxcox$fitted.values, datos$shares2)

# Independencia (No podemos concluir independencia)
plot(ri, pch=19, type="b")
dwtest(lin.mod.boxcox, alternative="two.sided")

# Homocedasticidad (No podemos concluir homocedasticidad)
plot(lin.mod$fitted.values, ri)
abline(h=0, col="red", lty=2)
bptest(lin.mod.boxcox)

## Análisis de puntos de influencia --------------------------------------------------------------
# DFFITS
p <- length(lin.mod$coefficients)
n <- length(datos$shares)
cutoff <- 2*sqrt(p/n) 
DFFITS_abs <- abs(dffits(lin.mod))
dffits_altos <- names(which(DFFITS_abs > cutoff)) # 571 en total
length(dffits_altos)

plot(DFFITS_abs, ylab="|DFFITS|", pch=19, col=ifelse(DFFITS_abs > cutoff, "blue", "black"),
     xlab="índice", main="Búsqueda de puntos de influencia sobre su valor ajustado")
abline(h=cutoff, col="red", lwd=2, lty=2)

# Distancia de Cook
Di <- cooks.distance(lin.mod)
plot(Di, pch=19, ylab="Distancia de Cook", ylim=c(0, 1), main="Búsqueda usando distancia de Cook")
abline(h=1, col="red", lty=2, lwd=2) # esperable al ser n muy grande

# COVRATIO
COVRATIO <- covratio(lin.mod)
indices_covratio <- names(which(COVRATIO > 1 + 3*p/n | COVRATIO < 1 - 3*p/n)) # 1575 en total
length(indices_covratio)

xlab <- "índice"
title <- "Búsqueda de puntos de influencia usando COVRATIO"
plot(COVRATIO, pch=19, ylab="COVRATIO", xlab=xlab, main=title, col=ifelse(COVRATIO > 1+3*p/n | COVRATIO < 1-3*p/n, "blue", "black"))
abline(h=1, col="blue", lty=2, lwd=2)
abline(h=1+3*p/n, col="red", lty=2, lwd=2)
abline(h=1-3*p/n, col="red", lty=2, lwd=2)

# Vemos la intersección de ambos conjuntos. Consideramos estas como las más problemáticas y 
# las eliminamos
interseccion <- intersect(dffits_altos, indices_covratio)
length(interseccion) # 464 observaciones en total
indices_influencia <- as.numeric(interseccion)
temp <- datos
datos <- datos[-indices_influencia, ]

# Ajustamos el mismo modelo anterior nuevamente
lin.mod <- lm(formula(lin.mod), data=datos)
summary(lin.mod) # R2 de 0.07687
AIC(lin.mod)     # AIC de 751267.1
BIC(lin.mod)     # BIC de 751558.7

## Tercera verificación --------------------------------------------------------------------------
# Normalidad (Seguimos sin poder concluir normalidad)
ri <- rstandard(lin.mod)
hist(ri, breaks=100, probability = TRUE)
curve(dnorm(x), add=TRUE)
ks.test(ri, "pnorm")
JarqueBeraTest(ri)

# Independencia (No podemos concluir independencia)
dwtest(lin.mod, alternative="two.sided")

# Homocedasticidad (No podemos concluir homocedasticidad)
bptest(lin.mod)

## Nuevamente Box-cox ---------------------------------------------------------------------------
lambda <- boxcox(lin.mod, optimize=TRUE, objective.name = "Shapiro-Wilk")$lambda # -0.0991971
datos$shares2 <- (datos$shares^lambda -1)/lambda
lin.mod.boxcox <- lm(shares2 ~ kw_avg_avg + tipo_noticia + self_reference_min_shares + 
                       num_hrefs + kw_max_avg + kw_min_avg + kw_min_min + avg_negative_polarity + 
                       n_tokens_title + average_token_length + global_subjectivity + 
                       kw_min_max + LDA_02 + num_self_hrefs + dia_de_la_semana + 
                       n_tokens_content + self_reference_max_shares + global_rate_positive_words + 
                       min_positive_polarity + num_keywords + abs_title_sentiment_polarity + 
                       abs_title_subjectivity, data=datos)
summary(lin.mod.boxcox) # R2 de 0.1333
AIC(lin.mod.boxcox)     # AIC de 34615.55
BIC(lin.mod.boxcox)     # BIC de 34907.13

## Cuarta verificación -----------------------------------------------------------------------
# Normalidad (No podemos concluir normalidad, y ahora notamos muchos residuos negativos)
ri <- rstandard(lin.mod.boxcox)
hist(ri, probability = TRUE, breaks = 100)
curve(dnorm(x), add=TRUE, col="blue", lwd=2)
ks.test(ri, "pnorm")
JarqueBeraTest(ri)
plot(lin.mod.boxcox$fitted.values, datos$shares2)

# Independencia (No podemos concluir independencia)
plot(ri, pch=19, type="b")
dwtest(lin.mod.boxcox, alternative="two.sided")

# Homocedasticidad (No podemos concluir homocedasticidad)
plot(lin.mod$fitted.values, ri, ylim=c(-10, 75))
abline(h=0, col="red", lty=2)
bptest(lin.mod.boxcox)

# 5) LASSO Regression --------------------------------------------------------------------------
# Lasso: Least Absolute Shrinkage and Selection Operator
# u operador de selección y contracción mínima absoluta

# lasso usa regularización L1, añadiendo una penalización equivalente a la magnitud 
# absoluta de los coeficientes de la regresioń.

# lasso contrae los estimadores hacia cero, por lo que es utilizada normalmente para 
# bases de datos con muchas variables

# lasso tiene el efecto de hacer que los coeficientes sean exactamente cero para lambda
# suficientemente grande, por lo que de cierta manera también sirve para selección de variables

# Usamos validación cruzada para determinar el valor de lambda óptimo

# Podemos escribir el problema de minimización como uno de minimización sujeta a una restricción

datos_lasso <- read_csv(here::here("datos", "procesados", "2020-11-18_ONP-eduardo.csv"))
datos_lasso$dia_de_la_semana <- factor(datos_lasso$dia_de_la_semana, 
                                 levels=c("Lunes", "Martes", "Miércoles", "Jueves",
                                          "Viernes", "Sábado", "Domingo"),
                                 labels=c("Lunes", "Martes", "Miércoles", "Jueves",
                                          "Viernes", "Sábado", "Domingo"))
datos_lasso$tipo_noticia <- factor(datos_lasso$tipo_noticia,
                             levels=c("Entretenimiento", "Negocios", "Tecnología",
                                      "Mundo", "Estilo de vida", "Otro",
                                      "Redes sociales"),
                             labels=c("Entretenimiento", "Negocios", "Tecnología",
                                      "Mundo", "Estilo de vida", "Otro",
                                      "Redes sociales"))
datos_lasso <- select(datos_lasso, !is_weekend)
datos_lasso <- relocate(datos_lasso, shares, .after = last_col())

# drop <- c("LDA_03", "n_unique_tokens", "n_non_stop_words",
#          "self_reference_avg_sharess", "rate_positive_words", "kw_max_min")
# datos_lasso <- select(datos_lasso, !drop)

# Primera forma, sin test y train
x_vars <- model.matrix(shares~., data = datos_lasso)[,-1]
y_var <- datos_lasso$shares
lambda_seq <- 10^seq(4, -2, length=100)
lafit <- glmnet(x_vars, y_var, alpha=1, lambda=lambda_seq)
plot(lafit, xvar="lambda", label=TRUE)

cv.rrfit <- cv.glmnet(x_vars, y_var, alpha=1, lambda=lambda_seq)
plot(cv.rrfit)

rr.bes.lam <- cv.rrfit$lambda.min

rr.best <- glmnet(x_vars, y_var, alpha=1, lambda = rr.bes.lam)
coef(rr.best)

fit <- glmnet(x, y, family = "multinomial") 
tLL <- fit$nulldev - deviance(fit) 
k <- rr.best$df
n <- rr.best$nobs 
AICc <- -tLL+2*k+2*k*(k+1)/(n-k-1) 
AICc 
BIC<-log(n)*k - tLL 
BIC

pred <- predict(rr.best, s=rr.bes.lam, newx = x_vars)
actual <- datos_lasso$shares
rss <- sum((pred-actual)^2)
tss <- sum((actual - mean(actual))^2)
(r2 <- 1 - rss/tss)
n <- length(datos_lasso$shares)
k <- 33
(r2.adj <- 1 - (n-1)/(n-k-1)*(1-r2))

formula <- shares ~ n_tokens_title + n_tokens_content + avg_positive_polarity + num_hrefs + 
  num_self_hrefs + min_positive_polarity + num_imgs + num_videos + avg_negative_polarity +
  average_token_length + num_keywords + max_negative_polarity + kw_min_min + kw_max_min + 
  title_sentiment_polarity + kw_min_max + kw_max_max + abs_title_subjectivity + kw_min_avg + 
  kw_max_avg + abs_title_sentiment_polarity + kw_avg_avg + self_reference_min_shares + dia_de_la_semana +
  self_reference_max_shares + LDA_00 + tipo_noticia + LDA_01 + LDA_02 + global_subjectivity +
  global_rate_positive_words
  
lasso.mod <- lm(formula, data=datos_lasso)
summary(lasso.mod)

# Segunda forma, con test y train
x_vars <- model.matrix(shares~., data=datos_lasso)[, -1]
y_var <- datos_lasso$shares
lambda_seq <- 10^seq(4, -2, length=100)

train = sample(1:nrow(x_vars), nrow(x_vars)*0.9)
x_test = (-train)
y_test = y_var[x_test]

# Quizás sea buena idea 
cv_output <- cv.glmnet(x_vars[train,], y_var[train],
                       alpha = 1, lambda = lambda_seq, 
                       nfolds = 5)
plot(cv_output)

# identifying best lamda
best_lam <- cv_output$lambda.min
best_lam

# Rebuilding the model with best lamda value identified
lasso_best <- glmnet(x_vars[train,], y_var[train], alpha = 1, lambda = best_lam)
coef(lasso_best)
pred <- predict(lasso_best, s = best_lam, newx = x_vars[x_test,])

# R2 -> 0.01417121
actual <- y_test
preds <- pred
rss <- sum((preds - actual) ^ 2)
tss <- sum((actual - mean(actual)) ^ 2)
rsq <- 1 - rss/tss
rsq
