#' Check the duplicity of points. Thecks if there are
#' at least two or more points in a same cell for a
#' given raster set.
#'
#' @param occ A SpacVector of points geometries. It could had
#' builded with the vect method for the data.frame signatiure
#' @param envData A list of environmental time series to test
#' the duplicity
#'
#' @return Logical It is true if there is at least
#' two (or more) points in the same cell
check_pts_duplicity <- function(occ, envData){
  pts <- terra::vect(occ, geom = c("longitude", "latitude"))
  r <- zero_raster(envData)
  extraction <- terra::extract(r, pts, cell = TRUE)
  any(table(extraction$cell) != 1)
}
