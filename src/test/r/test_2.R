source("../../src/main/r/eerste.R")

test_that("Nieuw - Test eerste is 4",{
  expect_equal(eerste(), 4)
})
