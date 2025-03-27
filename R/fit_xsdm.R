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

  ts <- envDataArray(values$env_data,
                     occ = values$occ)

  if(length(values$env_data) == 1){

    stan_data <- list(M = dim(ts)[1],
                      N = dim(ts)[2],
                      occ = values$occ$presence,
                      ts = ts,
                      grainsize = 1
    )

    mu_param <- mean(xsdm::envDataArray(values$env_data))
    sigma_param <- sd(xsdm::envDataArray(values$env_data))



    model <- instantiate::stan_package_model(
      name = "lewontin_cohen_univariate",
      package = "xsdm"
    )

    nchains <- 4
    init_list <- list(
      mu = mu_param,
      sigl = sigma_param,
      sigr = sigma_param,
      c = 10,
      pd = 0.9
    )

    init <- Map(f = \(x){init_list}, 1:nchains )

  } else {

    P = dim(ts)[3]

    mu_param <- sapply(1:P, function(x){
      mean(xsdm::envDataArray(values$env_data)[ , ,x])
    })

    sigma_param <- sapply(1:P, function(x){
      sd(xsdm::envDataArray(values$env_data)[ , ,x])
    })

    stan_data <- list(M = dim(ts)[1],
                      N = dim(ts)[2],
                      P = dim(ts)[3],
                      occ = values$occ$presence,
                      ts = ts,
                      mu_par = mu_param,
                      sigma_par = sigma_param,
                      grainsize = 1
    )

    nchains <- 4
    init_list <- list(
      mu = mu_param,
      sigl = sigma_param,
      sigr = sigma_param,
      c = 10,
      pd = 0.9
    )

    init <- Map(f = \(x){init_list}, 1:nchains )

    model <- instantiate::stan_package_model(
      name = "lewontin_cohen_multivariate",
      package = "xsdm"
    )
  }

  if(recompile){
    if( compile_standalone){
      model$compile(force_recompile = TRUE, cpp_options = list(stan_threads = TRUE), compile_standalone = TRUE)
    } else{
      model$compile(force_recompile = TRUE, cpp_options = list(stan_threads = TRUE))
    }
  }


  if(fit == "mle"){
    stan_model <- model$optimize(stan_data, init = list(init_list), jacobian = FALSE, ...)
  } else if(fit == "map") {
    stan_model <- model$optimize(stan_data, init = list(init_list), jacobian = TRUE, ...)
  } else if(fit == "mle.laplace"){
    fit_mode   <- model$optimize(stan_data, init = list(init_list), jacobian = FALSE, ...)
    stan_model <- model$laplace(data = stan_data, init = list(init_list), mode = fit_mode, jacobian = FALSE, ...)
  } else if(fit == "map.laplace"){
    fit_mode   <- model$optimize(stan_data, init = list(init_list), jacobian = TRUE, ...)
    stan_model <- model$laplace(data = stan_data, init = list(init_list), mode = fit_mode, ...)
  } else{
    stan_model <- model$sample(stan_data, init = init, chains = nchains,...)
  }

  xsdm <- new_xsdm(env_data = values$env_data,
                   occ = values$occ,
                   stan_model = stan_model)

  return(xsdm)
}

