//Partial sum function.

functions {
  real partial_sum_lpmf(array[] int slice_n_occ,
                        int start, int end,
                        matrix ts,
                        int N,
                        real mu,
                        real sigl,
                        real sigr,
                        real pd,
                        real c) {


    int M = (end-start+1);
    vector[N] response;
    vector[M] loglam;
    matrix[M, N] ts_slice = ts[start:end];
    real u;
    real v;

    for(i in 1:M){                      // loop over locations
     for(j in 1:N){                    // loop over time
      u = ts_slice[i, j] - mu;
      if (u < 0) {
        v = ( u / sigl )^2;
      } else {
        v = ( u / sigr )^2;
      }
      response[j] = -0.5 * v;
    }
    loglam[i] = mean(response);
  }

    return bernoulli_lpmf(slice_n_occ | pd * inv_logit(loglam - c));
  }

  vector growing_function(matrix ts,
                          int N,
                          int M,
                          real mu,
                          real sigl,
                          real sigr,
                          real pd,
                          real c) {


    vector[N] response;
    vector[M] loglam;
    real u;
    real v;

    for(i in 1:M){                      // loop over locations
     for(j in 1:N){                    // loop over time
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
    return pd * inv_logit(loglam - c);
  }

}

data {
  int M; // observations
  int N; // timeseries length
  array[M] int<lower=0,upper=1> occ; //Binary presence/pseudo-absence.
  matrix[M, N] ts;
  int<lower=1> grainsize;
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

  // priors - all weakly informative
  mu ~ normal(0, 10); //DAN: Priors make me nervous. In particular, it seems to me
                      //this prior relies on having somehow standardized the
                      //environmental time series, not sure how
  sigl ~ exponential(1);  // expected value and std = 10
  sigr ~ exponential(1);  // expected value and std = 10
  c ~ normal(0, 10); //DAN: These parameters are not the parameters of the same name
                     //in the math write-ups we have, instead they are the re-parameterized
                     //versions, the ones for which we used tildes in the math documents,
                     //including in the paper. I find that notation choice confusing and
                     //possibly error-producing and think we should consider changing
                     //notation here and elsewhere, e.g., changing sigl to sigl_tilde, etc.
                     //I did not do it myself because I don't want to risk breaking anything
                     //before I understand the whole code suite.
  pd ~ uniform(0, 1);


  // likelihood
  target += reduce_sum(partial_sum_lupmf, occ, grainsize,
                       ts, N, mu, sigl, sigr, pd, c);
}
