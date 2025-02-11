#' Title
#'
#' @param envData  env_data A (prefered named) list with environmental
#' raster time series.
#'
#' @return An empty raster with values of zero given
#' the environmetal data set provided as list form.
zero_raster <- function(envData){

  terra::rast(val = 0,
                crs = check_envdata_crs(envData),
                ext = check_envdata_ext(envData),
                res = check_envdata_res(envData))
  }

