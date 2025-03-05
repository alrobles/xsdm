functions {
  real partial_sum_lpmf(array[] int slice_n_occ,
                        int start,
                        int end,
                        array[,,] real ts,
                        int N,
                        int P,
                        vector mu,
                        vector sigl,
                        vector sigr,
                        matrix L,
                        real pd,
                        real c) {
    int M = (end - start + 1);
    vector[N] response;
    vector[M] loglam;
    vector[P] u;
    vector[P] v;
    vector[P] w;
    array[M, N, P] real ts_slice = ts[start:end];

    for(i in 1:M){                      // loop over locations
      for(j in 1:N){                    // loop over time
        w = to_vector(ts_slice[i,j, ]);
        u = mdivide_left_tri_low(L, w - mu);
        for (k in 1:P){
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
    return bernoulli_lpmf(slice_n_occ | pd * inv_logit(loglam - c));
  }
}

data {
  int M; // observations //DAN: I think this is number of locations, some are
                         //observations, some are going to be pseudo-absences
  int N; // timeseries length
  int P; // environmental covariates //NUMBER of env covars
  array[M] int<lower=0,upper=1> occ; //DAN: Binary presence/pseudo-absence.
  array[M,N,P] real ts;
  int<lower=1> grainsize;
}

parameters {
  // demographic model
  vector[P] mu;
  vector<lower=0>[P] sigl;
  vector<lower=0>[P] sigr;
  cholesky_factor_corr[P] L;

  // observation model
  real c;
  real<lower=0,upper=1> pd;
}

model{
  // priors - all weakly informative
  mu ~ normal(0, 10);
  sigl ~ exponential(1);
  sigr ~ exponential(1);
  c ~ normal(0, 10);
  pd ~ uniform(0, 1);
  L ~ lkj_corr_cholesky(2.0);

  // likelihood
  target += reduce_sum(partial_sum_lupmf,
                        occ,
                        grainsize,
                        ts,
                        N,
                        P,
                        mu,
                        sigl,
                        sigr,
                        L,
                        pd,
                        c);
}

