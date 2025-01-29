#' Check if all elements in env_data list are
#' Spat Raster
#'
#' @param envData A list of environmental data
#'
#' @return logical A flag if the elements in a env_data list
#' are not SpatRaster objects from terra package
#'
#' @examples
#' \dontrun{
#' # Bioclimatic variable time series
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#' check_envdata_spatraster(envData)
#' }
check_envdata_spatraster <- function(envData){
  all(Reduce(c, Map(class, envData) )  == "SpatRaster")
}
