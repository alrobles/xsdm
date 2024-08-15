#' @title Lewontin-Cohen XSDM
#'
#' @importFrom rstan sampling
#' @importFrom methods is
#' @importFrom terra nlyr
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

  message(
    "You are running XSDM using:\n",
    "  - the Lewontin-Cohen\n",
    "  - ", length(x), " climatic variable(s) as predictors"
  )

  d <- lapply(x, \(x) terra::extract(x, p, ID = FALSE))
  # NAs need to be removed
  empty <- lapply(d, \(x) which(is.na(x), arr.ind = TRUE)[, 1])
  empty <- unique(unlist(empty))
  if (length(empty) > 0) d <- lapply(d, \(d) d[-empty, ])
  # need an array for stan
  climate <- array(NA, dim = c(nrow(d[[1]]), ncol(d[[1]]), length(d)))
  for (i in seq_along(x)) {
    climate[, , i] <- as.matrix(d[[i]])
  }

  # initial values are obtained from the climate to facilitate fitting
  R_init <- matrix(0, nrow = dim(climate)[3], ncol = dim(climate)[3])
  diag(R_init) <- 1
  init <- rep(
    list(
      list(
        mu = apply(climate, MARGIN = 3, mean),
        sigl = apply(climate, MARGIN = 3, sd),
        sigr = apply(climate, MARGIN = 3, sd),
        L = t(chol(R_init)),
        b = 3,
        c = -1,
        pd = .95
      )
    ),
    chains
  )
  if (length(x) == 1) init <- "random"  #DEV cannot make this work for uni-dimensional cases. I think the problem is that this is a vector in Stan, but is passed as a real.

  # need a list for each chains
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

  fit <- sampling(
    stanmodels$lewontin_cohen,
    data = dat,
    init = init,
    chains = chains,
    ...
  )

  return(fit)
}
