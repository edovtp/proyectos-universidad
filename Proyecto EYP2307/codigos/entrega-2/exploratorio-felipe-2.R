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
summary(lin.mod.forward) # R2 de 0.02253
AIC(lin.mod.forward)     # AIC de 853889.9
BIC(lin.mod.forward)     # BIC de 854181.9

# 5.- Backward
lin.mod.backward <- step(lm(shares~., data=datos), direction="backward", trace=0)
summary(lin.mod.backward) # R2 de 0.02253
AIC(lin.mod.backward)     # AIC de 853889.9
BIC(lin.mod.backward)     # BIC de 854181.9

# 6.- Stepwise
lin.mod.stepwise <- step(lm(shares~., data=datos), direction="both", trace=0)
summary(lin.mod.stepwise) # R2 de 0.02253
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

# Histograma
ggplot(data = datos) +
  theme_bw() +
  labs(title = "Histograma de Residuos Estandarizados", x = "Residuos Estandarizados", y = "Densidad") +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none") +
  geom_histogram(aes(x = ri, y = ..density..), color = "red", fill = "orange",
                 binwidth = 2, alpha = 0.2) +
  stat_function(aes(x = 0), size = 1, color = "#C1549C",
                fun = dnorm, args = list(mean = mean(ri), sd = sd(ri)))

ggsave(here::here("productos/presentacion-2/Presentacion_files/primera-version", 
                  "histograma.png"), width = 6, height = 3.5, dpi = 300)

# qqnorm
ggplot(data = lin.mod) +
  stat_qq(mapping = aes(sample = ri), size = 1, color = "#FB836F") +
  stat_qq_line(mapping = aes(sample = ri), color = "#7E549F") +
  labs(x = "Cuantiles teóricos", y = "Residuos Estandarizados",
       title = "Q-Q Plot Normal") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = )

ggsave(here::here("productos/presentacion-2/Presentacion_files/primera-version", 
                  "qqnorm.png"), width = 6, height = 3.5, dpi = 300)

# Test
ks.test(ri, "pnorm") # Se rechaza la hipótesis nula: valor-p = 2.2e-16

# No distribuyen normal

# Gráfico valores ajustados y residuos
v_ajustados = lin.mod$fitted.values
ggplot(data = lin.mod, aes(x = v_ajustados, y = ri)) +
  geom_point(color = "#C1548C") +
  labs(title = "Distribución de los residuos", x = "Valores ajustados",
       y = "Residuo Estandarizado") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

ggsave(here::here("productos/presentacion-2/Presentacion_files/primera-version", 
                  "ajustados-residuos.png"), width = 12, height = 6, dpi = 300)


# Independencia (Sí podemos concluir)
ggplot(data = lin.mod, aes(x = seq_along(ri), y = ri)) +
  geom_point(color = "#FB836F") +
  labs(title = "Distribución de los residuos", x = "Número de residuo",
       y = "Residuo Estandarizado") +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

ggsave(here::here("productos/presentacion-2/Presentacion_files/primera-version", 
                  "independencia.png"), width = 12, height = 6, dpi = 300)

# Test
dwtest(lin.mod, alternative="two.sided") # No se rechaza: valor-p = 0.6957

# Son independientes

# Homocedasticidad (No podemos concluir)
ggplot(data = lin.mod, aes(x = v_ajustados, y = ri)) +
  geom_point(color = "#FB836F") +
  geom_smooth(color = "#40CEE3", se = FALSE, formula = y ~ x, method = "loess") +
  labs(title = "Distribución de los residuos", x = "Valores ajustados",
       y = "Residuo Estandarizado") +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

ggsave(here::here("productos/presentacion-2/Presentacion_files/primera-version", 
                  "homocedasticidad.png"), width = 12, height = 6, dpi = 300)

# Test
bptest(lin.mod) # Se rechaza la H0: valor-p = 1.39e-05

## Transformación de Box-Cox primero (siempre es mejor mantener todos los datos) -----------------
ggplot(data = lin.mod, aes(x = v_ajustados, y = ri)) +
  geom_point(aes(color = ri)) +
  labs(title = "Distribución de los residuos", x = "Valores ajustados",
       y = "Residuo Estandarizado") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")
