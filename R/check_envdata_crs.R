#' Check environmental data list coordinate reference system
#' Check if all elements in the env_data list have equal coords
#'
#' @param envData An list with environmental data time serires as elements.
#' @return If all the raster time serires are the same, return the crs string. If not
#' returns FALSE
#' @examples
#' \dontrun{
#' # Bioclimatic variable time series
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio1_ts <- terra::project(bio1_ts, "EPSG:2169")
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#' check_envdata_crs(envData)
#' }
check_envdata_crs <- function(envData){
  Reduce(idem, Map(terra::crs, envData))
}
