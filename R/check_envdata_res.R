#' Check environmental data list resolution
#' Check if all elements in the env_data list have equal resolution
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
#' check_envdata_res(envData)
#' }
check_envdata_res <- function(envData){
  Reduce(idem, Map(terra::res, envData) )
}
