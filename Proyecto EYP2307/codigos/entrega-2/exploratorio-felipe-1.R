library(here)
library(ggplot2)
library(Johnson)
library(glmnet)
library(here)
library(readr)
library(tidyverse)
library(car)
library(lmtest)
library(EnvStats)

# Carga de datos
datos = read_csv(here::here("datos", "procesados", "2020-11-18_ONP-eduardo.csv"))

# Definición de las variables categóricas
datos$dia_de_la_semana = factor(datos$dia_de_la_semana, 
                                 levels=c("Lunes", "Martes", "Miércoles", "Jueves",
                                          "Viernes", "Sábado", "Domingo"),
                                 labels=c("Lunes", "Martes", "Miércoles", "Jueves",
                                          "Viernes", "Sábado", "Domingo"))
datos$tipo_noticia = factor(datos$tipo_noticia,
                             levels=c("Entretenimiento", "Negocios", "Tecnología",
                                      "Mundo", "Estilo de vida", "Otro",
                                      "Redes sociales"),
                             labels=c("Entretenimiento", "Negocios", "Tecnología",
                                      "Mundo", "Estilo de vida", "Otro",
                                      "Redes sociales"))
# Variables quitadas con el VIF
drop = c("LDA_03", "n_unique_tokens", "n_non_stop_words",
          "self_reference_avg_sharess", "rate_positive_words",
          "kw_max_min")
# Le quitamos las variables que tengan VIF mayor a 10
datos = select(datos, !drop)
# Quitamos día de la semana
datos = select(datos, !dia_de_la_semana)
# Hacemos el modelo backward sin intercepto pq es el que dió menor AIC
lin.mod.backward.si = step(lm(shares~.-1, data=datos), direction="backward", trace=0)
lin.mod = lin.mod.backward.si

# Independencia
r_i = rstandard(lin.mod)
ggplot(data = lin.mod, aes(x = seq_along(r_i), y = r_i)) +
  geom_point(aes(color = r_i)) +
  labs(title = "Distribución de los residuos", x = "Número de residuo",
       y = "Residuo Estandarizado") +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

dwtest(lin.mod, alternative = "two.sided") # Son independientes

# Homocedasticidad
v_ajustados = lin.mod$fitted.values
ggplot(data = lin.mod, aes(x = v_ajustados, y = r_i)) +
  geom_point(aes(color = r_i)) +
  geom_smooth(color = "firebrick", se = FALSE, formula = y ~ x, method = "loess") +
  labs(title = "Distribución de los residuos", x = "Valores ajustados",
       y = "Residuo Estandarizado") +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

bptest(lin.mod) # No hay homocedasticidad

# Normalidad
ggplot(data = lin.mod) +
  stat_qq(mapping = aes(sample = r_i), size = 1, color = "dodgerblue1") +
  stat_qq_line(mapping = aes(sample = r_i), color = "chocolate2") +
  labs(x = "Cuantiles teóricos", y = "Residuos Estandarizados",
       title = "Q-Q Plot Normal") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = )

ks.test(r_i, "pnorm", mean(r_i), sd(r_i)) # No son normales

# Hacemos boxcox
(lambda = boxcox(lin.mod, optimize = TRUE)$lambda)
# Graficamos el lambda que maximiza
plot(boxcox(datos$shares, lambda = seq(-3, 3, len = 1000), objective.name = "PPCC"))
abline(v = lambda, col = "blue", lty = 2)
if (lambda == 0){
  datos$shares2= log(datos$shares)
} else {
  datos$shares2 = ((datos$shares ^ lambda) - 1 ) / lambda
}
# Veamos el modelo con variable respuesta shares2
datos2 = datos
datos2$shares = NULL
lin.mod2 = lm(shares2 ~ ., data = datos2) # R^2 de 0.1289
summary(lin.mod2)

# Independencia
r_i = rstandard(lin.mod2)
ggplot(data = lin.mod2, aes(x = seq_along(r_i), y = r_i)) +
  geom_point(aes(color = r_i)) +
  labs(title = "Distribución de los residuos", x = "Número de residuo",
       y = "Residuo Estandarizado") +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

dwtest(lin.mod2, alternative = "two.sided") # No son independientes

