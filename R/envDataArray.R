#' envDataArray
#' Get an array of environmental data from presence-absence points.
#' @param occ Occurence data frame. Should contain longitude and latitude columns
#' @param envData List of environmental variables time series stack.
#'
#' @return An array of M points times N time steps times P environmental variables
#' @export
#'
#' @examples
#' occ <- mus_virtualis
#' bio1_ts <- terra::unwrap(xsdm::cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(xsdm::cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio12_ts)
#' envDataArray(occ, envData)
envDataArray <- function(occ, envData){

  pts <- terra::vect(occ, geom = c("longitude", "latitude"))

  envDataArray <- Map(f = \(x){terra::extract(x, pts, cell = FALSE, ID = FALSE)}, envData)
  envDataArray <- Map(f = \(x){stats::setNames(x, paste0(names(x)[[1]], "_", 1:ncol(x)))}, envDataArray)
  envDataArray <- Map(f = as.matrix, envDataArray)
  envDataArray <- simplify2array(envDataArray)
  if(dim(envDataArray)[3] == 1){
    envDataArray <- as.matrix(envDataArray)
  }
  return(envDataArray)
}

