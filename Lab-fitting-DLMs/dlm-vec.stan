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
  vector[K] Theta[N]; // state space paramater
  cholesky_factor_corr[K] L_Omega; //prior correlation
  vector<lower=0>[K] L_tau; // prior scale
  real<lower=0> R; // model error
  vector[K] Theta0; // init Theta
}

transformed parameters {
  matrix[K, K] Q;
  vector[N] F_Theta;
  Q = diag_pre_multiply(L_tau, L_Omega);
  for (n in 1:N)
    F_Theta[n] = F[n]*Theta[n];
}

model {
  R ~ exponential(1);
  L_tau ~ exponential(1);
  L_Omega ~ lkj_corr_cholesky(2);
  Theta0 ~ normal(0, 5);
  Theta[1] ~ multi_normal_cholesky(Theta0, Q);
  for (n in 2:N)
    Theta[n] ~ multi_normal_cholesky(Theta[n-1], Q);
  y ~ normal(F_Theta, R);
}

