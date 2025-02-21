#' Probability mass fucntion
#'
#' @param prob A value between 0 to 1 of probability of detection
#' @param occ A logical value (either 0 or 1) of observed detection
#' @param lp_sum Logical. If true, returns the total sum of the
#' log likelihood
#'
#' @return Numeric. Bernoulli log probability mass function
#' @export
#'
#' @examples
#' prob <- prob_detec(env = matrix(c(-1, 0, -0.1, 0.9), ncol = 1), mu =  0, sigl =  1, sigr =  0.9, c =  -0.8, pd = 0.9)
#' bernoulli_lpmf(prob, occ = c(0, 1, 1, 0))
bernoulli_lpmf <- function(prob, occ, lp_sum = FALSE){
  if(!lp_sum){
    .bernoulli_lpmf(prob, occ)
  } else {
    .bernoulli_lpmf(prob, occ) |> .parallelVectorSum()
  }

}

