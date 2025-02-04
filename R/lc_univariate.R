#' lc_univariate Gets the Lewontin Cohen model
#' univariate
#'
#' @return NULL Is required for it side effects
#' @export
#' @family models
#'
#' @examples
#' if (instantiate::stan_cmdstan_exists()) {
#'   +
#'   lc_univariate()
#' }
lc_univariate <- function() {
  model <- instantiate::stan_package_model(
    name = "lewontin_cohen_univariate",
    package = "xsdm"
  )

  return(model)
}
