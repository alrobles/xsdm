#' Check if all elements in env_data list are
#' Spat Raster
#'
#' @param envData A list of environmental data
#'
#' @return logical A flag if the elements in a env_data list
#' are not SpatRaster objects from terra package
check_envdata_spatraster <- function(envData){
  all(Reduce(c, Map(class, envData) )  == "SpatRaster")
}
