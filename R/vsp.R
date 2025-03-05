#' Virtual species
#'
#' @param env A list with environmental time series raster object
#' @param param.list A list of parameters
#'
#' @return \code{NULL}
#' @export
#'
#' @examples

#' if (instantiate::stan_cmdstan_exists()) {
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' envData <- list(bio1 = bio1_ts)
#' pars <- list(mu = 4.38, sigl = 1.24, sigr = 1.05, c = -8.39, pd = 0.61)
#' vsp(envData, param.list =  pars) |> terra::plot()
#' }
vsp.xsdm = function(env, param.list = NULL) {
  #values  <- unclass(xsdm_object)

  if(!is.null(param.list)){
    checkList <- identical(names(param.list), c("mu", "sigl", "sigr", "c", "pd", "L"))
    if(!checkList){
      stop("Check the parameter names")
    }
  }

  if(length(env_data) == 1){
    envM <- as.matrix(values$env_data[[1]])

    #Assign the parameters given the environment
    #Later this will be done with another control function
    # to pass arguments to priors in LC model

    if(is.null(param.list)){
      param.list = list(mu = mean(envM),
                        sigl = stats::sd(envM),
                        sigr = stats::sd(envM),
                        c = -1,
                        pd = 1
      )
    }
    #
    f <- function(env)function(mu, sigl, sigr, c, pd){
      prob_detec(env, mu, sigl, sigr, c, pd)
    }
    f_par <- f(envM)

    coords <- terra::crds(values$env_data[[1]])
    probs <- suppressWarnings(do.call(f_par, args = param.list))
    data.frame(coords, probs)|>
      terra::rast(crs = terra::crs(values$env_data[[1]]))

  } else (stop("Environmental data should be just for one variable"))
}
