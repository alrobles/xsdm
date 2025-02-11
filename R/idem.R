#' Check if two objects are the same
#'
#' @param x An R object to test
#' @param y An R object to test
#'
#' @return If the objects are the same, returns the object. If
#' the objects are different returns FALSE
idem <- function(x,y){
  if (identical(x, y)){
    x
  } else{
    FALSE
  }
}