# Homocedasticidad
v_ajustados = lin.mod2$fitted.values
ggplot(data = lin.mod2, aes(x = v_ajustados, y = r_i)) +
  geom_point(aes(color = r_i)) +
  geom_smooth(color = "firebrick", se = FALSE, formula = y ~ x, method = "loess") +
  labs(title = "Distribución de los residuos", x = "Valores ajustados",
       y = "Residuo Estandarizado") +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

bptest(lin.mod2) # No hay homocedasticidad

# normalidad
ggplot(data = datos) +
  stat_qq(mapping = aes(sample = shares2), size = 1, color = "dodgerblue1") +
  stat_qq_line(mapping = aes(sample = shares2), color = "chocolate2") +
  labs(x = "Cuantiles teóricos", y = "shares2 (variable respuesta transformada)",
       title = "Q-Q Plot Normal") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = )

ks.test(datos$shares2, "pnorm", mean(datos$shares2), sd(datos$shares2))

# Transformamos johnson
johnson = RE.Johnson(datos$shares2)
ggplot(data = datos) +
  stat_qq(mapping = aes(sample = johnson$transformed), size = 1, color = "dodgerblue1") +
  stat_qq_line(mapping = aes(sample = johnson$transformed), color = "chocolate2") +
  labs(x = "Cuantiles teóricos", y = "V. respuesta transformada con Johnson",
       title = "Q-Q Plot Normal") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = )

ks.test(johnson$transformed, "pnorm", mean(johnson$transformed), sd(johnson$transformed))


# LASSO (con backward model sin intercepto)
datos = select(datos, !"shares2")
lin.mod.backward.si <- step(lm(shares~.-1, data=datos), direction="backward", trace=0)
x_vars = model.matrix(shares ~.,data = datos)
y_var = datos$shares
lambda_seq = 10^seq(2,-2,-0.1)
set.seed(70)
train = sample(1:nrow(datos),0.5*nrow(datos))
x_test = (-train)
y_test = y_var[x_test]
cv_output = cv.glmnet(x_vars[train,], y_var[train],
                       alpha = 1, lambda = lambda_seq, 
                       nfolds = 10)

#ahora buscamos el mejor lambda
best_lambda = cv_output$lambda.min
best_lambda

#el mejor lambda es 50.11872

#ahora hago el modelo con ese lambda

lasso_best = glmnet(x_vars[train,],y_var[train],alpha = 1,lambda = best_lambda)

# ahora vemos que tan bueno es el modelo, usandolo con mis datos de prueba.

pred = predict(lasso_best,s=best_lambda,newx = x_vars[x_test,])
final = cbind(y_var[-train],pred)
head(final)

#vemos cuales hace 0
coef(lasso_best)

#calculamos el R^2

actual <- y_var[-train]
preds <- pred
rss <- sum((preds - actual) ^ 2)
tss <- sum((actual - mean(actual)) ^ 2)
rsq <- 1 - rss/tss
rsq 

# Da un r^2 de 0.01634607

# LASSO (con backward model sin intercepto transformado con boxcox)
x_vars = model.matrix(shares2 ~.,data = datos)
y_var = datos$shares2
lambda_seq = 10^seq(2,-2,-0.1)
set.seed(70)
train = sample(1:nrow(datos),0.5*nrow(datos))
x_test = (-train)
y_test = y_var[x_test]
cv_output = cv.glmnet(x_vars[train,], y_var[train],
                      alpha = 1, lambda = lambda_seq, 
                      nfolds = 10)

#ahora buscamos el mejor lambda
best_lambda = cv_output$lambda.min
best_lambda

#el mejor lambda es 0.01258925

#ahora hago el modelo con ese lambda

lasso_best = glmnet(x_vars[train,],y_var[train],alpha = 1,lambda = best_lambda)

# ahora vemos que tan bueno es el modelo, usandolo con mis datos de prueba.

pred = predict(lasso_best,s=best_lambda,newx = x_vars[x_test,])
final = cbind(y_var[-train],pred)
head(final)

#vemos cuales hace 0
coef(lasso_best)

#calculamos el R^2

