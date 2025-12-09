# Tests


library(testthat)
source("clean_data.R")
source("algorithm.R")
source("simulation.R")

test_that("clean_data removes rows with NA and computes pct_change", {
  df <- data.frame(
    Open = c(100, 102, NA, 105),
    Close = c(101, 103, 104, 106)
  )
  
  cleaned <- clean_data(df)
  
  # No NAs should remain
  expect_false(any(is.na(cleaned)))
  
  # pct_change must exist
  expect_true("pct_change" %in% colnames(cleaned))
  
  # pct_change values correct
  expect_equal(cleaned$pct_change[1], (101 - 100)/100 * 100)
})

test_that("categorize_change assigns proper labels", {
  expect_equal(categorize_change(2.5), "good")
  expect_equal(categorize_change(0.3), "mid")
  expect_equal(categorize_change(-2.1), "bad")
})

test_that("estimate_mc returns list with matrix + next_state", {
  df <- data.frame(
    pct_change = c(2.0, -1.0, 0.5, 3.0, -2.5),
    state = c("good", "bad", "mid", "good", "bad")
  )
  
  result <- estimate_mc(df, start = 1, window = 4)
  
  expect_true("matrix" %in% names(result))
  expect_true("prediction" %in% names(result))
  
  M <- result$matrix
  
  # matrix must be 3x3
  expect_equal(dim(M), c(3,3))
  
  # each row should sum to 1
  row_sums <- rowSums(M)
  expect_true(all(abs(row_sums - 1) < 1e-8))
})

test_that("predict_state returns one of good/mid/bad", {
  M <- matrix(
    c(0.6, 0.3, 0.1,
      0.2, 0.5, 0.3,
      0.25,0.25,0.5),
    nrow = 3, byrow = TRUE
  )
  rownames(M) <- colnames(M) <- c("good","mid","bad")
  
  pred <- predict_state(M, current_state = "good")
  expect_true(pred %in% c("good","mid","bad"))
})

test_that("simulation produces numeric accuracy", {
  df <- data.frame(
    pct_change = rnorm(300, mean = 0.2, sd = 1),
    state = sample(c("good","mid","bad"), 300, replace = TRUE)
  )
  
  acc <- simulate_accuracy(df, window = 20, n_sims = 50)
  
  expect_true(is.numeric(acc))
  expect_true(acc >= 0 && acc <= 1)
})
