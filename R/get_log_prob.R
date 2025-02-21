#' Calculate the Log posterior from a fitted xsdm model.
#'
#' @param xsdm_object
#'
#' @return A function that calculates the log of the proabilites
#'  from a point in the posterior given a fitted xsdm model.
#' @export
#'
#' @examples
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' envData <- list(bio1 = bio1_ts)
#' #Virtual species presence/absence points
#' pts <- mus_virtualis
#' if (instantiate::stan_cmdstan_exists()) {
#'  model <- xsdm(envData, occ = pts, fit = "mle")
#'  log_prob_f <- get_log_prob(model)
#' }
get_log_prob <- function(xsdm_object){
  values  <- unclass(xsdm_object)

  if(!is.null(values$stan_model)){
    mod$stan_model$log_prob
  } else {
    stop("Fit an stan model")
  }

}
