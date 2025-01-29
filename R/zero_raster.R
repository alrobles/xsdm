#' Title
#'
#' @param envData  env_data A (prefered named) list with environmental
#' raster time series.
#'
#' @return An empty raster with values of zero given
#' the environmetal data set provided as list form.
#' @examples
#' \dontrun{
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#' zero_raster(envData)
#' }

zero_raster <- function(envData){

  stopifnot("The environmental data is not a list" =
              class(envData) == "list") |>
    try()

  terra::rast(val = 0,
                crs = check_envdata_crs(envData),
                ext = check_envdata_ext(envData),
                res = check_envdata_res(envData))
  }