lambda = boxcox(lin.mod, optimize=TRUE, objective.name = "Shapiro-Wilk")$lambda

# Gráfico lambda que maximiza
plot(boxcox(lin.mod, lambda = seq(-3, 3, len = 1000), objective.name = "Shapiro-Wilk"), 
     xlab = expression(lambda), ylab = "Shapiro-Wilk", 
     main = "Lambda óptimo para la transformación de Box-cox") 
abline(v = lambda, col = "red", lty = 2, lwd = 2)

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

## Segunda verificación -----------------------------------------------------------------------

# Normalidad (No podemos concluir normalidad, y ahora notamos muchos residuos negativos)
ri <- rstandard(lin.mod.boxcox)

# Histograma
ggplot(data = datos) +
  theme_bw() +
  labs(title = "Histograma de Residuos Estandarizados", x = "Residuos Estandarizados", y = "Densidad") +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none") +
  geom_histogram(aes(x = ri, y = ..density..), color = "red", fill = "orange",
                 binwidth = 1, alpha = 0.2) +
  stat_function(aes(x = 0), size = 1, color = "#C1549C",
                fun = dnorm, args = list(mean = mean(ri), sd = sd(ri)))

ggsave(here::here("productos/presentacion-2/Presentacion_files/segunda-version", 
                  "histograma.png"), width = 12, height = 6, dpi = 300)

# qqnorm
ggplot(data = lin.mod.boxcox) +
  stat_qq(mapping = aes(sample = ri), size = 1, color = "#FB836F") +
  stat_qq_line(mapping = aes(sample = ri), color = "#7E549F") +
  labs(x = "Cuantiles teóricos", y = "Residuos Estandarizados",
       title = "Q-Q Plot Normal") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = )

ggsave(here::here("productos/presentacion-2/Presentacion_files/segunda-version", 
                  "qqnorm.png"), width = 12, height = 6, dpi = 300)

# Test
ks.test(ri, "pnorm") # Se rechaza la hipótesis nula: valor-p = 2.2e-16

# No distribuyen normal

# Gráfico valores ajustados y residuos
v_ajustados = lin.mod.boxcox$fitted.values
ggplot(data = lin.mod.boxcox, aes(x = v_ajustados, y = ri)) +
  geom_point(color = "#C1548C") +
  labs(title = "Distribución de los residuos", x = "Valores ajustados",
       y = "Residuo Estandarizado") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

ggsave(here::here("productos/presentacion-2/Presentacion_files/segunda-version", 
                  "ajustados-residuos.png"), width = 12, height = 6, dpi = 300)

# Independencia (No podemos concluir independencia)
ggplot(data = lin.mod.boxcox, aes(x = seq_along(ri), y = ri)) +
  geom_point(color = "#FB836F") +
  labs(title = "Distribución de los residuos", x = "Número de residuo",
       y = "Residuo Estandarizado") +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

ggsave(here::here("productos/presentacion-2/Presentacion_files/segunda-version", 
                  "independencia.png"), width = 12, height = 6, dpi = 300)

# Test
dwtest(lin.mod.boxcox, alternative="two.sided") # Se rechaza H0: valor-p = 6.074e-09

# No son independientes

# Homocedasticidad (No podemos concluir homocedasticidad)
ggplot(data = lin.mod.boxcox, aes(x = v_ajustados, y = ri)) +
  geom_point(color = "#FB836F") +
  geom_smooth(color = "#40CEE3", se = FALSE, formula = y ~ x, method = "loess") +
  labs(title = "Distribución de los residuos", x = "Valores ajustados",
       y = "Residuo Estandarizado") +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

ggsave(here::here("productos/presentacion-2/Presentacion_files/segunda-version", 
                  "homocedasticidad.png"), width = 12, height = 6, dpi = 300)

# Test
bptest(lin.mod.boxcox) # Se rechaza H0: valor-p = 2.2e-16

