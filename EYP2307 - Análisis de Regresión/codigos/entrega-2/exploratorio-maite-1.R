require(caret)
require(rio)
require(tidyverse)
require(glmnet)
OnlineNewsPopularity <- import("Datos/OnlineNewsPopularity.csv")
OnlineNewsPopularity$url = NULL


# limpiar la base quitando variables que no me aportan ----------

# Elimino variables sin varianza

Variables_var0 = nearZeroVar(OnlineNewsPopularity)
OnlineNewsPopularity = OnlineNewsPopularity[,-Variables_var0]

# elimino variables con poca correlación con la variable respuesta

correlacion = cor(OnlineNewsPopularity)[,59]
correlacion  
correlacion = which(abs(correlacion)<0.01)  
OnlineNewsPopularity = OnlineNewsPopularity[,-correlacion]  

# elimino variables que estan muy correlacionadas (y me puedan 
# traer problemas de multicolinealidad)

variables = names(OnlineNewsPopularity)
cantvariables = length(variables)
tol = 0.8
cor_alta = c()
for( i in 1:(cantvariables-1)){
  if(i != cantvariables-1){
    for(j in (i+1):(cantvariables-1)){
      correlacion = cor(OnlineNewsPopularity[,i], OnlineNewsPopularity[,j])
      if(abs(correlacion) > tol){
        cor_alta = c(cor_alta,j)
      }
    }
  }
}
cor_alta = sort(cor_alta[!duplicated(cor_alta)])

variables_cor_alta = c()
for(i in 1:(length(cor_alta))){
  variables_cor_alta = c(variables_cor_alta, variables[cor_alta[i]])
}

for(i in 1:(length(variables_cor_alta))){
  a = paste("OnlineNewsPopularity$",variables_cor_alta[i],"=NULL",sep = "")
  eval(parse( text=a ))
}

# eliminamos los datos duplicados

OnlineNewsPopularity = OnlineNewsPopularity[!duplicated(OnlineNewsPopularity),]  

# no hay datos duplicados.

write.csv(OnlineNewsPopularity,file = "Datos/ONP_limpia.csv" )


# Creamos modelos -----------------------------------------------

# modelo backward 

modelo_completo = lm(shares~.,data = OnlineNewsPopularity)
backward = step(modelo_completo,direction = "backward",trace = 0)

#AIC

(bw_mod_aic <- backward$anova$AIC %>% min())

# modelo forward

modelo_nulo = lm(shares~1,data = OnlineNewsPopularity)
forward = step(modelo_completo,direction = "forward",
               scope = formula(modelo_completo),trace = 0)  

#AIC
(fw_mod_aic <- forward$anova$AIC %>% min())
# modelo stepwise

stepwise = step(modelo_completo,direction = "both",trace = 0)

(stepwise_mod_aic <- stepwise$anova$AIC %>% min())

# modelo add1

auto_add1 <- function(data_frame, v_respuesta, v_explicativas, alpha) {
  formula <- as.formula(paste(v_respuesta, "1", sep = " ~ "))
  scope <- as.formula(
    paste("~ ", paste(v_explicativas, collapse = "+"), sep = ""))
  null_lin_mod <- lm(formula = formula, data = data_frame)
  detencion <- FALSE
  variables <- c()
  
  while(detencion == FALSE) {
    
    add_1 <- add1(null_lin_mod, scope = scope, test = "Chisq")
    minimo <- add_1$`Pr(>Chi)`[!is.na(add_1$`Pr(>Chi)`)] %>% min()
    indice <- which(add_1$`Pr(>Chi)`== minimo) - 1
    
    if(minimo <= alpha) {
      variables <- c(variables, v_explicativas[indice])
      v_explicativas <- v_explicativas[-indice]
      actualizacion <- as.formula(
        paste("~ ", paste(variables, collapse = "+"), sep = ""))
      null_lin_mod <- update(null_lin_mod, actualizacion)
      
    } else {
      detencion <- TRUE
    }
  }
  
  return(list(modelo = null_lin_mod, aic = min(add_1$AIC)))
}

v_explicativas <- names(OnlineNewsPopularity)[-31]
v_respuesta <- "shares"
alpha <- 0.05

(modelo_add1 <- auto_add1(OnlineNewsPopularity, v_respuesta, v_explicativas, alpha)$modelo)

#AIC

auto_add1(OnlineNewsPopularity, v_respuesta, v_explicativas, alpha)$aic

#tiene un AIC gigante


# vemos el R cuadrado

summary(modelo_add1)$r.squared

# Es muy chiquito

# modelo con drop1

auto_drop1 <- function(data_frame, v_respuesta, v_explicativas, alpha) {
  formula <- as.formula(
    paste(v_respuesta, paste(v_explicativas, collapse = "+"),
          sep = " ~ "))
  
  full_lin_mod <- lm(formula = formula, data = data_frame)
  detencion <- FALSE
  
  while(detencion == FALSE) {
    
    drop_1 <- drop1(full_lin_mod, test = "Chisq")
    maximo <- drop_1$`Pr(>Chi)`[!is.na(drop_1$`Pr(>Chi)`)] %>% max()
    indice <- which(drop_1$`Pr(>Chi)`== maximo) - 1
    
    if(maximo >= alpha) {
      
      v_explicativas <- v_explicativas[-indice]
      actualizacion <- as.formula(
        paste("~ ", paste(v_explicativas, collapse = "+"), sep = ""))
      full_lin_mod <- update(full_lin_mod, actualizacion)
      
    } else {
      detencion <- TRUE
    }
  }
  
  return(list(modelo = full_lin_mod, aic = min(drop_1$AIC)))
}

(modelo_drop1 <- auto_drop1(OnlineNewsPopularity, v_respuesta, 
                            v_explicativas, alpha)$modelo)

#AIC
auto_drop1(OnlineNewsPopularity, v_respuesta, v_explicativas, alpha)$aic

#tiene un AIC gigante

summary(modelo_drop1)$r.squared

# Modelo LASSO regression
#hace 0 las variables que tienen mucha varianza(que hacen
#que el modelo varíe harto), y aumenta el error cuadratico a
#costa de tener un mejor modelo, todo depende del lambda(que 
#controla la inclinación de la recta)
#hacemos validacion cruzada para elegir el mejor lambda

# creamos datos de entrenamiento y datos de prueba
x_vars = model.matrix(shares~.,data = OnlineNewsPopularity)[,-1]
y_var = OnlineNewsPopularity$shares
lambda_seq = 10^seq(2,-2,-0.1)
set.seed(70)
train = sample(1:nrow(OnlineNewsPopularity),0.5*nrow(OnlineNewsPopularity))
x_test = (-train)
y_test = y_var[x_test]
cv_output <- cv.glmnet(x_vars[train,], y_var[train],
                       alpha = 1, lambda = lambda_seq, 
                       nfolds = 10)

#ahora buscamos el mejor lambda
best_lambda = cv_output$lambda.min
best_lambda

#el mejor lambda es 100 

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











