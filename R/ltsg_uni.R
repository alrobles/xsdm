#' Univariate long term stochastic growth function for a
#' Lewontin Cohen demographic environmental model
#'
#' @param env Matrix Environmental time series (columns) per sites (rows)
#' @param mu numeric parameter.
#' @param sigl numeric parameter.
#' @param sigr numeric parameter
#'
#' @return A vector with long term stochastic growth values calculated in each site
ltsg_uni <- function(env, mu, sigl, sigr){
  if(is.vector(env)){
    env = matrix(env, ncol = length(env))
  }

  .response(env, mu, sigl, sigr) |>
    .meanRow()
}
