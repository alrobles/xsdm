#' @title Lewontin-Cohen XSDM
#' 
#' @importFrom rstan sampling
#' @importFrom methods is
#' @importFrom terra nlyr ncell xyFromCell
#' @export
#' 
#' @param x List of raster stacks. Each stack represent the timeseries 
#'  one climatic variable.
#' @param p SpatVector with species' occurrences.
#' @param chains Ingeter, number of chains to run.
#' @param ... Additional arguments for `rstan::sampling()`.
#' 
#' @return An object of class `stanfit` returned by `rstan::sampling`
#' 
lewontin_cohen <- function(x, p, chains = 4, ...) {
  stopifnot(is(x, "list"))
  stopifnot(all(sapply(x, \(x) is(x, "SpatRaster"))))
  stopifnot(all(sapply(x, nlyr) > 1))
  stopifnot(length(unique(sapply(x, nlyr))) == 1)
  if (!"occ" %in% names(p)) {
    stop("Missing 'occ' column in SpatVector.")
  }
  if (chains %% 1 != 0) {
    stop("'chains' must be an integer.")
  }
  
  # get climate at occurrences -------------
  d <- lapply(x, \(x) extract(x, p, ID = FALSE, cells = TRUE, xy = TRUE))
  # remove NAs values ---------
  empty <- lapply(d, \(x) which(is.na(x), arr.ind = TRUE)[, 1])
  empty <- unique(unlist(empty))
  if (length(empty) > 0) d <- lapply(d, \(d) d[-empty, ])
  xy <- lapply(d, \(d) d[, c("x", "y", "cell")])
  d <- lapply(d, \(d) d[, -which(colnames(d) %in% c("x", "y", "cell"))])
  
  # create climate array ------------
  climate <- array(NA, dim = c(nrow(d[[1]]), ncol(d[[1]]), length(d)))
  for (i in seq_along(x)) {
    climate[, , i] <- as.matrix(d[[i]])
  }

  # initial values for parameters -------------------
  init <- rep(
    list(
      list(
        mu = apply(climate, MARGIN = 3, mean),
        sigl = apply(climate, MARGIN = 3, sd),
        sigr = apply(climate, MARGIN = 3, sd),
        L = matrix(c(1, 0, 0, 1), byrow = TRUE, ncol = 2),
        b = 3,
        c = -1,
        pd = .95
      )
    ),
    chains
  )

  # standata -------------
  dat <- rep(
    list(
      N = length(p),
      M = ncol(climate),
      P = dim(climate)[3],
      ts = climate,
      occ = p$occ
    ), 
    chains
  )

  # sampling --------
  fit <- sampling(stanmodels$lewontin_cohen, data = dat, ...)
  
  return (fit)
}
