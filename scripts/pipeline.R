# Load necessary packages
library(tidyverse)
library(lubridate)

# Load project scripts
source("clean_data.R")
source("algorithm.R")
source("simulation.R")
source("visualizations.R")

# Load raw data
raw_data <- read_csv("C:/path/to/your/stock.csv")

# Clean data
df <- clean_data(raw_data)

# Window sizes to test: 100, 150, ..., 500
windows <- seq(100, 500, by = 50)

# Storage for mean accuracy per window
acc_results <- tibble(
  window = integer(),
  accuracy = numeric()
)

# Storage for all individual simulation results (for overall summary plot)
all_sim_results <- tibble(
  window = integer(),
  accuracy = numeric()
)

# Loop through each window size
for (w in windows) {
  cat("Running simulation for window =", w, "...\n")
  
  # Run Monte Carlo simulation
  sim <- simulate_markov_accuracy(df, window = w, reps = 1000, seed = 123)
  
  # Store mean accuracy for this window
  acc_results <- acc_results %>%
    add_row(window = w, accuracy = sim$accuracy)
  
  # Store individual rep results for overall summary plot
  all_sim_results <- bind_rows(all_sim_results, tibble(
    window = w,
    accuracy = as.numeric(sim$results$correct)
  ))
}

# Print summary of mean accuracy vs window
print(acc_results)

# Plot mean accuracy vs window size
print(plot_accuracy_vs_window(acc_results))

# Plot distribution of prediction accuracy across all windows
print(plot_accuracy_summary_all_windows(all_sim_results))


print(plot_percent_change_hist(df, bins = 30))  # Histogram of daily percent changes
