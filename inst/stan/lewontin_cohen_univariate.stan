//DAN: Adding notes for my own clarification. Eventually these are to 
//be deleted, possibly inspiring changes to comments to clarify for the
//next person.

data {
  int N; // observations //DAN: I think this is number of locations, some are 
                         //observations, some are going to be pseudo-absences
  int M; // timeseries length
  array[N] int<lower=0,upper=1> occ; //DAN: Binary presence/pseudo-absence.
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

//DAN: I do not currently understand the purpose for the "generated_quantities",
//but I wonder if the comment below mentioning Cholesky might be inaccurate?
//This is supposed to be the *univariate* L-C, which means there should not be
//and Cholesky decompositions involved anywhere.
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
