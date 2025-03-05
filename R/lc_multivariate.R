#' lc_univariate Gets the multivariate Lewontin Cohen model
#' @return NULL Is required for it side effects
#' @export
#' @family models
#'
#' @examples
#' if (instantiate::stan_cmdstan_exists()) {
#'   lc_multivariate()
#' }
lc_multivariate <- function() {
  model <- instantiate::stan_package_model(
    name = "lewontin_cohen_multivariate",
    package = "xsdm"
  )
  return(model)
}
