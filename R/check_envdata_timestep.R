#' Check environmental data list coordinate reference system
#' Check if all elements in the env_data list have equal coords
#'
#' @param envData An list with environmental data time serires as elements.
#' @return If all the raster time serires are the same, return the crs string. If not
#' returns FALSE
check_envdata_timestep <- function(envData){

  tstep <- function(raster_ts){
    tinfo <- terra::timeInfo(raster_ts)
    tinfo$step
  }
  Flag <- ifelse(Reduce(idem,  Map(tstep, envData) ) == "years", TRUE, FALSE)
  return(Flag)
}
