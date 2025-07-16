data {
  int N; // observations
  int M; // timeseries length
  int P; // environmental covariates
  array[N] int<lower=0,upper=1> occ;
  array[N,M,P] real ts;

  vector[P] mu_par_1;
  vector[P] mu_par_2;
  vector[P] sigl_par;
  vector[P] sigr_par;
  real c_par_1;
  real c_par_2;
  real L_par;
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
  // mu[1] ~ normal(14.94015, 345.78505);
  // mu[2] ~ normal(20.87634, 1162.07217);
  // sigl[1] ~ exponential(0.479011234);
  // sigl[2] ~ exponential(0.008605318);
  // sigr[1] ~ exponential(0.479011234);
  // sigr[2] ~ exponential(0.008605318);
  // L ~ lkj_corr_cholesky(2.0);         // 2.0 = shape parameter
  // c ~ normal(0, 10);
  // pd ~ uniform(0, 1);


  for (k in 1:P){
    mu[k] ~ normal(mu_par_1[k], mu_par_2[k]);
    sigl[k] ~ exponential(sigl_par[k]);
    sigr[k] ~ exponential(sigr_par[k]);
  }
  c ~ normal(c_par_1, c_par_2);
  pd ~ uniform(0, 1);
  L ~ lkj_corr_cholesky(L_par);

  // likelihood
  for(i in 1:N){                      // loop over locations
    for(j in 1:M){                    // loop over time
      w = to_vector(ts[i,j, ]);
      for (k in 1:P){                 // loop over covariates
      w[k] = (w[k] - mu[k]);
        if (w[k] < 0) {
          v[k] = ( w[k] / sigl[k] );
      } else {
          v[k] = ( w[k] / sigr[k] );
        }
      }
      u = mdivide_left_tri_low(L, v);
      response[j] = -0.5 * sum(u .* u);
    }
    loglam[i] = mean(response);
  }
  occ ~ bernoulli(pd * inv_logit(loglam - c));
}

generated quantities{ // calculate correlation matrix R from Cholesky matrix L
  matrix[P,P] R;
  R = L*(L');
}
