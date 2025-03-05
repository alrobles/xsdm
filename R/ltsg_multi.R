#' Multivariate long term stochastic growth function for a
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
#' bio1 <- terra::unwrap(xsdm::cmcc_cm_bio1)
#' bio12 <- terra::unwrap(xsdm::cmcc_cm_bio12)
#' bio12 <- bio12/100 # rescaled bio12 to be in units with same order of magnitude
#' envData <- xsdm::envDataArray( xsdm::mus_virtualis, list(bio1, bio12))
#' L <- matrix(c(1, 0, 0, 1), ncol = 2) #lower triangular matrix
#' ltsg_multi(env = envData, mu = c(1, 3),   sigl = c(0.5,  0.5), sigr = c(0.5,  0.5),   L = L  )
ltsg_multi <- function(env, mu, sigl, sigr, L){
  if(!is.array(env)){
    stop("Enviromental data should be on array form")
  }

  output <- matrix(nrow = dim(env)[1], ncol = dim(env)[2] )

  for(i in 1:ncol(env)){
    W <- t(env[ ,i, ]) - mu
    U <- t(solve(L, W))
    R <- .response_multi(x = U, sigl = sigl, sigr = sigr)
    output[ ,i] <- R
  }
  output |>
    .meanRow()

}

