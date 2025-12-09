# Markov Algorithm Script

#' Predict the next day type using a Markov transition matrix
#'
#' This function estimates the 3×3 Markov transition matrix over a specified
#' window of your data and returns a single predicted next day type
#' ("good", "mid", or "bad") based on the last observed day in that window.
#'
#' @param data A data frame containing a column \code{day_type} with values
#'        "good", "mid", or "bad".
#' @param start Integer index of the first row to use for transition estimation.
#' @param window Integer number of transitions to include (rows \code{start} to
#'        \code{start + window}).
#'
#' @return Character string: predicted next day type ("good", "mid", or "bad").
#'
#' @examples
#' next_day <- predict_next_day(df, start = 1, window = 200)
predict_next_day <- function(data, start, window) {
  
  
  # Initialize transition counts
  
  good_good <- 0; good_mid <- 0; good_bad <- 0
  mid_good  <- 0; mid_mid  <- 0; mid_bad  <- 0
  bad_good  <- 0; bad_mid  <- 0; bad_bad  <- 0
  
  
  # Count transitions over the window
  
  for (i in start:(start + window - 1)) {
    today   <- data$day_type[i]      # Current day type
    nextday <- data$day_type[i + 1]  # Next day type
    
    # Increment appropriate transition counter
    if (today == "good" && nextday == "good") good_good <- good_good + 1
    if (today == "good" && nextday == "mid")  good_mid  <- good_mid  + 1
    if (today == "good" && nextday == "bad")  good_bad  <- good_bad  + 1
    
    if (today == "mid"  && nextday == "good") mid_good  <- mid_good  + 1
    if (today == "mid"  && nextday == "mid")  mid_mid   <- mid_mid   + 1
    if (today == "mid"  && nextday == "bad")  mid_bad   <- mid_bad   + 1
    
    if (today == "bad"  && nextday == "good") bad_good  <- bad_good  + 1
    if (today == "bad"  && nextday == "mid")  bad_mid   <- bad_mid   + 1
    if (today == "bad"  && nextday == "bad")  bad_bad   <- bad_bad   + 1
  }
  
  
  # Build and normalize transition matrix

  mat <- matrix(
    c(
      good_good, good_mid, good_bad,
      mid_good,  mid_mid,  mid_bad,
      bad_good,  bad_mid,  bad_bad
    ),
    nrow = 3,
    byrow = TRUE
  )
  
  prob_mat <- mat / rowSums(mat)                # Normalize rows to sum to 1
  rownames(prob_mat) <- c("good", "mid", "bad")
  colnames(prob_mat) <- c("good", "mid", "bad")
  
  # Predict next day based on last observed day in window
  last_day <- data$day_type[start + window]     # Last observed day in window
  probs <- prob_mat[last_day, ]                 # Probabilities of next day types
  
  
  # Handle edge cases: invalid probabilities
  
  if (any(is.na(probs)) || sum(probs) == 0) {
    return("mid")  # Default prediction
  }
  
  
  # Return predicted next day type
  
  return(names(which.max(probs)))
}
