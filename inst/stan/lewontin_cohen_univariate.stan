data {
  int N; // observations
  int M; // timeseries length
  array[N] int<lower=0,upper=1> occ;
  array[N, M] real ts;
}

parameters {
  // demographic model
  real mu;
  real<lower=0> sigl;
  real<lower=0> sigr;
  
  // observation model
  real c;
  real<lower=0,upper=1> pd;
}

model{
  // auxiliary variables
  vector[M] response;
  vector[N] loglam;
  real u; 
  real v; 

  // priors - all weakly informative
  mu ~ normal(0, 10);
  sigl ~ exponential(1);  // expected value and std = 10
  sigr ~ exponential(1);  // expected value and std = 10
  c ~ normal(0, 10);
  pd ~ uniform(0, 1);

  // likelihood
  for(i in 1:N){                      // loop over locations
    for(j in 1:M){                    // loop over time
      u = ts[i, j] - mu;
      if (u < 0) { 
        v = ( u / sigl )^2; 
      } else { 
        v = ( u / sigr )^2; 
      }
      response[j] = -0.5 * v;
    }
    loglam[i] = mean(response);
  }
  occ ~ bernoulli(pd * inv_logit(loglam - c)); 
}

generated quantities{ // calculate correlation matrix R from Cholesky matrix L
  vector[N] log_lik;{
    // auxiliary variables
    vector[M] response;
    vector[N] loglam;
    real u; 
    real v;
    
    // likelihood
    for(i in 1:N){                      // loop over locations
      for(j in 1:M){                    // loop over time
        u = ts[i, j] - mu;
        if (u < 0) { 
          v = ( u / sigl )^2; 
        } else { 
          v = ( u / sigr )^2; 
        }
        response[j] = -0.5 * v;
      }
      loglam[i] = mean(response);
      log_lik[i] = bernoulli_lpmf(occ[i] | pd * inv_logit(loglam[i] - c)); 
    }
  }
}
