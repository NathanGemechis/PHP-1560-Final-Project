# Data Cleaning Script

#' Clean and standardize price data with proper date sorting
#'
#' This function renames key price variables, converts `date` to Date type,
#' orders rows by descending date, and removes any rows containing missing values.
#'
#' @param data A data frame containing raw stock price data, expected to include
#'   columns `Date`, `Close/Last`, `Volume`, `Open`, `High`, and `Low`.
#'
#' @return A tibble with renamed columns (`date`, `close`, `volume`, `open`,
#'   `high`, `low`), sorted by descending date and with all rows containing NAs removed.
clean_prices <- function(data) {
  data %>%
    # Rename columns for consistency
    rename(
      date = Date,
      close = `Close/Last`,
      volume = Volume,
      open = Open,
      high = High,
      low = Low
    ) %>%
    # Convert numeric columns from character to numeric
    mutate(
      close  = as.numeric(gsub("[$,]", "", close)),
      open   = as.numeric(gsub("[$,]", "", open)),
      high   = as.numeric(gsub("[$,]", "", high)),
      low    = as.numeric(gsub("[$,]", "", low)),
      volume = as.numeric(volume)  # already numeric but in case not
    ) %>%
    # Convert date column safely to Date type
    mutate(
      date = as.Date(date, tryFormats = c("%Y-%m-%d", "%m/%d/%Y", "%d-%m-%Y"))
    ) %>%
    # Remove any rows with NA in date or close
    drop_na(date, close) %>%
    # Sort data by descending date
    arrange(desc(date))
}


# Add daily change and percent change columns
add_change <- function(data) {
  data$change <- numeric(nrow(data))          # Initialize column for absolute change
  data$percent_change <- numeric(nrow(data))  # Initialize column for percent change
  
  for(i in 2:nrow(data)) {
    data$change[i] <- data$close[i] - data$close[i - 1]        # Calculate daily change
    data$percent_change[i] <- data$change[i] / data$close[i - 1] # Calculate percent change
  }
  
  # Remove first row (cannot compute change for first day)
  data %>% slice(-1)
}


# Categorize each day as "good", "mid", or "bad"
categorize_days <- function(data) {
  data %>%
    mutate(
      day_type = case_when(
        percent_change > 0.01  ~ "good",  # >1% gain
        percent_change < -0.01 ~ "bad",   # >1% loss
        TRUE                   ~ "mid"    # otherwise
      )
    )
}


# Full cleaning pipeline
clean_data <- function(data) {
  data <- clean_prices(data)     # Step 1: rename, convert, sort, drop NA
  data <- add_change(data)       # Step 2: compute daily changes
  data <- categorize_days(data)  # Step 3: classify day types
}

