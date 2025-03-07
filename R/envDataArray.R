#' envDataArray
#' Get an array of environmental data from presence-absence points.
#' @param occ Occurence data frame. Should contain longitude and latitude columns
#' @param envData List of environmental variables time series stack.
#'
#' @return An array of M points times N time steps times P environmental variables
#' @export
#'
#' @examples
#' occ <- mus_virtualis[1:5, ]
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' envData <- list(bio1 = bio1_ts)
#' envDataArray(occ, envData)
envDataArray <- function(envData, occ = NULL){

  if(is.null(occ)){

    pts <- terra::vect(occ, geom = c("longitude", "latitude"))

    if(length(envData) == 1){
      envDataArray <- terra::extract(envData[[1]], pts, cell = FALSE, ID = FALSE)
      envDataArray <- as.matrix(envDataArray)
    } else {
      envDataArray <- Map(f = \(x){terra::extract(x, pts, cell = FALSE, ID = FALSE)}, envData)
      envDataArray <- Map(f = \(x){stats::setNames(x, paste0(names(x)[[1]], "_", 1:ncol(x)))}, envDataArray)
      envDataArray <- Map(f = as.matrix, envDataArray)
      envDataArray <- simplify2array(envDataArray)
    }

  } else {

    if(length(envData) == 1){
      envDataArray <- terra::as.matrix(envData[[1]])
      envDataArray <- as.matrix(envDataArray)
    } else{
      envDataArray <- Map(f = \(x){terra::as.matrix(x)}, envData)
      envDataArray <- Map(f = \(x){stats::setNames(x, paste0(names(x)[[1]], "_", 1:ncol(x)))}, envDataArray)
      envDataArray <- Map(f = as.matrix, envDataArray)
      envDataArray <- simplify2array(envDataArray)
    }


  }

  return(envDataArray)
}

