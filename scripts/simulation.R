# Simulations Script

#' Run Monte Carlo simulation to estimate prediction accuracy
#'
#' This function repeatedly samples windows from the data, predicts the next
#' day using the Markov transition algorithm, and checks whether the prediction
#' matches the true next day. It returns accuracy and detailed results.
#'
#' @param data Data frame that contains a column `day_type`
#'        ("good", "mid", "bad").
#' @param window Integer window size W used for Markov estimation.
#' @param reps Integer number of Monte Carlo simulations (default 1000).
#' @param seed Optional random seed for reproducibility.
#'
#' @return A list containing:
#'   \item{accuracy}{Prediction accuracy over all reps}
#'   \item{results}{Data frame of each rep:
#'                  start index, predicted, actual, correct (TRUE/FALSE)}
simulate_markov_accuracy <- function(data, window, reps = 1000, seed = NULL) {
  
  # Set random seed if provided
  if (!is.null(seed)) set.seed(seed)
  
  # Determine the number of valid starting indices
  n <- nrow(data)
  max_start <- n - window - 1
  if (max_start <= 0) {
    stop("Window too large for dataset.")
  }
  
  # Initialize storage vectors for results
  preds <- character(reps)    # Predicted day types
  actual <- character(reps)   # Actual day types
  correct <- logical(reps)    # Correctness of predictions
  starts <- integer(reps)     # Starting indices used for each simulation
  
  # Monte Carlo loop over reps
  for (i in 1:reps) {
    
    # Random valid start index
    s <- sample(1:max_start, 1)
    starts[i] <- s
    
    # Predict next day type using Markov algorithm
    preds[i] <- predict_next_day(data, start = s, window = window)
    
    # Retrieve actual next day type
    actual[i] <- data$day_type[s + window]
    
    # Check if prediction was correct
    correct[i] <- (preds[i] == actual[i])
  }
  
  # Compute overall accuracy
  accuracy <- mean(correct)
  
  # Compile detailed results into a data frame
  results <- data.frame(
    start = starts,
    predicted = preds,
    actual = actual,
    correct = correct
  )
  
  # Return accuracy and results
  list(
    accuracy = accuracy,
    results = results
  )
}
