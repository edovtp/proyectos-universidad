library(tidyverse)
library(readr)
library(rstan)
library(loo)
library(bayesplot)
library(shinystan)
library(patchwork)


set.seed(219)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Análisis exploratorio -------------------------------------------------------------
retornos <- read_csv("data/retornos.csv") %>% 
  dplyr::select(periodo, TBONOS, IPSA, ENEL)

ggplot(retornos, aes(x = periodo, y = ENEL)) +
  geom_line() +
  labs(x = "Fecha", y = "Retorno",
       title = "Evolución de retornos de ENEL",
       subtitle = "Período 2002-2022") +
  theme_minimal()

# Modelo CAPM -----------------------------------------------------------------------
ENEL_ajustado <- retornos$ENEL - retornos$TBONOS
mercado_ajustado <- retornos$IPSA - retornos$TBONOS

adj_returns <- tibble(adj_ENEL = ENEL_ajustado,
                      adj_market = mercado_ajustado)

ggplot(tibble(x = mercado_ajustado, y = ENEL_ajustado), aes(x, y)) +
  geom_point() +
  labs(x = "Retornos IPSA", y = "Retornos ENEL",
       title = "Relación entre retornos de ENEL y retornos de mercado") +
  theme_minimal()

N <- nrow(adj_returns)
X <- cbind(1, adj_returns$adj_market)

## 1. Priori de Zellner
lm_freq <- lm(adj_ENEL ~ adj_market, data = adj_returns)

b0 <- lm_freq$coefficients
Sigma0 <- solve(t(X) %*% X)
nu0 <- 1
sigma0 <- summary(lm_freq)$sigma
a <- N
b <- 1

capm_zellner_data <- list(
  K = 2, N = N, X = X, y = adj_returns$adj_ENEL,
  b0 = b0, Sigma0 = Sigma0,
  nu0 = nu0, sigma0 = sigma0,
  a = a, b = b
)

fit_zellner <- rstan::stan(
  "modelos/zellner.stan",
  data = capm_zellner_data
)

## 2. Colas pesadas
capm_colas_pesadas_data <- list(
  K = 2,
  N = N,
  X = X,
  y = adj_returns$adj_ENEL,
  b0 = b0, Sigma0 = Sigma0,
  nu0 = nu0, sigma0 = sigma0,
  a = a, b = b, c = 2, d = 0.1
)

fit_t <- rstan::stan(
  "modelos/colas_pesadas.stan",
  data = capm_colas_pesadas_data
)

## 3. Colas asimétricas
capm_asimetrico_data <- list(
  K = 2,
  N = N,
  X = X,
  y = adj_returns$adj_ENEL,
  b0 = b0, Sigma0 = Sigma0,
  a = a, b = b, c = 2, d = 1
)

fit_asimetrico <- rstan::stan(
  "modelos/asimetrico.stan",
  data = capm_asimetrico_data
)

## Comparación de los tres modelos
print(fit_zellner, pars = c("beta", "sigma", "g"))
print(fit_t, pars = c("beta", "sigma", "g", "nu"), digits_summary = 3)
print(fit_asimetrico, pars = c("beta", "sigma", "alpha", "g"), digits_summary = 3)

### WAIC y PSIS-LOOCV
loo::waic(extract_log_lik(fit_zellner, merge_chains = FALSE))
loo::waic(extract_log_lik(fit_t, merge_chains = FALSE))
loo::waic(extract_log_lik(fit_asimetrico, merge_chains = FALSE))

ll_zellner <- extract_log_lik(fit_zellner, merge_chains = FALSE)
ll_t <- extract_log_lik(fit_t, merge_chains = FALSE)
ll_asim <- extract_log_lik(fit_asimetrico, merge_chains = FALSE)

loo1 <- loo::loo(ll_zellner, r_eff = relative_eff(exp(ll_zellner)))
loo2 <- loo::loo(ll_t, r_eff = relative_eff(exp(ll_t)))
loo3 <- loo::loo(ll_asim, r_eff = relative_eff(exp(ll_asim)))

loo_compare(list(loo1, loo2, loo3))

# shinystan::launch_shinystan(fit_zellner)
# shinystan::launch_shinystan(fit_t)
# shinystan::launch_shinystan(fit_asimetrico)

## Model Checking
## Observado vs replicas
y_rep <- extract(fit_asimetrico)[["y_rep"]]
ppc_dens_overlay(y = ENEL_ajustado, y_rep[1:10, ], alpha=0.9)

## Estadísticos de prueba
p1 <- ppc_stat(ENEL_ajustado, y_rep, stat = "mean")
p2 <- ppc_stat(ENEL_ajustado, y_rep, stat = "min")
p3 <- ppc_stat(ENEL_ajustado, y_rep, stat = "max")
p4 <- ppc_stat(ENEL_ajustado, y_rep, stat = "sd")

(p1 + p2) / (p3 + p4)

# Modelo de mezcla ------------------------------------------------------------------
capm_mezcla_data <- list(
  K = 2,
  N = N,
  X = X,
  y = adj_returns$adj_ENEL,
  mu = c(-0.1, -0.01, 0.05),
  b0 = b0, Sigma0 = Sigma0,
  a = 2, b = 200, 
  nu0 = 1, sigma0 = sigma0
)

fit_mezcla <- rstan::stan(
  "modelos/mezcla.stan",
  data = capm_mezcla_data,
  iter = 10000,
  warmup = 8000
)

saveRDS(fit_mezcla, "fit_mezcla.rds")

print(fit_mezcla, pars = c("beta", "w", "sigma2"), digits_summary = 4)
loo::waic(extract_log_lik(fit_mezcla, merge_chains = FALSE))

ll_mezcla <- extract_log_lik(fit_mezcla, merge_chains = FALSE)
loo4 <- loo::loo(ll_mezcla, r_eff = relative_eff(exp(ll_mezcla)))
loo_compare(list(loo1, loo2, loo3, loo4))

y_rep <- extract(fit_mezcla)[["y_rep"]]
ppc_dens_overlay(y = ENEL_ajustado, y_rep[1:20, ], alpha=0.9)

p1 <- ppc_stat(ENEL_ajustado, y_rep, stat = "mean")
p2 <- ppc_stat(ENEL_ajustado, y_rep, stat = "sd")
p3 <- ppc_stat(ENEL_ajustado, y_rep, stat = "min")
p4 <- ppc_stat(ENEL_ajustado, y_rep, stat = "max")

(p1 + p2) / (p3 + p4)
