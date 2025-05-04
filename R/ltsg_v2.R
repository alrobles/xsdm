#' Univariate long term stochastic growth function for a
#' Lewontin Cohen demographic environmental model
#'
#' @param env Matrix Environmental time series (columns) per sites (rows)
#' @param mu numeric parameter.
#' @param sig numeric parameter.
#'
#' @return A vector with long term stochastic growht values calculated in each site
#' @export
#'
#' @examples
#' ltsg_v2(env = -1, mu = 0, sig = 1)
ltsg_v2 <- function(env, mu, sig){

  if(is.vector(env)){
    env = matrix(env, ncol = length(env))
  }

  dimsEnv <- dim(env)

  if(is.na(dimsEnv[3])){
    ltsg_result <- ltsg_uni(env, mu, sig, sig)
  } else {
    ltsg_result <-  ltsg_multi_v2(env, mu = mu, sig = sig)

  }

  return(ltsg_result)


}
