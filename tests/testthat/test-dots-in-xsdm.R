test_that("correct chains in ... of xsdm()", {
  r <- matrix(1, ncol = 2, nrow = 2)
  r <- terra::rast(r)
  p <- terra::as.points(r)
  p$occ <- 1
  r <- list(c(r, r))
  # should have 4 chains
  mssg <- tryCatch(
    xsdm(r, p, "lewontin-cohen", dry = TRUE),
    message = function(m) {
      conditionMessage(m)
    }
  )
  expected_mssg <- paste0(
    "You are running XSDM using:\n",
    "  - Lewontin-Cohen\n",
    "  - 1 climatic variable(s) as predictors\n",
    "  - 4 chains\n"
  )
  expect_identical(mssg, expected_mssg)
  # should have same chains
  chains <- sample(1:1e3, 1)
  mssg <- tryCatch(
    xsdm(r, p, "lewontin-cohen", dry = TRUE, chains = chains),
    message = function(m) {
      conditionMessage(m)
    }
  )
  expected_mssg <- paste0(
    "You are running XSDM using:\n",
    "  - Lewontin-Cohen\n",
    "  - 1 climatic variable(s) as predictors\n",
    "  - ", chains, " chains\n"
  )
  expect_identical(mssg, expected_mssg)
})
