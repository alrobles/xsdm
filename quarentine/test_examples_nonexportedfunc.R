#' @examples
#' \dontrun{
#' # Bioclimatic variable time series
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio1_ts <- terra::project(bio1_ts, "EPSG:2169")
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#' check_envdata_crs(envData)
#' }
#'
#' \dontrun{
#' # Bioclimatic variable time series
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#' xsdm:::check_envdata_ext(envData)
#' }
#' \dontrun{
#' # Bioclimatic variable time series
#' data(cmcc_cm_bio1)
#' data(cmcc_cm_bio12)
#' data(cmcc_cm_pr)
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio1_ts <- terra::project(bio1_ts, "EPSG:2169")
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#' check_sequence_increment(envData)
#'}
#' @examples
#' \dontrun{
#' # Bioclimatic variable time series
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#' xsdm:::check_envdata_res(envData)
#' }
#' \dontrun{
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#' pts <- mus_virtualis
#' pts <- rbind(pts, pts)
#'
#' xsdm:::new_xsdm(envData, occ = pts) |> xsdm:::validate_xsdm()
#' }
#' @examples
#' \dontrun{
#' # Bioclimatic variable time series
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#' check_envdata_spatraster(envData)
#' }
#' @examples
#' \dontrun{
#' # Bioclimatic variable time series
#' data(cmcc_cm_bio1)
#' data(cmcc_cm_bio12)
#' data(cmcc_cm_pr)
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' pr <- terra::unwrap(cmcc_cm_pr)
#' pr <- pr[[1:20]]
#' bio12_ts <- bio12_ts[[1:29]]
#' envData <- list(bio1 = bio1_ts, bio_12 = bio12_ts)
#' xsdmTest:::check_envdata_timestep_consistency(envData)
#'}
#'#' @examples
#' \dontrun{
#' # Bioclimatic variable time series
#' data(cmcc_cm_bio1)
#' data(cmcc_cm_bio12)
#' data(cmcc_cm_pr)
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio1_ts <- terra::project(bio1_ts, "EPSG:2169")
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' pr <- terra::unwrap(cmcc_cm_pr)
#' envData <- list(bio1 = bio1_ts, pr = pr)
#' check_envdata_timestep(envData)
#'}
#' \dontrun{
#' occ <- mus_virtualis
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#' check_pts_duplicity(occ, envData)
#'}
#'#' @examples
#' \dontrun{
#' pts <- mus_virtualis
#' check_pts_haslonglat(pts)
#'}
#' @examples
#' \dontrun{
#' pts <- mus_virtualis
#' check_pts_presence_binary(pts)
#'}

#' @examples
#' \dontrun{
#' pts <- mus_virtualis
#' check_pts_presence_na(pts)
#'}
#'#' @examples
#' \dontrun{
#' pts <- mus_virtualis
#' check_pts_presence(pts)
#'}
#'
#' @examples
#' \dontrun{
#' check_sequence_increment(1:5)
#' check_sequence_increment(c(1, 4, 6, 7))
#' }
#' #' @examples
#' occ <- mus_virtualis[1:5, ]
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' envData <- list(bio1 = bio1_ts)
#' envDataArray(occ, envData)
#'
#' @examples
#'\dontrun{
#' idem("a", "b")
#' idem("x", "x")
#' # combined con Reduce can be applied in a list recursively
#' test <- list("a", "a", "a")
#' Reduce(idem, test)
#' #' test <- list("a", "a", "A")
#' Reduce(idem, test)
#'}
#' @examples
#' \dontrun{
#' bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#' bio12_ts <- terra::unwrap(cmcc_cm_bio12)
#' envData <- list(bio1 = bio1_ts, bio12 = bio1_ts)
#' zero_raster(envData)
#' }

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
