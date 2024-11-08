#' @title XSDM Species Distribution Modeling
#'
#' @importFrom methods is
#' @importFrom terra nlyr
#' @importFrom stats sd
#' @export
#'
#' @param x List of raster stacks. Each stack represent the timeseries
#'  one climatic variable.
#' @param p SpatVector with species' occurrences.
#' @param model String, for now only `lewontin-cohen`.
#' @param ... Additional arguments for `rstan::sampling()`.
#'
#' @return An object of class `stanfit` returned by `rstan::sampling`
#'
xsdm <- function(x, p, model, ...) {
  stopifnot(is(x, "list"))
  stopifnot(is(p, "SpatVector"))
  stopifnot(is(model, "character"))
  stopifnot(all(sapply(x, \(x) is(x, "SpatRaster"))))
  stopifnot(all(sapply(x, nlyr) > 1))
  stopifnot(length(unique(sapply(x, nlyr))) == 1)
  if (!"occ" %in% names(p)) {
    stop("Missing 'occ' column in SpatVector.")
  }

  model_choices <- c("lewontin-cohen")
  if (!model %in% model_choices) { 
    stop(
      "The model specified is not available. Current options are: ", 
      paste(model_choices, collapse = ", ")
    )
  }

  chains <- ifelse (
    !"chains" %in% ...names(),
    4L,  # default chains = 4
    ...elt(which(...names() == "chains"))
  )

  if (tolower(model) == "lewontin-cohen") {
    demographic_model <- "lewontin_cohen"
    demographic_model_mssg <- "Lewontin-Cohen"
  }
  message(
    "You are running XSDM using:\n",
    "  - ", demographic_model_mssg, "\n",
    "  - ", length(x), " climatic variable(s) as predictors\n",
    "  - ", chains, " chains"
  )

  # dry-run if passed an additional par `dry = TRUE`.
  # As this is for development purposes only, I made this an 'hidden'
  # par to be passed within the dots argument.
  if ("dry" %in% ...names() && ...elt(which(...names() == "dry")) == TRUE) {
    message("This was a dry run: exiting...")
    return(NULL)
  }

  # preprocessing of data for `sampling()`
  # from stack to matrix timeseries
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
  R_initial <- matrix(0, nrow = dim(climate)[3], ncol = dim(climate)[3])
  diag(R_initial) <- 1
  initial <- rep(
    list(
      list(
        mu = apply(climate, MARGIN = 3, mean),
        sigl = apply(climate, MARGIN = 3, sd),
        sigr = apply(climate, MARGIN = 3, sd),
        L = t(chol(R_initial)),  # Cholesky factor with no correlation
        c = -5,
        pd = .90
      )
    ),
    chains
  )

  # need a list for each chains
  dat <- list(
    N = length(p),
    M = ncol(climate),
    P = dim(climate)[3],
    ts = climate,
    occ = p$occ
  )
  
  # ISSUE - there is probably a better solution to the following nested 'if'
  if (demographic_model == "lewontin_cohen") {
    if (length(x) == 1) {  # univariate model is standalone
      dat$ts <- dat$ts[, , 1]  # needed for Stan to initialialize it properly
      fit <- .lewontin_cohen_univariate(dat, initial, chains, ...)
    } else {
      fit <- .lewontin_cohen(dat, initial, chains, ...)
    }
  }

  return(fit)
}
