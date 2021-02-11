data {
  int<lower=0> n; // size of trainging set (with NAs)
  int<lower=0> n_o2; // number of observations
  int o2_x[n_o2];
  real o2_y[n_o2];
  real o2_sd[n_o2];
  int n_forecast;
  int n_lag;
}
transformed data {
  vector[2] zeros;
  matrix[2,2] identity;
  zeros = rep_vector(0, 2);
  identity = diag_matrix(rep_vector(1.0,2));
}
parameters {
  vector[n+n_forecast-1] o2_devs;
  //cov_matrix[2] Sigma;
  //real<lower=0> o2_sd_proc;
  //real<lower=0> temp_sd_proc;
  real o2_x0[n_lag]; // initial conditions
  real<lower=-1,upper=1> o2_b[n_lag];
}
transformed parameters {
  vector[n+n_forecast] o2_pred;
  vector[n_forecast] o2_forecast;
  // predictions for first states
  for(t in 1:n_lag) {
    o2_pred[t] = o2_x0[t];
  }
  
  for(i in 2:(n+n_forecast)) {
    o2_pred[i] = 0;
    for(k in 1:n_lag) {
      o2_pred[i] = o2_pred[i] + o2_b[k]*o2_pred[i-1];
    }
    o2_pred[i] = o2_pred[i] + o2_devs[i-1];
  }
  // this is redundant but easier to work with output -- creates object o2_forecast
  // containing forecast n_forecast time steps ahead
  for(t in 1:n_forecast) {
    o2_forecast[t] = o2_pred[n_o2+t];
   }
    
}
model {
  // initial conditions
  o2_x0 ~ normal(0,1);
  o2_b ~ normal(0,1);
  
  // process standard deviations
  o2_devs ~ std_normal();

  // likelihood
  for(t in 1:n_o2) {
    o2_y[t] ~ normal(o2_pred[o2_x[t]], o2_sd[t]);
  }
} 
