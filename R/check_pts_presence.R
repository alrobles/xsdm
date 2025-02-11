#' Check points data frame
#' @param occ An occurence species data.frame.
#' @return Logical. Is TRUE if the data.frame with
#' occurrence points has the columns longitude and
#' latitude
check_pts_presence <- function(occ){
  utils::hasName(x = occ, "presence")
}
