#' Title
#'
#' @param xsdm_object An xsdm object
#' @param index An integer ginving the row index from the sample
#' of the posterior. Default 1
#' @param scale Logical. Should be environmental scaled?
#' This function takes the mean and standard deviation of provided ocurrence (presence/absence) points.
#' This scale was used in the fit process.
#' to weight the environmental data provided to predict
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

predict.xsdm <- function(xsdm_object, index = 1, scale = FALSE){
  values  <- unclass(xsdm_object)
  meta <- values$stan_model$metadata()
  match_lp <-  grep(pattern = "^lp", x = meta$model_params)
  params <- meta$model_params[-match_lp]
  df <- values$stan_model$draws(format = "df", variables = params)

  P <- length(values$env_data)

  if(P == 1){
    envM <- as.matrix(values$env_data[[1]])
    f <- function(env)function(mu, sigl, sigr, c, pd){
      prob_detec(env, mu, sigl, sigr, c, pd)
    }
    f_par <- f(envM)
    coords <- terra::crds(values$env_data[[1]])
    prob_detect_df <- suppressWarnings(do.call(f_par, args = df[index, params]))
    data.frame(coords, prob_detect_df) |>
      terra::rast()
  } else {

    envM <- xsdm::envDataArray(values$env_data)


    if(scale == TRUE){
      env_occ <- xsdm::envDataArray(values$env_data, occ = values$occ)
      for(i in 1:P){
        envM[ , , i] <- (envM[ , , i] - mean(env_occ[ , , i]))/stats::sd(env_occ[ , , i])
      }
    }

    coords <- terra::crds(values$env_data[[1]])

    # to do
    #needs to pass this to an independent function

    mu <-   df[index, grep("mu", params)]   |> suppressWarnings() |> unlist()
    sigl <- df[index, grep("sigl", params)] |> suppressWarnings() |> unlist()
    sigr <- df[index, grep("sigr", params)] |> suppressWarnings() |> unlist()
    L <-    df[index, grep("L", params)]    |> suppressWarnings() |> unlist() |>  matrix(ncol = P)
    c_param <- df[index, grep("c", params)] |> suppressWarnings() |> unlist()
    pd <-    df[index, grep("pd", params)]  |> suppressWarnings() |> unlist()

    prob_detect_df <- prob_detec(envM, mu, sigl, sigr, c_param, pd = pd, L)

    data.frame(coords, prob_detect_df)|>
      terra::rast()

  }
}
