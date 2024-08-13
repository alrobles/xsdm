data {
  int N; // observations
  int M; // timeseries length
  int P; // environmental covariates
  array[N] int<lower=0,upper=1> occ;
  array[N,M,P] real ts;
}

parameters {
  // demographic model
  vector[P] mu;
  vector<lower=0>[P] sigl;
  vector<lower=0>[P] sigr;
  cholesky_factor_corr[P] L;          // corr R=L*L'
  
  // observation model
  real c;
  real<lower=0,upper=1> pd;
}

model{
  // auxiliary variables
  vector[M] response;
  vector[N] loglam;
  vector[P] u; 
  vector[P] v; 
  vector[P] w; 

  // priors
  mu ~ normal(0, 10);
  sigl ~ exponential(0.01);
  sigr ~ exponential(0.01);
  L ~ lkj_corr_cholesky(2.0);         // 2.0 = shape parameter
  c ~ normal(0, 100);
  pd ~ uniform(0, 1);

  // likelihood
  for(i in 1:N){                      // loop over locations
    for(j in 1:M){                    // loop over time
      w = to_vector(ts[i,j, ]);
      u = mdivide_left_tri_low(L, w - mu);
      for (k in 1:P){                 // loop over covariates
        if (u[k] < 0) { 
          v[k] = ( u[k] / sigl[k] )^2; 
      } else { 
          v[k] = ( u[k] / sigr[k] )^2; 
        }
      }
      response[j] = -0.5 * sum(v);
    }
    loglam[i] = mean(response);
  }
  occ ~ bernoulli(pd * inv_logit(loglam - c)); 
}

generated quantities{ // calculate correlation matrix R from Cholesky matrix L
  matrix[P,P] R;
  vector[N] log_lik;{
    // auxiliary variables
    vector[M] response;
    vector[N] loglam;
    vector[P] u; 
    vector[P] v; 
    vector[P] w; 
    
    // likelihood
    for(i in 1:N){                      // loop over locations
      for(j in 1:M){                    // loop over time
        w = to_vector(ts[i,j, ]);
        u = mdivide_left_tri_low(L, w - mu);
        for (k in 1:P){                 // loop over covariates
          if (u[k] < 0) { 
            v[k] = ( u[k] / sigl[k] )^2; 
        } else { 
            v[k] = ( u[k] / sigr[k] )^2; 
          }
        }
        response[j] = -0.5 * sum(v);
      }
      loglam[i] = mean(response);
      log_lik[i] = bernoulli_lpmf(occ[i] | pd * inv_logit(loglam[i] - c)); 
    }
  }
  R = L*(L');
}
