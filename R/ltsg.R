#' Univariate long term stochastic growth function for a
#' Lewontin Cohen demographic environmental model
#'
#' @param env Matrix Environmental time series (columns) per sites (rows)
#' @param mu numeric parameter.
#' @param sigl numeric parameter.
#' @param sigr numeric parameter
#' @param L matrix parameter
#'
#' @return A vector with long term stochastic growht values calculated in each site
#' @export
#'
#' @examples
#' ltsg(env = -1, mu = 0, sigl = 1, sigr = 0.9)
ltsg <- function(env, mu, sigl, sigr, L = NULL){

  if(is.vector(env)){
    env = matrix(env, ncol = length(env))
  }

  dimsEnv <- dim(env)

  if(is.na(dimsEnv[3])){
    ltsg_result <- ltsg_uni(env, mu, sigl, sigr)
  } else {
    if(is.null(L)){
      stop("Provide an L matrix")
    }
    ltsg_result <-  ltsg_multi(env, mu = mu, sigl = sigl, sigr = sigr, L = L)

  }

  return(ltsg_result)


}
