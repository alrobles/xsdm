#' Title
#'
#' @param xsdm_object An xsdm object
#' @param index An integer ginving the row index from the sample
#' of the posterior. Default 1
#'
#' @return A raster map
#' @method predict xsdm
#' @aliases predict.xsdm
#' @export
#'
#' @examples
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' envData <- list(bio1 = bio1_ts)
#' pts <- mus_virtualis
#' if (instantiate::stan_cmdstan_exists()) {
#' mod <- xsdm(envData, occ = pts, fit = "map" )
#' predict(mod)
#' }

predict.xsdm <- function(xsdm_object, index = 1){
  values  <- unclass(xsdm_object)
  meta <- values$stan_model$metadata()
  match_lp <-  grep(pattern = "^lp", x = meta$model_params)
  params <- meta$model_params[-match_lp]
  df <- values$stan_model$draws(format = "df", variables = params)

  if(length(values$env_data) == 1){
    envM <- as.matrix(values$env_data[[1]])
    f <- function(env)function(mu, sigl, sigr, c, pd){
      prob_detec(env, mu, sigl, sigr, c, pd)
    }
    f_par <- f(envM)
    coords <- terra::crds(values$env_data[[1]])
    prob_detect <- suppressWarnings(do.call(f_par, args = df[index, params]))
    data.frame(coords, prob_detect)|>
      terra::rast()
  }
}
