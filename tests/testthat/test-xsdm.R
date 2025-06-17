#env variables

testthat::test_that("errors",{
  bio1_ts <- terra::unwrap(cmcc_cm_bio1)
  pts <- mus_virtualis


  testthat::expect_error(
    xsdm(bio1_ts, occ = pts)
  )
#
#   bio1_ts <- terra::unwrap(cmcc_cm_bio1)
#   envData <- list(bio1 = bio1_ts)
#   pts <- mus_virtualis
#   pts <- rbind(pts,pts)
#
#    testthat::expect_error(
#     xsdm(envData, occ = pts),
#     regexp = "points are duplicated"
#   )


})
