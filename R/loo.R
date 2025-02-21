#' Get loo from xsdm model
#'
#' @param xsdm_object an xsdm object created with constuctor and validated
#' @param index An integer ginving the row index from the sample
#' @param ... argument passed to stan model sampling
#'
#' @return a fitted xsdm object
#'
loo <- function(xsdm_object, index = 1,...){
  values  <- unclass(xsdm_object)
  ts <- envDataArray(occ = values$occ,
                     values$env_data)

  values  <- unclass(xsdm_object)
  meta <- values$stan_model$metadata()
  match_lp <-  grep(pattern = "^lp", x = meta$model_params)
  params <- meta$model_params[-match_lp]
  df <- values$stan_model$draws(format = "df", variables = params)

  if(length(values$env_data) == 1){
    f <- function(env)function(mu, sigl, sigr, c, pd){
      prob_detec(env, mu, sigl, sigr, c, pd)
    }
    f_par <- f(ts)
    #coords <- terra::crds(values$env_data[[1]])
    prob_detect <- suppressWarnings(do.call(f_par, args = df[index, params]))
    loglik <- bernoulli_lpmf(prob_detect, values$occ$presence)
  }
  return(loglik)
}

