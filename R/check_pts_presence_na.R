#' Check points data frame
#' @param occ An occurence species data.frame.
#' @return Logical. Is TRUE if the data.frame with
#' occurrence points has the columns longitude and
#' latitude
check_pts_presence_na <- function(occ){
  !any(is.na(occ[["presence"]]))
}
