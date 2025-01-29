#' validate xsdm_object constructed via xsdm_plus function
#'
#' @param xsdm_object An xsdm object constructed with new_xsdm function
#'
#' @return A validated xsdm_object
#' @examples
#' \dontrun{
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#' pts <- mus_virtualis
#' pts <- rbind(pts, pts)
#'
#' xsdm:::new_xsdm(envData, occ = pts) |> xsdm:::validate_xsdm()
#' }

validate_xsdm <- function(xsdm_object){
  values  <- unclass(xsdm_object)
  stopifnot(class(values$env_data) == "list")

  stopifnot("All elements in env_data should be
            raster time series" =
              check_envdata_spatraster(values$env_data) == TRUE) |>
    try()

  stopifnot("All elements in env_data should be
  projected with the same coordiante reference system" =
              check_envdata_crs(values$env_data) != FALSE ) |>
    try()

  stopifnot("All elements in env_data should have time assigned" =
              check_envdata_hastime(values$env_data) != FALSE  ) |>
    try()

  consistency <- check_envdata_timestep_consistency(values$env_data)
  consistency_msg <- consistency$msg

  warnifnot("All elements in env_data should be
            year time series. Check reference." =
              check_envdata_timestep(values$env_data) != FALSE ) |>
    tryCatch()

  stopifnot(consistency_msg = consistency$flag == TRUE)  |>
    tryCatch(finally = print(consistency_msg))

  stopifnot("The ocurrence data.frame doesn't have longitude and/or latitude columns" =
              check_pts_haslonglat(values$occ) == TRUE  ) |>
    try()

  stopifnot("The ocurrence data.frame doesn't have presence column" =
              check_pts_presence(values$occ) == TRUE  ) |>
    try()

  stopifnot("The presence column in ocurrence data.frame is not binary (i. e. 1 and 0 entries)" =
              check_pts_presence_binary(values$occ) == TRUE  ) |>
    try()

  stopifnot("The presence column in ocurrence data.frame has NA entries" =
              check_pts_presence_na(values$occ) == TRUE  ) |>
    try()

  stopifnot("The point points are duplicated. Check clean_data" =
              xsdm:::check_pts_duplicity(values$occ, values$envData) == FALSE) |>
    try()


  xsdm_object
}
