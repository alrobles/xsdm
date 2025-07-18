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
#' @param normalize Logical, normalize the time series using the mean
#' and the standard deviation of the presence-absence provided points
#' @param prior_parameters list with parameters passed to prior.
#' @param nchains Default NULL. The number of mcmc chains passed to cmdstanr sample function.
#' @param ... argument passed to stan model sampling
#' @param compile_standalone Default TRUE. It is useful to export
#' loglik functions
#'
#' @return a fitted xsdm object
#'
fit_xsdm_berti <- function(xsdm_object,
                     fit = NULL,
                     recompile = FALSE,
                     normalize = FALSE,
                     prior_parameters = list(mu_par_1 = NULL,
                                             mu_par_2 = NULL ,
                                             sigl_par = NULL,
                                             sigr_par = NULL,
                                             c_par_1 = NULL,
                                             c_par_2 = NULL,
                                             L_par = NULL),
                     nchains = NULL,
                     compile_standalone = FALSE,

                     ...){
  values  <- unclass(xsdm_object)


  ### needs to add a function that computes this externally and can
  #store center and scale coefficients in case we need to normaliza

  ts <- envDataArray(values$env_data,
                     occ = values$occ)

  ts_presence <- envDataArray(values$env_data,
                              occ = values$occ[values$occ$presence == 1, ])


  if(length(values$env_data) == 1){

    if(normalize){
      ts = (ts - mean(ts))/stats::sd(ts)
    }
    if(is.null(prior_parameters$mu_par_1) ){
      prior_parameters$mu_par_1  <- mean(ts_presence)
    }

    if(is.null(prior_parameters$mu_par_2) ){
      prior_parameters$mu_par_2  <- stats::sd(ts_presence)*10
    }

    if(is.null(prior_parameters$sigl_par) ){
      prior_parameters$sigl_par  <- 1/stats::sd(ts_presence)
    }

    if(is.null(prior_parameters$sigr_par) ){
      prior_parameters$sigr_par  <- 1/stats::sd(ts_presence)
    }

    if(is.null(prior_parameters$c_par_1) ){
      prior_parameters$c_par_1  <- 0
    }

    if(is.null(prior_parameters$c_par_2) ){
      prior_parameters$c_par_2  <- 10
    }

    if(is.null(prior_parameters$L_par) ){
      prior_parameters$L_par  <- 2
    }



    stan_data <- list(M = dim(ts)[1],
                      N = dim(ts)[2],
                      occ = values$occ$presence,
                      mu_par_1 = prior_parameters$mu_par_1,
                      mu_par_2 = prior_parameters$mu_par_2,
                      sigl_par = prior_parameters$sigl_par,
                      sigr_par = prior_parameters$sigr_par,
                      c_par_1 = prior_parameters$c_par_1,
                      c_par_2 = prior_parameters$c_par_2,
                      ts = ts,
                      grainsize = 1
    )

    model <- instantiate::stan_package_model(
      name = "lewontin_cohen_univariate",
      package = "xsdm"
    )

    if(is.null(nchains)){
      nchains <- 4
    }

    init_list <- list(
      mu = prior_parameters$mu_par_1,
      sigl = 1/prior_parameters$sigl_par,
      sigr = 1/prior_parameters$sigl_par,
      c = 0,
      pd = 0.9
    )

    init <- Map(f = \(x){init_list}, 1:nchains )

  } else {

    P = dim(ts)[3]

    if(normalize){
      for(i in 1:P){
        ts[ , ,i] <- ( ts[ , ,i] - mean(ts[ , ,i]) )/stats::sd(ts[ , ,i])

      }

    }
    if(is.null(prior_parameters$mu_par_1) ){
      mu_par_1 <- sapply(1:P, function(x){
        mean(ts[ , ,x])
      })
      prior_parameters$mu_par_1  <- mu_par_1

    }

    if(is.null(prior_parameters$mu_par_2) ){
      mu_par_2 <- sapply(1:P, function(x){
        stats::sd(ts[ , ,x])
      })
      mu_par_2 <- mu_par_2*10
      prior_parameters$mu_par_2  <- mu_par_2
    }

    if(is.null(prior_parameters$sigl_par) ){
      sigma_par <- sapply(1:P, function(x){
        stats::sd(ts[ , ,x])
      })
      sigma_par <- 1/(sigma_par)
      prior_parameters$sigl_par  <- sigma_par
    }


    if(is.null(prior_parameters$sigr_par) ){
      sigma_par <- sapply(1:P, function(x){
        stats::sd(ts[ , ,x])
      })
      sigma_par <- 1/(sigma_par)
      prior_parameters$sigr_par  <- sigma_par

    }

    if(is.null(prior_parameters$c_par_1) ){
      prior_parameters$c_par_1  <- 0
    }

    if(is.null(prior_parameters$c_par_2) ){
      prior_parameters$c_par_2  <- 10
    }

    if(is.null(prior_parameters$L_par) ){
      prior_parameters$L_par  <- 2
    }


    stan_data <- list(N = dim(ts)[1],
                      M = dim(ts)[2],
                      P = dim(ts)[3],
                      occ = values$occ$presence,
                      ts = ts,
                      mu_par_1 = prior_parameters$mu_par_1,
                      mu_par_2 = prior_parameters$mu_par_2,
                      sigl_par = prior_parameters$sigl_par,
                      sigr_par = prior_parameters$sigr_par,
                      c_par_1 = prior_parameters$c_par_1,
                      c_par_2 = prior_parameters$c_par_2,
                      L_par = prior_parameters$L_par,
                      grainsize = 1
    )

    if(is.null(nchains)){
      nchains <- 4
    }

    init_list <- list(
      mu = prior_parameters$mu_par_1,
      sigl = 1/prior_parameters$sigl_par,
      sigr = 1/prior_parameters$sigr_par,
      c = 0,
      pd = 0.9
      ,L = diag(nrow = P)
    )

    init <- Map(f = \(x){init_list}, 1:nchains )

    model <- instantiate::stan_package_model(
      name = "lewontin_cohen_multivariate_berti",
      package = "xsdm"
    )
  }

  #stan_model <- model$sample(stan_data, init = init, chains = nchains,...)

  if(recompile){
    if( compile_standalone){
      model$compile(force_recompile = TRUE, cpp_options = list(stan_threads = TRUE), compile_standalone = TRUE)
    } else{
      model$compile(force_recompile = TRUE, cpp_options = list(stan_threads = TRUE))
    }
  }

  if(fit == "mle"){
    stan_model <- model$optimize(stan_data, init = list(init_list), jacobian = FALSE, ...)
  }
  else if(fit == "map") {
    stan_model <- model$optimize(stan_data, jacobian = TRUE, ...)
  } else if(fit == "mle.laplace"){
    fit_mode   <- model$optimize(stan_data, init = list(init_list), jacobian = FALSE, ...)
    stan_model <- model$laplace(data = stan_data, init = list(init_list), mode = fit_mode, jacobian = FALSE, ...)
  } else if(fit == "map.laplace"){
    fit_mode   <- model$optimize(stan_data, init = list(init_list), jacobian = TRUE, ...)
    stan_model <- model$laplace(data = stan_data, init = list(init_list), mode = fit_mode, ...)
  } else if(fit == "pathfinder"){
    num_paths = nchains
    stan_model <- model$pathfinder(data = stan_data, init = init <- Map(f = \(x){init_list}, 1:nchains ), num_paths  = nchains, ...)
  } else {
    stan_model <- model$sample(stan_data, init = init, chains = nchains,...)
  }
  xsdm <- new_xsdm(env_data = values$env_data,
                   occ = values$occ,
                   stan_model = stan_model)

  return(xsdm)
}
