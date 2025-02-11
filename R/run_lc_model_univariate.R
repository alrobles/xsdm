#' @title Fit the Lewontin Cohen model.
#' @family models
#' @description Fit the Bernoulli Stan model and return posterior summaries.
#' @return A data frame of posterior summaries.
#'
#' @param occ Numeric vector of presence absence observations (zeroes and ones).
#' @param ts  Numeric array  of environmental variables. It has dimensions M (sites), N (time steps) and P (environmental variables)
#' @param grainsize The grainsize for the reduce sum parallelization inerly handle by stan code. Ideally is the
#' @param ... Named arguments to the `sample()` method of CmdStan model
#' quotient between the number of observations and the number of cores.
#'   objects: <https://mc-stan.org/cmdstanr/reference/model-method-sample.html>
#' @examples
#' if (instantiate::stan_cmdstan_exists()) {
#'  occ <- mus_virtualis
#'  bio1_ts <- terra::unwrap(xsdm::cmcc_cm_bio1)
#'  bio12_ts <- terra::unwrap(xsdm::cmcc_cm_bio12)
#'  envData <- list(bio1 = bio1_ts)
#'  ts <- envDataArray(occ, envData)
#'  run_lc_model_univariate(
#'   occ = occ$presence,
#'   ts = ts
#'   )
#' }
run_lc_model_univariate <- function(occ, ts, grainsize = 10, ...) {
  stopifnot(is.numeric(occ) && all(occ >= 0 & occ <= occ))
  model <- lc_univariate()
  stan_data <- list(M = length(occ),
                      N = dim(ts)[2],
                      occ = occ,
                      ts = ts,
                      grainsize = grainsize)
  fit <- model$sample(data = stan_data, ...)
  return(fit)
}
