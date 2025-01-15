#' Constructor function for the class xsdm
#'
#' @param env_data A (prefered named) list with environmental
#' raster time series.
#' @param occ A data.frame
#' @param ... other arguments
#' @return an object of class xsdm
#' @export
#'
#' @examples
#'
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio12_ts)
#' #Virtual species presence/absence points
#' pts <- mus_virtualis
#' xsdm(envData, occ = pts)
xsdm <- function(env_data = list(),
                 occ = data.frame(),
                 ...){

  #save the call for print method
  this.call <- match.call()

  xsdm_model <-  new_xsdm(env_data, occ, call = this.call)
  xsdm_model <-  validate_xsdm(xsdm_model)

  return(xsdm_model)

}
