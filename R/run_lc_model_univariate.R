#' @title Fit the Bernoulli model.
#' @export
#' @family models
#' @description Fit the Bernoulli Stan model and return posterior summaries.
#' @return A data frame of posterior summaries.
#' @param occ Numeric vector of presence absence observations (zeroes and ones).
#' @param ts  Numeric array  of environmental variables. It has dimensions M (sites), N (time steps) and P (environmental variables)
#' @param ... Named arguments to the `sample()` method of CmdStan model
#'   objects: <https://mc-stan.org/cmdstanr/reference/model-method-sample.html>
#' @examples
#' if (FALSE) {
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
run_lc_model_univariate <- function(occ, ts, ...) {
  stopifnot(is.numeric(occ) && all(occ >= 0 & occ <= occ))
  model <- instantiate::stan_package_model(
    name = "lewontin_cohen_univariate",
    package = "xsdm"
  )

  stan_data <- list(M = length(occ),
                    N = dim(ts)[2],
                    occ = occ,
                    ts = ts,
                    grainsize = 10)


  fit <- model$sample(
    data = stan_data,
    ...)
  fit$summary()
}
