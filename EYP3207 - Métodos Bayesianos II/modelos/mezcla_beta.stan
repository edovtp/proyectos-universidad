data {
  int<lower=1> K;                 // Number of components
  int<lower=0> N;                 // Number of observations
  vector<lower=0, upper=1>[N] y;  // Scaled data
  
  // Prior parameters
  vector<lower=0>[K] a;
}

parameters {
  simplex[K] eta;
}

model {
  // Likelihood
  vector[K] log_eta = log(eta);
  for (i in 1:N) {
    vector[K] lps = log_eta;
    for (j in 1:K)
      lps[j] += beta_lpdf(y[i] | j, K - j + 1);
    target += log_sum_exp(lps);
  }
  
  // Prior
  target += dirichlet_lpdf(eta | a);
}

generated quantities {
  vector[N] log_lik;
  vector[K] log_eta = log(eta);
  for (i in 1:N) {
    vector[K] lps = log_eta;
    for (j in 1:K) {
      lps[j] += beta_lpdf(y[i] | j, K - j + 1);
    }
    log_lik[i] = log_sum_exp(lps);
  }
}
