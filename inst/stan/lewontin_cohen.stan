//DAN: Adding notes for my own clarification. Eventually these are to 
//be deleted, possibly inspiring changes to comments to clarify for the
//next person.

data {
  int N; // observations //DAN: I think this is number of locations, some are 
                         //observations, some are going to be pseudo-absences
  int M; // timeseries length
  int P; // environmental covariates //NUMBER of env covars
  array[N] int<lower=0,upper=1> occ; //DAN: Binary presence/pseudo-absence.
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

  // priors - all weakly informative
  mu ~ normal(0, 10); //DAN: See my comments in the univariate model on 1) how priors
                      //make me nervous, 2) how this appears to assume the env data
                      //have been somehow pre-normalized, and 3) how we are using the 
                      //wrong notation here.
  sigl ~ exponential(0.1);  // expected value and std = 10
  sigr ~ exponential(0.1);  // expected value and std = 10
  c ~ normal(0, 10);
  pd ~ uniform(0, 1);
  L ~ lkj_corr_cholesky(2.0);       // 2.0 = shape parameter

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
