library(stringr)
library(terra)
###create shape to crop
shp <- vect("C:/Documents and Settings/alrob/Downloads/CO_square.kml")
shp_buffer <- terra::buffer(shp, 1e3*50)
e <- round(ext(shp_buffer))
shp_example <- vect(e)
terra::crs(shp_example)  <- terra::crs(shp)
#terra::writeVector(shp_example, "data-raw/shp_example.shp")

pathToFiles <- "C:/Documents and Settings/alrob/Documents/chelsaAnalysis/data/USA"
chelsaFiles <- list.files(pathToFiles, pattern = "historical")




objName_list <- purrr::map_chr(chelsaFiles, function(x){
  filename <- file.path(pathToFiles, x)
  r <- terra::rast(filename)
  r_crop <- crop(r, e)
  outputFile <- file.path("inst/exdata", x)
  #writeCDF(r_crop, outputFile, overwrite  = TRUE)
  v <- str_extract(x, pattern = "tasmin|tasmax|tas|pr")
  m <- str_extract(x, pattern = "MIROC5|ACCESS1-3|CESM1-BGC|CMCC-CM")
  objName <- str_glue("{m}_{v}")
  objName <- janitor::make_clean_names(objName)
  assign(objName,
         r_crop,
         envir = .GlobalEnv)
  external_env <- new.env()
  assign(objName,
         r_crop,
         envir = external_env)

  #save(external_env, file = file.path("data", objName), compress = "xz")
  objName
})

miroc_objects <- str_subset(objName_list, pattern = "miroc5")

miroc5_bio12 <- purrr::map(unique(lubridate::year(terra::time(miroc5_pr))),
                           function(x){
  r <- fastBioClim::bio_12(miroc5_pr[[r_years == x]])
  terra::time(r, tstep="years") <- x
  terra::varnames(r) <- "bio12"
  names(r) <- "bio12"
  r}) %>%
  purrr:::reduce(c)
r_years <- lubridate::year(terra::time(miroc5_tas))
miroc5_bio1 <- purrr::map(unique(r_years),
                           function(x){
                             r <- fastBioClim::bio_1(miroc5_tas[[r_years == x]])
                             terra::time(r, tstep = "years") <- x
                             terra::varnames(r) <- "bio01"
                             names(r) <- "bio01"
                             r}) %>%
  purrr:::reduce(c)

miroc5_bio1 <- miroc5_bio1[[1:30]]
miroc5_bio12 <- miroc5_bio12[[1:30]]

###

access1_3_bio12 <- purrr::map(unique(lubridate::year(terra::time(access1_3_pr))),
                           function(x){
                             r <- fastBioClim::bio_12(access1_3_pr[[r_years == x]])
                             terra::time(r, tstep="years") <- x
                             terra::varnames(r) <- "bio12"
                             names(r) <- "bio12"
                             r}) %>%
  purrr:::reduce(c)
r_years <- lubridate::year(terra::time(access1_3_tas))
access1_3_bio1 <- purrr::map(unique(r_years),
                          function(x){
                            r <- fastBioClim::bio_1(access1_3_tas[[r_years == x]])
                            terra::time(r, tstep = "years") <- x
                            terra::varnames(r) <- "bio01"
                            names(r) <- "bio01"
                            r}) %>%
  purrr:::reduce(c)

access1_3_bio1 <- access1_3_bio1[[1:30]]
access1_3_bio12 <- access1_3_bio12[[1:30]]

###


cesm1_bgc_bio12 <- purrr::map(unique(lubridate::year(terra::time(cesm1_bgc_pr))),
                           function(x){
                             r <- fastBioClim::bio_12(cesm1_bgc_pr[[r_years == x]])
                             terra::time(r, tstep="years") <- x
                             terra::varnames(r) <- "bio12"
                             names(r) <- "bio12"
                             r}) %>%
  purrr:::reduce(c)