actual <- y_var[-train]
preds <- pred
rss <- sum((preds - actual) ^ 2)
tss <- sum((actual - mean(actual)) ^ 2)
rsq <- 1 - rss/tss
rsq

# Da un r^2 de 0.2395703

# Supuestos para el modelo antes de boxcox
# Outliers
v_ajustados = lin.mod$fitted.values
r_i = rstandard(lin.mod)
ggplot(data = lin.mod, aes(x = v_ajustados, y = r_i)) +
  geom_point(color = "dodgerblue4") +
  labs(title = "Detección de Outliers", x = "Valores ajustados", y = "Residuos Estandarizados") +
  geom_hline(yintercept = qnorm(0.975), linetype = 2, color = "firebrick", size = 1) +
  geom_hline(yintercept = - qnorm(0.975), linetype = 2, color = "firebrick", size = 1) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

outlierTest(lin.mod)

outliers_mayores_b = sort(r_i[which(r_i >= qnorm(0.975))])
outliers_menores_b = sort(r_i[which(r_i <= - qnorm(0.975))])
# Total de posibles outliers: 498
length(outliers_mayores_b) + length(outliers_menores_b)

# Puntos extremos
h_ii = hatvalues(lin.mod)
p = 41
n = nrow(datos)
linea_1 = 2 * (p + 1) / n
linea_2 = 2 * p/n
ggplot(data = lin.mod, aes(x = h_ii, y = r_i)) +
  geom_point(color = "dodgerblue4") +
  labs(title = "Detección de Puntos extremos", x = "h_ii", y = "Residuos Estandarizados") +
  geom_vline(xintercept = linea_1, linetype = 2, color = "forestgreen", size = 1) +
  geom_vline(xintercept = linea_2, linetype = 2, color = "firebrick", size = 1) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")
extremos_linea_1_b = sort(h_ii[which(h_ii > 2 * (p + 1) / n)])
extremos_linea_2_b = sort(h_ii[which(h_ii > 2 * (p) / n)])
# Total de puntos extremos linea 1 y 2:  735 y 773
length(extremos_linea_1_b)
length(extremos_linea_2_b)

# Puntos de influencia

# DFFITS
DFFITS = dffits(lin.mod)
ggplot(data = lin.mod, aes(x = seq_along(r_i), y = abs(DFFITS))) +
  geom_point(color = "dodgerblue4") +
  geom_hline(yintercept = 2 * sqrt(p / n), linetype = 2, color = "firebrick", size = 1) +
  labs(x = "Índice", y = "|DFFITS|",
       title = "Criterio DFFITS") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")
dffits_pi = sort(abs(DFFITS)[which(abs(DFFITS) > 2 * sqrt(p / n))])
# Cantidad de puntos de influencia según el criterio dffits: 437
length(dffits_pi)

# Distancia de cook
distancia_cook = cooks.distance(lin.mod)
ggplot(data = lin.mod, aes(x = seq_along(r_i), y = distancia_cook)) +
  geom_point(color = "dodgerblue4") +
  geom_hline(yintercept = 1, linetype = 2, color = "firebrick", size = 1) +
  labs(x = "Índice", y = "Distancia de Cook",
       title = "Criterio Distancia de Cook") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")
# Cantidad de puntos de influencia según el criterio cook: 0
cook_pi = sort(distancia_cook[which(distancia_cook > 1)])
length(cook_pi)

# COVRATIO 
COVRATIO = covratio(lin.mod)
ggplot(data = lin.mod, aes(x = seq_along(r_i), y = COVRATIO)) +
  geom_point(color = "dodgerblue4") +
  geom_hline(yintercept = 1 + 3 * p / n, linetype = 2, color = "forestgreen", size = 1) +
  geom_hline(yintercept = 1 - 3 * p / n, linetype = 2, color = "firebrick", size = 1) +
  labs(x = "Índice", y = "COVRATIO",
       title = "Criterio COVRATIO") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")
covratio_pi_sobre_b = sort(COVRATIO[which(COVRATIO > 1 + 3 * p / n)])
covratio_pi_bajo_b = sort(COVRATIO[which(COVRATIO < 1 - 3 * p / n)])
# Cantidad de puntos de influencia según el criterio covratio: 934
length(covratio_pi_bajo_b) + length(covratio_pi_sobre_b)


