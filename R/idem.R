#' Check if two objects are the same
#'
#' @param x An R object to test
#' @param y An R object to test
#'
#' @return If the objects are the same, returns the object. If
#' the objects are different returns FALSE
#'
#'
#' @examples
#'\dontrun{
#' idem("a", "b")
#' idem("x", "x")
#' # combined con Reduce can be applied in a list recursively
#' test <- list("a", "a", "a")
#' Reduce(idem, test)
#' #' test <- list("a", "a", "A")
#' Reduce(idem, test)
#'}
idem <- function(x,y){
  if (identical(x, y)){
    x
  } else{
    FALSE
  }
}
