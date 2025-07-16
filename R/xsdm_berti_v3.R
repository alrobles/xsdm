#' Constructor function for the class xsdm
#'
#' @param env_data A (prefered named) list with environmental
#' raster time series.
#' @param occ A data.frame with name of species, longitude, latitude and occurrence column.
#' @param fit Logical or string. Default TRUE. Define the fittig
#' method for xsdm. Default method is sampling from the porsterior
#' using MCMC. Other possible methods are mle (Maximum likelihood estimation),
#' map (Maximum a posteriori estimation), mle.laplace (Laplace method),
#' map.laplace.
#' @param ... other arguments
#' @return an object of class xsdm
#' @export
#'
#' @examples
#'
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' envData <- list(bio1 = bio1_ts)
#' #Virtual species presence/absence points
#' pts <- mus_virtualis
#' xsdm(envData, occ = pts, fit = FALSE)
#' if (instantiate::stan_cmdstan_exists()) {
#'   xsdm(envData, occ = pts, fit = TRUE)
#' }
xsdm_berti_v3 <- function(env_data = list(),
                       occ = data.frame(),
                       fit = TRUE,
                       ...){


  #save the call for print method
  this.call <- match.call()

  xsdm_model <-  new_xsdm(env_data, occ, call = this.call)
  xsdm_model <-  validate_xsdm(xsdm_model)
  if(!fit == FALSE){
    xsdm_model <-  fit_xsdm_berti(xsdm_model, fit = fit,...)
  }

  return(xsdm_model)
}
