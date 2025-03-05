#' Probability of detection
#'
#' @param env Environmental time serires matrix. Rows are sites and
#' columns are yearly time steps.
#' @param mu Numeric parameter. It controls the center of the function
#' @param sigl  Numeric parameter. It controls the left shape of the bell curve
#' @param sigr Numeric parameter. It controls the right shape of the bell curve
#' @param c Numeric parameter. It controls the growth limit.
#' @param pd Numeric parameter. It controls the maximum probability
#' @param L matrix parameter. Default is NULL (i. e. univariate Lewontin Cohen model)
#'
#' @return A numeric value between 0 and 1 with the probability of detection
#' given the environmental time series matrix and the parameters
#'

prob_detec_multi <- function(env, mu, sigl, sigr, L, c, pd){

  if(!is.array(env)){
    stop("Enviromental data should be on array form")
  }

  ltsg_multi(env, mu = mu, sigl = sigl, sigr = sigr, L = L) |>
    .invLogit(c, pd)

}
