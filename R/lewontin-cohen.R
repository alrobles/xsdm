#' @title Lewontin-Cohen XSDM
#'
#' @importFrom rstan sampling
#' @export
#'
#' @param dat List of data to be passed to `rstan::sampling()`.
#' @param init Initial values to be passed to `rstan::sampling()`.
#' @param chains Ingeter, number of chains to run.
#' @param ... Additional arguments for `rstan::sampling()`.
#'
#' @return An object of class `stanfit` returned by `rstan::sampling`
#'
.lewontin_cohen <- function(dat, init, chains, ...) {
  fit <- sampling(
    stanmodels$lewontin_cohen,
    data = dat,
    init = init,
    chains = chains,
    ...
  )
  return(fit)
}

#' @title Univariate Lewontin-Cohen XSDM
#'
#' @importFrom rstan sampling
#' @export
#'
#' @param dat List of data to be passed to `rstan::sampling()`.
#' @param init Initial values to be passed to `rstan::sampling()`.
#' @param chains Ingeter, number of chains to run.
#' @param ... Additional arguments for `rstan::sampling()`.
#'
#' @return An object of class `stanfit` returned by `rstan::sampling`
#'
.lewontin_cohen_univariate <- function(dat, init, chains, ...) {
  fit <- sampling(
    stanmodels$lewontin_cohen_univariate,
    data = dat,
    init = init,
    chains = chains,
    ...
  )

  return(fit)
}
