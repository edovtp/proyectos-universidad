// skew-normal regression - Zellner prior

data {
  int<lower=0> K;  // Number of coefficients
  int<lower=0> N;  // Sample size
  matrix[N, K] X;  // Intercept + adjusted market
  vector[N] y;     // Excess returns
  
  // Prior parameters
  vector[K] b0;
  cov_matrix[K] Sigma0;
  real<lower=0> a;
  real<lower=0> b;
  real<lower=0> c;
  real<lower=0> d;
}

parameters {
  vector[K] beta;
  real alpha;
  real<lower=0> w;
  real<lower=0> g;
}

transformed parameters {
  real delta;
  real<lower=0> sigma;
  delta = alpha/sqrt(1 + alpha^2);
  sigma = w * sqrt(1 - 2 * delta^2 / pi());
}

model {
  for (i in 1:N){
    y[i] ~ skew_normal(X[i] * beta - w * delta * sqrt(2 / pi()), w, alpha);
  }
  beta ~ multi_normal(b0, g * sigma^2 * Sigma0);
  w ~ gamma(c, d);
  g ~ gamma(a, b);
}

generated quantities {
  vector[N] y_rep;
  vector[N] log_lik;
  
  for (i in 1:N){
    log_lik[i] = skew_normal_lpdf(y[i] | X[i] * beta - w * delta * sqrt(2 / pi()), w, alpha);
    y_rep[i] = skew_normal_rng(X[i] * beta - w * delta * sqrt(2 / pi()), w, alpha);
  }
}
