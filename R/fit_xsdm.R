#' Fit an xsdm model
#'
#' @param xsdm_object an xsdm object created with constuctor and validated
#' @param fit String. Default is TRUE. Calculate parameters either by sampling,
#' optimization or Laplace methods. Calculate the mle estimation (default) or
#' Maximum a posteriori estimation (need to pass jacobian = TRUE  argument).
#' Possible parameters are c("mle", "map", "mle.laplace", "map.laplace")
#' @param recompile Default FALSE. If TRUE, recompile the Lewontin-Cohen model
#' to use features not availiable out of the box. It is needed
#' to use laplace and optim methods.
#' @param compile_standalone Default TRUE. It is useful to export
#' loglik functions
#' @param ... argument passed to stan model sampling
#'
#' @return a fitted xsdm object
#'
fit_xsdm <- function(xsdm_object, fit = NULL, recompile = FALSE, compile_standalone = FALSE, ...){
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

  if(recompile){
    if( compile_standalone){
      model$compile(force_recompile = TRUE, compile_standalone = TRUE)
    }else{
      model$compile(force_recompile = TRUE)
    }
  }


  if(fit == "mle"){
    stan_model <- model$optimize(stan_data, jacobian = FALSE, ...)
  } else if(fit == "map") {
    stan_model <- model$optimize(stan_data, jacobian = TRUE, ...)
  } else if(fit == "mle.laplace"){
    fit_mode   <- model$optimize(stan_data, jacobian = FALSE, ...)
    stan_model <- model$laplace(data = stan_data, mode = fit_mode, jacobian = FALSE, ...)
  } else if(fit == "map.laplace"){
    fit_mode   <- model$optimize(stan_data, jacobian = TRUE, ...)
    stan_model <- model$laplace(data = stan_data, mode = fit_mode, ...)
  } else{
    stan_model <- model$sample(stan_data, ...)
  }

  xsdm <- new_xsdm(env_data = values$env_data,
                   occ = values$occ,
                   stan_model = stan_model)

  return(xsdm)
}

