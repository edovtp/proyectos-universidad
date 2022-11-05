library(CARBayes)
library(CARBayesdata)
library(tidyverse)
library(magrittr)
library(GGally)
library(rgdal)
library(leaflet)
library(spdep)
library(coda)
library(feather)


# Modelos
formula <- votos_2017_1 ~ ingreso_medio + porcentaje_pobreza + 
  porcentaje_personas_sin_servicios_basicos + porcentaje_hacinamiento +
  tasa_gasto_salud + tasa_gasto_educacion

## Sin efectos ------------------------------------------------------------------------
### Cadenas
glm_c1 <- S.glm(formula = formula, family = "binomial", data = presidenciales_santiago,
                trials = presidenciales_santiago$inscritos_2017_1, burnin = 20000,
                n.sample = 40000, thin = 100)

glm_c2 <- S.glm(formula = formula, family = "binomial", data = presidenciales_santiago,
                trials = presidenciales_santiago$inscritos_2017_1, burnin = 20000,
                n.sample = 40000, thin = 100)

glm_c3 <- S.glm(formula = formula, family = "binomial", data = presidenciales_santiago,
                trials = presidenciales_santiago$inscritos_2017_1, burnin = 20000,
                n.sample = 40000, thin = 100)

### Summary
glm_c1
glm_c2
glm_c3

summary(glm_c1)
coef(glm_c1)
model.matrix(glm_c1)

glm_c1$summary.results
glm_c1$samples
glm_c1$fitted.values
glm_c1$modelfit

## BYM ------------------------------------------------------------------------
matriz_adyacencia <- nb2mat(vecinos_santiago, style = "B")

## 15 minutos cada uno
bym_c1 <- S.CARbym(formula, family = "binomial", data = presidenciales_santiago,
                   trials = presidenciales_santiago$inscritos_2017_1,
                   W = matriz_adyacencia,
                   burnin = 2000000, n.sample = 4000000, thin = 10000)

bym_c2 <- S.CARbym(formula, family = "binomial", data = presidenciales_santiago,
                   trials = presidenciales_santiago$inscritos_2017_1,
                   W = matriz_adyacencia,
                   burnin = 2000000, n.sample = 4000000, thin = 10000)

bym_c3 <- S.CARbym(formula, family = "binomial", data = presidenciales_santiago,
                   trials = presidenciales_santiago$inscritos_2017_1,
                   W = matriz_adyacencia,
                   burnin = 2000000, n.sample = 4000000, thin = 10000)

# save(bym_c1, bym_c2, bym_c3, file = "./datos/bym.RData")
load("./datos/bym.RData")

beta_samples_bym <- mcmc.list(bym_c1$samples$beta,
                              bym_c2$samples$beta,
                              bym_c3$samples$beta)

gelman.diag(beta_samples_bym)

## Leroux ------------------------------------------------------------------------
### 10 minutos cada una
ler_c1 <- S.CARleroux(formula, family = "binomial", data = presidenciales_santiago,
                      trials = presidenciales_santiago$inscritos_2017_1,
                      W = matriz_adyacencia, burnin = 2000000, n.sample = 4000000,
                      thin = 10000)

ler_c2 <- S.CARleroux(formula, family = "binomial", data = presidenciales_santiago,
                      trials = presidenciales_santiago$inscritos_2017_1,
                      W = matriz_adyacencia, burnin = 2000000, n.sample = 4000000,
                      thin = 10000)

ler_c3 <- S.CARleroux(formula, family = "binomial", data = presidenciales_santiago,
                      trials = presidenciales_santiago$inscritos_2017_1,
                      W = matriz_adyacencia, burnin = 2000000, n.sample = 4000000,
                      thin = 10000)

save(ler_c1, ler_c2, ler_c3, file = "./datos/ler.RData")
# load("./datos/ler.RData")

beta_samples_ler <- mcmc.list(ler_c1$samples$beta,
                              ler_c2$samples$beta,
                              ler_c3$samples$beta)

gelman.diag(beta_samples_bym)

## Localised ----------------------------------------------------------------------
loc_c1 <- S.CARlocalised(formula, family = "binomial", data = presidenciales_santiago,
                         trials = presidenciales_santiago$inscritos_2017_1, G = 4,
                         W = matriz_adyacencia, burnin = 20000, n.sample = 40000)

loc_c2 <- S.CARlocalised(formula, family = "binomial", data = presidenciales_santiago,
                         trials = presidenciales_santiago$inscritos_2017_1, G = 4,
                         W = matriz_adyacencia, burnin = 20000, n.sample = 40000)

loc_c3 <- S.CARlocalised(formula, family = "binomial", data = presidenciales_santiago,
                         trials = presidenciales_santiago$inscritos_2017_1, G = 4,
                         W = matriz_adyacencia, burnin = 20000, n.sample = 40000)
