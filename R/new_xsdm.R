#' Constructor function for the class xsdm
#'
#' @param env_data A (prefered named) list with environmental
#' raster time series.
#' @param occ A data.frame
#' @param call Call this function
#' @return an object of class xsdm
#' @examples
#' \dontrun{
#' # example code
#' # Bioclimatic variable time series
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#' #Virtual species presence/absence points
#' pts <- mus_virtualis
#' new_xsdm(envData, occ = pts)
#' }

new_xsdm <- function(env_data = list(),
                     occ = data.frame(),
                     #model_spec = list(),
                     #stan_model = NULL,
                     #sampling_data = NULL,
                     #sampling_result = NULL,
                     #habitat_suitability = NULL,
                     #range_map = NULL
                     call = character()
                     ){

  if(is.null(names(x = env_data)) ){
    names(x = envData) <- paste0("e", 1:length(env_data))
  }

  xsdm <- structure(
    list(
      env_data = env_data,
      occ = occ,
      model_spec = NULL,
      stan_model = NULL,
      samplig_data = NULL,
      sampling_result = NULL,
      habitat_suitability = NULL,
      range_map = NULL,
      call = call),
    class = "xsdm"
  )
  return(xsdm)
}
