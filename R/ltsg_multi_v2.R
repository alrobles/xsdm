#' Multivariate long term stochastic growth function for a
#' Lewontin Cohen demographic environmental model
#'
#' @param env Matrix Environmental time series (columns) per sites (rows)
#' @param mu numeric parameter.
#' @param sigl numeric parameter.
#' @param sigr numeric parameter
#' @param L matrix parameter
ltsg_multi_v2 <- function(env, mu, sig){
  if(!is.array(env)){
    stop("Enviromental data should be on array form")
  }

  output <- matrix(nrow = dim(env)[1], ncol = dim(env)[2] )

  for(i in 1:ncol(env)){
    W <- t( (t(env[ ,i, ]) - mu)/sig )

    #U <- t(solve(L, W))
    #U <- .response_multi(x = W, sigl = sigl, sigr = sigr)
    #R <- t(solve(L, t(U)))
    output[ ,i] <- .response_halfsquare(W)
  }
  output |>
    .meanRow()

}

