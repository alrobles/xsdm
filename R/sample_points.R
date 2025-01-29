#' Sample points function from an environmental time series raster
#' list. Simple function that return random points from the
#' extension of a set of enrionmental time series raster.
#'
#' @param envData list. A list of environmental time series raster
#' @param n numeric. The number of points of the required points
#' @param return.data.frame Logical if is TRUE (default) return a data.frame with longitude
#' and latitude of the points, if FALSE return an object of class
#' SpatVect and points geometries instead.
#' @return Either a data.frame or a SpatVect of points objects
#' @export
#'
#' @examples
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#  sample_points(envData)
sample_points <- function(envData, n = 1e5, return.data.frame = TRUE){
  r <- zero_raster(envData)
  if(return.data.frame){

    smp <- terra::spatSample(terra::ext(r),
                             size = n ,
                             lonlat = TRUE,
                             as.points = FALSE)
    smp <- base::as.data.frame(smp)
    names(smp) <- c("longitude", "latitude")
    #smp <- smp[c("longitude", "latitude")]
    return(smp)


  } else {
    smp <- terra::spatSample(terra::ext(r),
                             size = n ,
                             lonlat = TRUE,
                             as.points = TRUE)
    return(smp)
  }
}


