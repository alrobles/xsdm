#' Check sequence. Function to check if a vector is
#' a sequence with same increment
#'
#' @param seq A vector to test if is a constant sequence
#'
#' @return If the increment in the sequence is not the same
#' returns FALSE. Otherwise returns the increment step
#'
#' @examples
#' \dontrun{
#' check_sequence_increment(1:5)
#' check_sequence_increment(c(1, 4, 6, 7))
#' }
check_sequence_increment <-  function(seq){
  seqdif <- seq[-1] - seq[-length(seq)]
  Reduce(idem, seqdif)
}

