#' Virtual species
#'
#' @param env_data A list with environmental time series raster object
#' @param param.list A list of parameters. Could be null for
#' an unidimensional model (i. e. one environmental variable in the
#' env list)
#'
#' @return A raster with the probability of detection of the
#' virtual species
#' @export
#'
#' @examples

#' if (instantiate::stan_cmdstan_exists()) {
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' envData <- list(bio1 = bio1_ts)
#' pars <- list(mu = 4.38, sigl = 1.24, sigr = 1.05, c = -8.39, pd = 0.61)
#' vsp( envData, param.list =  pars)
#' }
vsp <- function(env_data, param.list = NULL) {


  if(!is.null(param.list)){
    checkList_uni <-   identical(names(param.list), c("mu", "sigl", "sigr", "c", "pd"))
    checkList_multi <- identical(names(param.list), c("mu", "sigl", "sigr", "c", "pd", "L"))
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
    f <- function(env)function(mu, sigl, sigr, c, pd, L){
      prob_detec(env, mu, sigl, sigr, c, pd, L)
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
