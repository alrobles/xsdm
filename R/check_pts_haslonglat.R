#' Check environmental data list coordinate reference system
#' Check if all elements in the env_data list have equal coords
#'
#' @param occ An occurence data.frame.
#' @return Logical. Is TRUE if the data.frame with
#' occurrence points has the columns longitude and
#' latitude
#' @examples
#' \dontrun{
#' pts <- mus_virtualis
#' check_pts_haslonglat(pts)
#'}
check_pts_haslonglat <- function(occ){
  hasLongLat <- function(occ){
    long <- utils::hasName(x = occ, "longitude")
    lat <- utils::hasName(x = occ, "latitude")
    all(long, lat)
  }
  hasLongLat(occ)
}
