#' Check sequence. Function to check if a vector is
#' a sequence with same increment
#'
#' @param seq A vector to test if is a constant sequence
#'
#' @return If the increment in the sequence is not the same
#' returns FALSE. Otherwise returns the increment step
check_sequence_increment <-  function(seq){
  seqdif <- seq[-1] - seq[-length(seq)]
  Reduce(idem, seqdif)
}

