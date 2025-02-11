#' Constructor function for the class xsdm
#'
#' @param env_data A (prefered named) list with environmental
#' raster time series.
#' @param occ A data.frame
#' @param stan_model A stan fitted object slot. Default is NULL
#' @param call Call this function
new_xsdm <- function(env_data = list(),
                     occ = data.frame(),
                     #model_spec = list(),
                     stan_model = NULL,
                     #sampling_data = NULL,
                     #sampling_result = NULL,
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
      stan_model = stan_model,
      samplig_data = NULL,
      sampling_result = NULL,
      call = call),
    class = "xsdm"
  )
  return(xsdm)
}
