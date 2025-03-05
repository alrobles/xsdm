#' Probability of detection
#'
#' @param env Environmental time serires matrix. Rows are sites and
#' columns are yearly time steps.
#' @param mu Numeric parameter. It controls the center of the function
#' @param sigl  Numeric parameter. It controls the left shape of the bell curve
#' @param sigr Numeric parameter. It controls the right shape of the bell curve
#' @param c Numeric parameter. It controls the growth limit.
#' @param pd Numeric parameter. It controls the maximum probability
#'
#' @return A numeric value between 0 and 1 with the probability of detection
#' given the environmental time series matrix and the parameters
#'
prob_detec_uni <- function(env, mu, sigl, sigr, c, pd){
  if(is.vector(env)){
    env = matrix(env, ncol = length(env))
  }
  ltsg(env, mu, sigl, sigr) |>
    .invLogit(c, pd)
}
