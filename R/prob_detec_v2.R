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
#' @export
#'
#' @examples
#' prob_detec_v2(env = -1, mu =  0, sig =  1, c =  1.1, pd = 0.8)
prob_detec_v2 <- function(env, mu, sig, c, pd){
  if(is.vector(env)){
    env = matrix(env, ncol = length(env))
  }

  prob <- ltsg_v2(env, mu, sig) |>
    .invLogit(c, pd)

  return(prob)
}
