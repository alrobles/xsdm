#' Environmental Grid Array. Returns an array of environmental
#' combinations from a grid with a length out split.
#' It can be used to get the probability of detection along
#' a list of environmental time series
#'
#' @param envData A list with environmental raster time series
#' @param param.list A list of parameters. Could be null for
#' an unidimensional model (i. e. one environmental variable in the
#' env list)
#' @param lenght Number of grid splits
#'
#' @returns A data.table with probability of detection given a grid of environmental range
#' @export
#'
#' @examples
#' bio1 <- terra::unwrap(cmcc_cm_bio1)
#' bio12 <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio01 = bio1, bio12 = bio12)
#' pars <- list(
#' mu = c(3, 400),
#' sigl = c(0.5, 90),
#' sigr = c(0.5, 90),
#' L = matrix(c(1, 0, 0, 1), ncol = 2)
#' )
#' envGridLtsg(envData, pars)
#'
envGridLtsg <- function(envData, param.list, lenght = 100) {
  seqList <- function(x) seq(x[1], x[2], by = ((x[2] - x[1])/(lenght - 1)))
  envDataRange <- Map(f = function(x) seqList(range(terra::minmax(x))), envData )
  x_grid <- do.call(data.table::CJ, envDataRange)
  envGridArray <- Map(function(x) matrix(x, ncol = 1), x_grid) |>
    simplify2array()
  f <- function(env)function(mu, sigl, sigr, L){
    ltsg(env, mu, sigl, sigr, L)
  }
  if(is.null(param.list)){
    stop("Provide a valid parameter list")
  }

  f_par <- f(envGridArray)
  ltsg_val <- suppressWarnings(do.call(f_par, args = param.list))
  x_grid <- cbind(x_grid, ltsg_val)
  colnames(x_grid) <- c(names(envData), "ltsg")
  x_grid
}
