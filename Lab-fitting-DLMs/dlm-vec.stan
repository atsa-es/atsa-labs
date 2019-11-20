data {
  int<lower=0> N; // length of dependent variable
  int<lower=0> K; // number of indep vars
  vector[N] y;
  row_vector[K] F[N]; // row_vectors of
}

transformed data {
  for (n in 1:N) {
      print("F[", n, "] = ", F[n]);
  }
}

parameters {
  vector[K] Theta0; // init Theta
  vector[K] Theta[N]; // state space paramater
  real<lower=0> R; // model error
  cholesky_factor_corr[K] L_Omega; //prior correlation
  vector<lower=0>[K] tau; // prior scale
}

transformed parameters {
  matrix[K, K] L;
  vector[N] F_Theta;

  L = diag_pre_multiply(tau, L_Omega);

  for (n in 1:N)
    F_Theta[n] = F[n]*Theta[n];
}

model {
  R ~ exponential(1);
  Theta0 ~ normal(0, 5);
  L_Omega ~ lkj_corr_cholesky(1);
  tau ~ exponential(1);
  Theta[1] ~ multi_normal_cholesky(Theta0, L);
  for (n in 2:N)
    Theta[n] ~ multi_normal_cholesky(Theta[n-1], L);
  y ~ normal(F_Theta, R);
}

generated quantities {
  matrix[K, K] Q;
  Q = L * L';
}

