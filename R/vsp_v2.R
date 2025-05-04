#' Virtual species
#'
#' @param env_data A list with environmental time series raster object
#' @param param.list A list of parameters. Could be null for
#' an unidimensional model (i. e. one environmental variable in the
#' env list)
#'
#' @return A raster with the probability of detectio of the
#' virtual species
#' @export
#'
#' @examples

#' if (instantiate::stan_cmdstan_exists()) {
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' bio12_ts <- bio12_ts/100
#' envData <- list(bio1 = bio1_ts, bio12 = bio12_ts)
#' pars <- list(mu = 4.38, sig = 1.24, c = -8.39, pd = 0.9)
#' vsp_v2(envData, param.list =  pars)
#' }
vsp_v2 <- function(env_data, param.list = NULL) {


  if(!is.null(param.list)){
    checkList_uni <-   identical(names(param.list), c("mu", "sigl", "sigr", "c", "pd"))
    checkList_multi <- identical(names(param.list), c("mu", "sig", "c", "pd"))
    checkList <- any(c(checkList_uni, checkList_multi))

    if(!checkList){
      stop("Check the parameter names")
    }
  }
  if(length(env_data) == 1){
    envM <- as.matrix(env_data[[1]])

    f <- function(env)function(mu, sigl, sigr, c, pd){
      prob_detec(env, mu, sigl, sigr, c, pd)
    }
    if(is.null(param.list)){
      param.list = list(mu = mean(envM),
                        sigl = stats::sd(envM),
                        sigr = stats::sd(envM),
                        c = -1,
                        pd = 1)
    }
  } else {
    envM <- envDataArray(env_data)
    f <- function(env)function(mu, sig, c, pd){
      prob_detec_v2(env, mu, sig, c, pd)
    }
    if(is.null(param.list)){
      stop("Provide a valid parameter list")
    }
  }

  f_par <- f(envM)

  coords <- terra::crds(env_data[[1]])
  crs_val <- terra::crs(env_data[[1]])
  probs <- suppressWarnings(do.call(f_par, args = param.list))
  data.frame(coords, probs)|>
    terra::rast(crs = crs_val)

  #else (stop("Environmental data should be just for one variable"))
}
