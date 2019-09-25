data {
  int<lower=0> N; // length of dependent variable
  int<lower=0> K; // number of indep vars
  vector[N] y;
  row_vector[K] F[N]; // N vectors of size K (array[N,K])
}

transformed data {
  for (n in 1:N) {
      print("F[", n, "] = ", F[n]);
  }
}

parameters {
  real<lower=0> R; // model error
  vector<lower=0>[K] A; // init error
  vector[K] zA; // scale init error
  cholesky_factor_corr[K] L_Omega; // prior cholesky factor corr
  vector<lower=0>[K] tau; // prior scale
  vector[K] z[N]; // std normal
}

transformed parameters {
  matrix[K, K] L;
  vector[K] Theta0; // init Theta
  vector[K] Theta[N]; // state space paramater
  vector[N] F_Theta;

  L = diag_pre_multiply(tau, L_Omega);

  for (k in 1:K)
    Theta0[k] = A[k] * zA[k];

  Theta[1] = Theta0 + L * z[1];
  for (n in 2:N)
    Theta[n] = Theta[n-1] + L * z[n];

  for (n in 1:N)
    F_Theta[n] = F[n]*Theta[n];

}

model {
  R ~ exponential(1);
  A ~ exponential(1);
  zA ~ normal(0,1);
  L_Omega ~ lkj_corr_cholesky(1);
  tau ~ exponential(1);
  for (n in 1:N)
    z[n] ~ normal(0, 1);
  y ~ normal(F_Theta, R);
}

generated quantities {
  matrix[K, K] Q;
  Q = L * L';
}
