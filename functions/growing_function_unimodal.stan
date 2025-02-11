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