## Análisis de puntos de influencia --------------------------------------------------------------
# DFFITS
p <- length(lin.mod$coefficients)
n <- length(datos$shares)
cutoff <- 2*sqrt(p/n) 
DFFITS_abs <- abs(dffits(lin.mod))
dffits_altos <- names(which(DFFITS_abs > cutoff)) # 571 en total
ggplot(data = lin.mod, aes(x = seq_along(ri), y = DFFITS_abs)) +
  geom_point(color = "#FB836F") +
  geom_hline(yintercept = 2 * sqrt(p / n), linetype = 2, color = "#7E549F", size = 1) +
  labs(x = "Índice", y = "|DFFITS|",
       title = "Criterio DFFITS") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

ggsave(here::here("productos/presentacion-2/Presentacion_files/puntos-de-influencia", 
                  "DFFITS.png"), width = 6, height = 3.5, dpi = 300)

# Distancia de Cook
Di <- cooks.distance(lin.mod)
ggplot(data = lin.mod, aes(x = seq_along(ri), y = Di)) +
  geom_point(color = "#FB836F") +
  geom_hline(yintercept = 1, linetype = 2, color = "#7E549F", size = 1) +
  labs(x = "Índice", y = "Distancia de Cook",
       title = "Criterio Distancia de Cook") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")
# esperable al ser n muy grande

ggsave(here::here("productos/presentacion-2/Presentacion_files/puntos-de-influencia", 
                  "distancia-cook.png"), width = 6, height = 3.5, dpi = 300)

# COVRATIO
COVRATIO <- covratio(lin.mod)
indices_covratio <- names(which(COVRATIO > 1 + 3*p/n | COVRATIO < 1 - 3*p/n)) # 1575 en total
ggplot(data = lin.mod, aes(x = seq_along(ri), y = COVRATIO)) +
  geom_point(color = "#FB836F") +
  geom_hline(yintercept = 1 + 3 * p / n, linetype = 2, color = "#7E549F", size = 1) +
  geom_hline(yintercept = 1 - 3 * p / n, linetype = 2, color = "#C1549C", size = 1) +
  labs(x = "Índice", y = "COVRATIO",
       title = "Criterio COVRATIO") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

ggsave(here::here("productos/presentacion-2/Presentacion_files/puntos-de-influencia", 
                  "COVRATIO.png"), width = 6, height = 3.5, dpi = 300)


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
ggplot(data = datos) +
  theme_bw() +
  labs(title = "Histograma de Residuos Estandarizados", x = "Residuos Estandarizados", y = "Densidad") +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none") +
  geom_histogram(aes(x = ri, y = ..density..), color = "red", fill = "orange",
                 binwidth = 1, alpha = 0.2) +
  stat_function(aes(x = 0), size = 1, color = "#7E549F",
                fun = dnorm, args = list(mean = mean(ri), sd = sd(ri)))

ggsave(here::here("productos/presentacion-2/Presentacion_files/tercera-version", 
                  "histograma.png"), width = 12, height = 6, dpi = 300)

# qqnorm
ggplot(data = lin.mod) +
  stat_qq(mapping = aes(sample = ri), size = 1, color = "#FB836F") +
  stat_qq_line(mapping = aes(sample = ri), color = "#7E549F") +
  labs(x = "Cuantiles teóricos", y = "Residuos Estandarizados",
       title = "Q-Q Plot Normal") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = )

ggsave(here::here("productos/presentacion-2/Presentacion_files/tercera-version", 
                  "qqnorm.png"), width = 12, height = 6, dpi = 300)

# Test
ks.test(ri, "pnorm") # Se rechaza H0: valor-p = 2.2e-16

# Gráfico valores ajustados y residuos
v_ajustados = lin.mod$fitted.values
ggplot(data = lin.mod, aes(x = v_ajustados, y = ri)) +
  geom_point(color = "#C1549C") +
  labs(title = "Distribución de los residuos", x = "Valores ajustados",
       y = "Residuo Estandarizado") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

ggsave(here::here("productos/presentacion-2/Presentacion_files/tercera-version", 
                  "ajustados-residuos.png"), width = 12, height = 6, dpi = 300)


# Independencia (No podemos concluir independencia)
ggplot(data = lin.mod, aes(x = seq_along(ri), y = ri)) +
  geom_point(color = "#FB836F") +
  labs(title = "Distribución de los residuos", x = "Número de residuo",
       y = "Residuo Estandarizado") +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

ggsave(here::here("productos/presentacion-2/Presentacion_files/tercera-version", 
                  "independencia.png"), width = 12, height = 6, dpi = 300)

