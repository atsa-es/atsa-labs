data {
  int<lower=0> n; // size of trainging set (with NAs)
  int<lower=0> n_o2; // number of observations
  int o2_x[n_o2];
  real o2_y[n_o2];
  real o2_sd[n_o2];
  int<lower=0> n_temp; // number of observations
  int temp_x[n_temp];
  real temp_y[n_temp];
  real temp_sd[n_temp];  
  int n_forecast;
  int n_lag_o2;
  int n_lag_temp;
}
transformed data {
  vector[2] zeros;
  matrix[2,2] identity;
  zeros = rep_vector(0, 2);
  identity = diag_matrix(rep_vector(1.0,2));
}
parameters {
  vector[n+n_forecast-1] o2_devs;
  vector[n+n_forecast-1] temp_devs;
  //cov_matrix[2] Sigma;
  real o2_x0[n_lag_o2]; // initial conditions
  real<lower=-1,upper=1> o2_b[n_lag_o2];
  real<lower=0.05, upper=0.25> o2_sd_proc;
  real<lower=0.3,upper=0.6> temp_sd_proc;
  real<lower=2> o2_df;
  real<lower=2> temp_df;
  real temp_x0[n_lag_temp]; // initial conditions
  real<lower=-1,upper=1> temp_b[n_lag_temp]; 
}
transformed parameters {
  vector[n+n_forecast] o2_pred;
  vector[n_forecast] o2_forecast;
  vector[n+n_forecast] temp_pred;
  vector[n_forecast] temp_forecast;  
  vector[n_lag_temp] temp_b_trans;
  vector[n_lag_o2] o2_b_trans;
  
  // predictions for first states
  for(t in 1:n_lag_o2) {
    o2_pred[t] = o2_x0[t];
  }
  for(t in 1:n_lag_o2) {
    temp_pred[t] = temp_x0[t];
  }  

  for(i in (1+n_lag_o2):(n+n_forecast)) {
    o2_pred[i] = 0;
    for(k in 1:n_lag_o2) {
      o2_pred[i] += o2_b[k]*o2_pred[i-k];
    }
    o2_pred[i] += o2_sd_proc*o2_devs[i-1];
  }
  for(i in (1+n_lag_temp):(n+n_forecast)) {
    temp_pred[i] = 0;
    for(k in 1:n_lag_temp) {
      temp_pred[i] += temp_b[k]*temp_pred[i-k];
    }
    temp_pred[i] += temp_sd_proc*temp_devs[i-1];
  }
  
  // this is redundant but easier to work with output -- creates object o2_forecast
  // containing forecast n_forecast time steps ahead
  for(t in 1:n_forecast) {
    o2_forecast[t] = o2_pred[n_o2+t];
    temp_forecast[t] = temp_pred[n_temp+t];
  }
    
}
model {
  // initial conditions
  o2_x0 ~ normal(7,3);
  o2_b ~ normal(1,1);
  // coefficients
  temp_x0 ~ normal(22,3);
  temp_b ~ normal(1,1);
  o2_sd_proc ~ student_t(3,0,2);
  temp_sd_proc ~ student_t(3,0,2);
  //o2_sd_obs ~ student_t(3,0,2);
  //temp_sd_obs ~ student_t(3,0,2);
  // df parameters
  o2_df ~ student_t(3,2,2);
  temp_df ~ student_t(3,2,2);
  // process standard deviations
  o2_devs ~ student_t(o2_df,0,1);
  temp_devs ~ student_t(temp_df,0,1);
  
  // likelihood
  for(t in 1:n_o2) {
    o2_y[t] ~ normal(o2_pred[o2_x[t]], o2_sd[t]);
  }
  for(t in 1:n_temp) {
    temp_y[t] ~ normal(temp_pred[temp_x[t]], temp_sd[t]);
  }
} 