r_years <- lubridate::year(terra::time(cesm1_bgc_tas))
cesm1_bgc_bio1 <- purrr::map(unique(r_years),
                          function(x){
                            r <- fastBioClim::bio_1(cesm1_bgc_tas[[r_years == x]])
                            terra::time(r, tstep = "years") <- x
                            terra::varnames(r) <- "bio01"
                            names(r) <- "bio01"
                            r}) %>%
  purrr:::reduce(c)

cesm1_bgc_bio1 <- cesm1_bgc_bio1[[1:30]]
cesm1_bgc_bio12 <- cesm1_bgc_bio12[[1:30]]

###

cmcc_cm_bio1
cmcc_cm_bio12
cmcc_cm_bio2 <- purrr::map(unique(lubridate::year(terra::time(cmcc_cm_pr))),
                            function(x){
                              r <- fastBioClim::bio_2(tasmax = cmcc_cm_tasmax[[r_years == x]],
                                                      tasmin = cmcc_cm_tasmin[[r_years == x]])
                              terra::time(r, tstep="years") <- x
                              terra::varnames(r) <- "bio02"
                              names(r) <- "bio02"
                              r}) %>%
  purrr:::reduce(c)

cmcc_cm_bio4 <- purrr::map(unique(lubridate::year(terra::time(cmcc_cm_pr))),
                           function(x){
                             r <- fastBioClim::bio_4(tas = cmcc_cm_tas[[r_years == x]])
                             terra::time(r, tstep="years") <- x
                             terra::varnames(r) <- "bio04"
                             names(r) <- "bio04"
                             r}) %>%
  purrr:::reduce(c)

cmcc_cm_bio5 <- purrr::map(unique(lubridate::year(terra::time(cmcc_cm_pr))),
                           function(x){
                             r <- fastBioClim::bio_5(tasmax = cmcc_cm_tasmax[[r_years == x]])
                             terra::time(r, tstep="years") <- x
                             terra::varnames(r) <- "bio05"
                             names(r) <- "bio05"
                             r}) %>%
  purrr:::reduce(c)

cmcc_cm_bio6 <- purrr::map(unique(lubridate::year(terra::time(cmcc_cm_pr))),
                           function(x){
                             r <- fastBioClim::bio_6(tasmin = cmcc_cm_tasmin[[r_years == x]])
                             terra::time(r, tstep="years") <- x
                             terra::varnames(r) <- "bio06"
                             names(r) <- "bio06"
                             r}) %>%
  purrr:::reduce(c)



cmcc_cm_bio2 <- cmcc_cm_bio2[[1:30]]
cmcc_cm_bio4 <- cmcc_cm_bio4[[1:30]]
cmcc_cm_bio5 <- cmcc_cm_bio5[[1:30]]
cmcc_cm_bio6 <- cmcc_cm_bio6[[1:30]]


cmcc_cm_bio1 <- wrap(cmcc_cm_bio1)
cmcc_cm_bio2 <- wrap(cmcc_cm_bio2)
cmcc_cm_bio4 <- wrap(cmcc_cm_bio4)
cmcc_cm_bio5 <- wrap(cmcc_cm_bio5)
cmcc_cm_bio6 <- wrap(cmcc_cm_bio6)
cmcc_cm_bio12 <- wrap(cmcc_cm_bio12)

usethis::use_data(cmcc_cm_bio1, overwrite = TRUE)
usethis::use_data(cmcc_cm_bio2, overwrite = TRUE)
usethis::use_data(cmcc_cm_bio4, overwrite = TRUE)
usethis::use_data(cmcc_cm_bio5, overwrite = TRUE)
usethis::use_data(cmcc_cm_bio6, overwrite = TRUE)
usethis::use_data(cmcc_cm_bio12, overwrite = TRUE)

###
cmcc_cm_pr <- wrap(cmcc_cm_pr)
usethis::use_data(cmcc_cm_pr, overwrite = TRUE, compress = "xz")
