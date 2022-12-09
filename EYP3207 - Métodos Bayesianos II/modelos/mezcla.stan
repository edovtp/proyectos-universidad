// Mixture regression

data {
  int<lower=0> K;  // Number of coefficients
  int<lower=0> N;  // Sample size
  matrix[N, K] X;  // Intercept + adjusted market
  vector[N] y;     // Excess returns
  vector[3] mu;    // Mixture means
  
  // Prior parameters
  vector[K] b0;
  cov_matrix[K] Sigma0;
  real<lower=0> nu0;
  real<lower=0> sigma0;
  real<lower=0> a;
  real<lower=0> b;
}

parameters {
  vector[K] beta;
  real<lower=0, upper=1> w1;
  vector<lower=0, upper=0.1>[3] sigma2;
}

transformed parameters {
  simplex[3] w;
  w[1] = w1;
  w[3] = (mu[2] * (1 - w1) + mu[1] * w1)/(mu[2] - mu[3]);
  w[2] = 1 - w1 - w[3];
}

model {
  // Likelihood
  vector[3] log_w = log(w);
  for (i in 1:N) {
    vector[3] lps = log_w;
    lps[1] += normal_lpdf(y[i] | X[i] * beta + mu[1], sqrt(sigma2[1]));
    lps[2] += normal_lpdf(y[i] | X[i] * beta + mu[2], sqrt(sigma2[2]));
    lps[3] += normal_lpdf(y[i] | X[i] * beta + mu[3], sqrt(sigma2[3]));
    target += log_sum_exp(lps);
  }
  
  // Priors
  beta ~ multi_normal(b0, Sigma0);
  w1 ~ beta(a, b);
  sigma2 ~ uniform(0, 0.1);
}

generated quantities {
  vector[N] y_rep;
  vector[N] log_lik;
  vector[3] log_w = log(w);
  
  for (i in 1:N){
    // log_lik
    vector[3] lps = log(w);
    lps[1] += normal_lpdf(y[i] | X[i] * beta + mu[1], sqrt(sigma2[1]));
    lps[2] += normal_lpdf(y[i] | X[i] * beta + mu[2], sqrt(sigma2[2]));
    lps[3] += normal_lpdf(y[i] | X[i] * beta + mu[3], sqrt(sigma2[3]));
    log_lik[i] = log_sum_exp(lps);
    
    // y_rep
    int component = categorical_rng(w);
    y_rep[i] = normal_rng(X[i] * beta + mu[component], sqrt(sigma2[component]));
  }
}