# Supuestos para el modelo después de boxcox
# Outliers
v_ajustados = lin.mod2$fitted.values
r_i = rstandard(lin.mod2)
ggplot(data = lin.mod2, aes(x = v_ajustados, y = r_i)) +
  geom_point(color = "dodgerblue4") +
  labs(title = "Detección de Outliers", x = "Valores ajustados", y = "Residuos Estandarizados") +
  geom_hline(yintercept = qnorm(0.975), linetype = 2, color = "firebrick", size = 1) +
  geom_hline(yintercept = - qnorm(0.975), linetype = 2, color = "firebrick", size = 1) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

outlierTest(lin.mod2)

outliers_mayores_b = sort(r_i[which(r_i >= qnorm(0.975))])
outliers_menores_b = sort(r_i[which(r_i <= - qnorm(0.975))])
# Total de posibles outliers: 2133
length(outliers_mayores_b) + length(outliers_menores_b)

# Puntos extremos
h_ii = hatvalues(lin.mod2)
p = 41
n = nrow(datos)
linea_1 = 2 * (p + 1) / n
linea_2 = 2 * p/n
ggplot(data = lin.mod2, aes(x = h_ii, y = r_i)) +
  geom_point(color = "dodgerblue4") +
  labs(title = "Detección de Puntos extremos", x = "h_ii", y = "Residuos Estandarizados") +
  geom_vline(xintercept = linea_1, linetype = 2, color = "forestgreen", size = 1) +
  geom_vline(xintercept = linea_2, linetype = 2, color = "firebrick", size = 1) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")
extremos_linea_1_b = sort(h_ii[which(h_ii > 2 * (p + 1) / n)])
extremos_linea_2_b = sort(h_ii[which(h_ii > 2 * (p) / n)])
# Total de puntos extremos linea 1 y 2:  2109 y 2237
length(extremos_linea_1_b)
length(extremos_linea_2_b)

# Puntos de influencia

# DFFITS
DFFITS = dffits(lin.mod2)
ggplot(data = lin.mod2, aes(x = seq_along(r_i), y = abs(DFFITS))) +
  geom_point(color = "dodgerblue4") +
  geom_hline(yintercept = 2 * sqrt(p / n), linetype = 2, color = "firebrick", size = 1) +
  labs(x = "Índice", y = "|DFFITS|",
       title = "Criterio DFFITS") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")
dffits_pi = sort(abs(DFFITS)[which(abs(DFFITS) > 2 * sqrt(p / n))])
# Cantidad de puntos de influencia según el criterio dffits: 2426
length(dffits_pi)

# Distancia de cook
distancia_cook = cooks.distance(lin.mod2)
ggplot(data = lin.mod2, aes(x = seq_along(r_i), y = distancia_cook)) +
  geom_point(color = "dodgerblue4") +
  geom_hline(yintercept = 1, linetype = 2, color = "firebrick", size = 1) +
  labs(x = "Índice", y = "Distancia de Cook",
       title = "Criterio Distancia de Cook") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")
# Cantidad de puntos de influencia según el criterio cook: 1
cook_pi = sort(distancia_cook[which(distancia_cook > 1)])
length(cook_pi)

# COVRATIO 
COVRATIO = covratio(lin.mod2)
ggplot(data = lin.mod2, aes(x = seq_along(r_i), y = COVRATIO)) +
  geom_point(color = "dodgerblue4") +
  geom_hline(yintercept = 1 + 3 * p / n, linetype = 2, color = "firebrick", size = 1) +
  geom_hline(yintercept = 1 - 3 * p / n, linetype = 2, color = "firebrick", size = 1) +
  labs(x = "Índice", y = "COVRATIO",
       title = "Criterio COVRATIO") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")
covratio_pi_sobre_b = sort(COVRATIO[which(COVRATIO > 1 + 3 * p / n)])
covratio_pi_bajo_b = sort(COVRATIO[which(COVRATIO < 1 - 3 * p / n)])
# Cantidad de puntos de influencia según el criterio covratio: 2940
length(covratio_pi_bajo_b) + length(covratio_pi_sobre_b)





