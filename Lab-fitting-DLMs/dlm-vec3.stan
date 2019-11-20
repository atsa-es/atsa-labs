data {
  int<lower=0> N; // length of dependent variable
  int<lower=0> K; // number of indep vars
  vector[N] y; // univariate time series
  row_vector[K] F[N]; // N vectors of size K (array[N,K])
}

transformed data {
  for (n in 1:N) {
      print("F[", n, "] = ", F[n]);
  }
}

parameters {
  vector[K] Theta0; // init Theta
  real<lower=0> R; // model error
  cholesky_factor_corr[K] L_Omega[N]; // cholesky factor of correlation matrix Omega
  vector<lower=0>[K] tau[N]; // scale values for Thetas
  vector[K] z[N]; // std normal
}

transformed parameters {
  matrix[K, K] L[N];
  vector[K] Theta[N]; // state space paramater
  vector[N] F_Theta;

  // produce covariance matrix for each Theta[n]
  for (n in 1:N)
    L[n] = diag_pre_multiply(tau[n], L_Omega[n]);

  Theta[1] = Theta0 + L[1] * z[1];
  for (n in 2:N)
    Theta[n] = Theta[n-1] + L[n] * z[n];

  for (n in 1:N)
    F_Theta[n] = F[n]*Theta[n];

}

model {
  R  ~ exponential(1);
  Theta0 ~ normal(0, 5);
  for (n in 1:N) {
      z[n] ~ normal(0, 1);
      L_Omega[n] ~ lkj_corr_cholesky(1);
      tau[n] ~ exponential(1);
  }
  y ~ normal(F_Theta, R);
}

generated quantities {
  matrix[K, K] Q[N];
  for (n in 1:N)
   Q[n] = L[n] * L[n]';
}


