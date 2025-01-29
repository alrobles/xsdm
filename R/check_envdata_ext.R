#' Check environmental data list extent
#' Check if all elements in the env_data list have equal extent
#'
#' @param envData An list with environmental data time serires as elements.
#' @return If all the raster time serires are the same, return the crs string. If not
#' returns FALSE
#' @examples
#' \dontrun{
#' # Bioclimatic variable time series
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#' xsdm:::check_envdata_ext(envData)
#' }
check_envdata_ext <- function(envData){
  ext_vect <- function(r_env){
    ex <- terra::ext(r_env)
    ex@pntr$vector
  }

  Reduce(idem, Map(ext_vect, envData) )
}
