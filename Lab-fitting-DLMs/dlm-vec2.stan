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
  real mu0[K];
  real<lower=0> alpha;
  real<lower=0> rho;
  real<lower=0> R; // model error scale
  vector[K] a;

}

transformed parameters {
  matrix[K, K] L;
  matrix[K, K] Q = cov_exp_quad(mu0, alpha, rho);
  vector[N] F_Theta;
  vector[K] Theta[N]; // state space paramater
  L = cholesky_decompose(Q);

  Theta[1] = Theta0 + L * a;
  for (n in 2:N) {
    Theta[n] = Theta[n-1] + L * a;
  }

  for (n in 1:N) {
    F_Theta[n] = F[n]*Theta[n];
  }

}

model {
  Theta0 ~ normal(0, 5);
  mu0  ~ normal(0, 5);
  alpha  ~ std_normal();
  rho  ~ inv_gamma(2,2);
  R  ~ exponential(1);
  a  ~ std_normal();
  y ~ normal(F_Theta, R);
}

