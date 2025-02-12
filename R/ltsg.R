#' Univariate long term stochastic growth function for a
#' Lewontin Cohen demographic environmental model
#'
#' @param env Matrix Environmental time series (columns) per sites (rows)
#' @param mu numeric parameter.
#' @param sigl numeric parameter.
#' @param sigr numeric parameter
#'
#' @return A vector with long term stochastic growht values calculated in each site
#' @export
#'
#' @examples
#' ltsg(env = -1, mu = 0, sigl = 1, sigr = 0.9)
ltsg <- function(env, mu, sigl, sigr){
  if(!is.matrix(env)){
    env = matrix(env, ncol = length(env))
  }

  .response(env, mu, sigl, sigr) |>
    .meanRow()
}
