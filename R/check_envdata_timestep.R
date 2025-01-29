#' Check environmental data list coordinate reference system
#' Check if all elements in the env_data list have equal coords
#'
#' @param envData An list with environmental data time serires as elements.
#' @return If all the raster time serires are the same, return the crs string. If not
#' returns FALSE
#' @examples
#' \dontrun{
#' # Bioclimatic variable time series
#' data(cmcc_cm_bio1)
#' data(cmcc_cm_bio12)
#' data(cmcc_cm_pr)
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio1_ts <- terra::project(bio1_ts, "EPSG:2169")
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' pr <- terra::unwrap(cmcc_cm_pr)
#' envData <- list(bio1 = bio1_ts, pr = pr)
#' check_envdata_timestep(envData)
#'}
check_envdata_timestep <- function(envData){

  tstep <- function(raster_ts){
    tinfo <- terra::timeInfo(raster_ts)
    tinfo$step
  }
  Flag <- ifelse(Reduce(idem,  Map(tstep, envData) ) == "years", TRUE, FALSE)
  return(Flag)
}