# Test
dwtest(lin.mod, alternative="two.sided") # Se rechaza H0: valor-p = 0.001611

# Homocedasticidad (No podemos concluir homocedasticidad)
v_ajustados = lin.mod$fitted.values
ggplot(data = lin.mod, aes(x = v_ajustados, y = ri)) +
  geom_point(color = "#FB836F") +
  geom_smooth(color = "#40CEE3", se = FALSE, formula = y ~ x, method = "loess") +
  labs(title = "Distribución de los residuos", x = "Valores ajustados",
       y = "Residuo Estandarizado") +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

ggsave(here::here("productos/presentacion-2/Presentacion_files/tercera-version", 
                  "homocedasticidad.png"), width = 12, height = 6, dpi = 300)

# Test
bptest(lin.mod) # Se rechaza H0: valor-p = 2.2e-16

## Nuevamente Box-cox ---------------------------------------------------------------------------
lambda <- boxcox(lin.mod, optimize=TRUE)$lambda # -0.0991971
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

# Histograma
ggplot(data = datos) +
  theme_bw() +
  labs(title = "Histograma de Residuos Estandarizados", x = "Residuos Estandarizados", y = "Densidad") +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none") +
  geom_histogram(aes(x = ri, y = ..density..), color = "red", fill = "orange",
                 binwidth = 1, alpha = 0.2) +
  stat_function(aes(x = 0), size = 1, color = "#7E549F",
                fun = dnorm, args = list(mean = mean(ri), sd = sd(ri)))

ggsave(here::here("productos/presentacion-2/Presentacion_files/cuarta-version", 
                  "histograma.png"), width = 12, height = 6, dpi = 300)

# qqnorm
ggplot(data = lin.mod.boxcox) +
  stat_qq(mapping = aes(sample = ri), size = 1, color = "#FB836F") +
  stat_qq_line(mapping = aes(sample = ri), color = "#7E549F") +
  labs(x = "Cuantiles teóricos", y = "Residuos Estandarizados",
       title = "Q-Q Plot Normal") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = )

ggsave(here::here("productos/presentacion-2/Presentacion_files/cuarta-version", 
                  "qqnorm.png"), width = 12, height = 6, dpi = 300)

# Test
ks.test(ri, "pnorm") # Se rechaza H0: valor-p = 2.2e-16

# Gráfico valores ajustados y residuos
v_ajustados = lin.mod.boxcox$fitted.values
ggplot(data = lin.mod.boxcox, aes(x = v_ajustados, y = ri)) +
  geom_point(color = "#C1549C") +
  labs(title = "Distribución de los residuos", x = "Valores ajustados",
       y = "Residuo Estandarizado") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

ggsave(here::here("productos/presentacion-2/Presentacion_files/cuarta-version", 
                  "ajustados-residuos.png"), width = 12, height = 6, dpi = 300)

# Independencia (No podemos concluir independencia)
ggplot(data = lin.mod.boxcox, aes(x = seq_along(ri), y = ri)) +
  geom_point(color = "#FB836F") +
  labs(title = "Distribución de los residuos", x = "Número de residuo",
       y = "Residuo Estandarizado") +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

ggsave(here::here("productos/presentacion-2/Presentacion_files/cuarta-version", 
                  "independencia.png"), width = 12, height = 6, dpi = 300)

# Test
dwtest(lin.mod.boxcox, alternative="two.sided") # Se rechaza H0: valor-p = 5.764e-12

# Homocedasticidad (No podemos concluir homocedasticidad)
ggplot(data = lin.mod.boxcox, aes(x = v_ajustados, y = ri)) +
  geom_point(color = "#FB836F") +
  geom_smooth(color = "#40CCE3", se = FALSE, formula = y ~ x, method = "loess") +
  labs(title = "Distribución de los residuos", x = "Valores ajustados",
       y = "Residuo Estandarizado") +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

ggsave(here::here("productos/presentacion-2/Presentacion_files/cuarta-version", 
                  "homocedasticidad.png"), width = 12, height = 6, dpi = 300)

# Test
bptest(lin.mod.boxcox) # Se rechaza H0: valor-p = 2.2e-16
