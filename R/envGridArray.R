#' Environmental Grid Array. Returns an array of environmental
#' combinations from a grid with a length out split.
#' It can be used to get the probability of detection along
#' a list of environmental time series
#'
#' @param envData A list with environmental raster time series
#' @param lenght Number of grid splits
#'
#' @returns An array with environmental combinations from a grid
#' @export
#'
#' @examples
#' bio1 <- terra::unwrap(cmcc_cm_bio1)
#' bio12 <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio01 = bio1, bio12 = bio12)
#' envGridArray(envData)
envGridArray <- function(envData, lenght = 100) {
  seqList <- function(x) seq(x[1], x[2], by = ((x[2] - x[1])/(lenght - 1)))
  envDataRange <- Map(f = function(x) seqList(range(terra::minmax(x))), envData )
  x_grid <- do.call(data.table::CJ, envDataRange)
  envGridArray <- Map(function(x) matrix(x, ncol = 1), x_grid) |>
    simplify2array()
  envGridArray
}
