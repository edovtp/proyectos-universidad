// t-distributed regression - Zellner prior

data {
  int<lower=0> K;  // Number of coefficients
  int<lower=0> N;  // Sample size
  matrix[N, K] X;  // Intercept + adjusted market
  vector[N] y;     // Excess returns
  
  // Prior parameters
  vector[K] b0;
  cov_matrix[K] Sigma0;
  real<lower=0> nu0;
  real<lower=0> sigma0;
  real<lower=0> a;
  real<lower=0> b;
  real<lower=0> c;
  real<lower=0> d;
}

parameters {
  vector[K] beta;
  real<lower=0> sigma2;
  real<lower=0> nu;
  real<lower=0> g;
}

transformed parameters {
  real<lower=0> sigma;
  sigma = sqrt(sigma2);
}

model {
  y ~ student_t(nu, X * beta, sigma);
  beta ~ multi_normal(b0, g * sigma2 * Sigma0);
  sigma2 ~ scaled_inv_chi_square(nu0, sigma0);
  nu ~ gamma(c, d);
  g ~ gamma(a, b);
}

generated quantities {
  vector[N] y_rep;
  vector[N] log_lik;
  
  for (i in 1:N){
    log_lik[i] = normal_lpdf(y[i] | X[i] * beta, sigma);
    y_rep[i] = student_t_rng(nu, X[i] * beta, sigma);
  }
}
