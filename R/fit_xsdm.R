#' Fit an xsdm model
#'
#' @param xsdm_object an xsdm object created with constuctor and validated
#' @param optim Default is false. Calculate the mle estimation (default) or
#' Maximum a posteriori estimation (need to pass jacobian = TRUE  argument)
#' @param ... argument passed to stan model sampling
#'
#' @return a fitted xsdm object
#'
fit_xsdm <- function(xsdm_object, optim = FALSE, ...){
  values  <- unclass(xsdm_object)
  ts <- envDataArray(occ = values$occ,
                   values$env_data)

  stan_data <- list(M = dim(ts)[1],
                    N = dim(ts)[2],
                    occ = values$occ$presence,
                    ts = ts, grainsize = 1
                    )


  if(length(values$env_data) == 1){
    model <- instantiate::stan_package_model(
      name = "lewontin_cohen_univariate",
      package = "xsdm"
    )
  } else {
    model <- instantiate::stan_package_model(
      name = "lewontin_cohen_univariate",
      package = "xsdm"
    )
  }

  if(optim){
    stan_model <- model$optimize(stan_data, ...)
  } else{
    stan_model <- model$sample(stan_data, ...)
  }

  xsdm <- new_xsdm(env_data = values$env_data,
                   occ = values$occ,
                   stan_model = stan_model)

  return(xsdm)
}

