#' Title
#'
#' @param object An xsdm object
#' @param index An integer ginving the row index from the sample
#' of the posterior. Default 1
#' @param scale Logical. Should be environmental scaled?
#' This function takes the mean and standard deviation of provided ocurrence (presence/absence) points.
#' This scale was used in the fit process.
#' to weight the environmental data provided to predict
#' @param ... pass arguments
#' @return A raster map
#' @method predict xsdm
#' @aliases predict.xsdm
#'
#' @examples
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio12_ts)
#' pts <- mus_virtualis
#' if (instantiate::stan_cmdstan_exists()) {
#' mod <- xsdm(envData, occ = pts, fit = TRUE, iter_warmup = 1000, iter_sampling = 1000, parallel_chains = 4, threads_per_chain = 5, recompile = TRUE )
#' model_draws <- xsdm:::pointwise_likelihood(mod)
#' loo::loo(model_draws)
#' }

pointwise_likelihood <- function(object, scale = FALSE, ...){
  values  <- unclass(object)
  ts_data <- envDataArray(occ = values$occ,
                          values$env_data)
  meta <- values$stan_model$metadata()
  match_lp <-  grep(pattern = "^lp", x = meta$model_params)
  params <- meta$model_params[-match_lp]
  df <- values$stan_model$draws(format = "df", variables = params)
  df_ALL <- values$stan_model$draws(format = "df")
  hidden_variables <- df_ALL[, c(".chain", ".iteration", ".draw") ]


  P <- length(values$env_data)

  log_lik_names <- paste0("log_lik", "[", 1:nrow(ts_data), "]")

  # if(P == 1){

  get_df_lik_row <- function(index, data = df){
    mu <-   data[index, grep("mu", params)]   |> suppressWarnings() |> unlist()
    sigl <- data[index, grep("sigl", params)] |> suppressWarnings() |> unlist()
    sigr <- data[index, grep("sigr", params)] |> suppressWarnings() |> unlist()
    c_param <- data[index, grep("c", params)] |> suppressWarnings() |> unlist()
    pd <-    data[index, grep("pd", params)]  |> suppressWarnings() |> unlist()

    if(P == 1){
      prob_detect <- prob_detec(env = ts_data, mu = mu, sigl = sigl, sigr = sigr, c = c_param, pd = pd)
      loglik <- bernoulli_lpmf(prob_detect, values$occ$presence)

    } else {
      L <-  data[index, grep("L", params)] |> suppressWarnings() |> unlist() |>  matrix(ncol = P)

      prob_detect <- prob_detec(env = ts_data, mu = mu, sigl = sigl, sigr = sigr, c = c_param, pd = pd, L = L)
      loglik <- bernoulli_lpmf(prob_detect, values$occ$presence)

    }

    loglik <- loglik |>
      t() |>
      as.data.frame()


    colnames(loglik) <- log_lik_names
    loglik

  }




  df_log_lik <- Reduce(rbind, Map(get_df_lik_row, 1:nrow(df)) )
  #df_log_lik <- cbind(df_ALL, df_log_lik)
  #df_log_lik <- df_log_lik[ , c("lp__", params, log_lik_names, ".chain", ".iteration", ".draw" )]
  #df_log_lik <- cmdstanr::as_draws( df_log_lik)

  return(df_log_lik)
}



















