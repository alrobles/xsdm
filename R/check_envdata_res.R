#' Check environmental data list resolution
#' Check if all elements in the env_data list have equal resolution
#'
#' @param envData An list with environmental data time serires as elements.
#' @return If all the raster time serires are the same, return the crs string. If not
#' returns FALSE
check_envdata_res <- function(envData){
  Reduce(idem, Map(terra::res, envData) )
}
