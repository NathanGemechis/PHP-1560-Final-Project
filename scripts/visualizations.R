# Visualizations script

# Plot daily percent changes over time
plot_percent_changes <- function(data) {
  ggplot(data, aes(x = date, y = percent_change)) +
    geom_line(color = "steelblue", size = 1) +
    labs(
      title = "Daily Percent Changes",
      x = "Date",
      y = "Percent Change"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      axis.title = element_text(face = "bold")
    )
}

# Plot day type classification timeline (good / mid / bad)
plot_day_types <- function(data) {
  ggplot(data, aes(x = date, y = 0, color = day_type)) +
    geom_point(size = 4, alpha = 0.8) +
    scale_color_manual(values = c("good" = "#2ca02c", "mid" = "#1f77b4", "bad" = "#d62728")) +
    labs(
      title = "Day Type Classification Timeline",
      x = "Date",
      y = ""
    ) +
    theme_minimal(base_size = 14) +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      plot.title = element_text(face = "bold", hjust = 0.5),
      legend.title = element_blank()
    )
}

# Plot Markov transition matrix as a heatmap
plot_transition_matrix <- function(mat) {
  df <- as.data.frame(mat)
  df$from <- rownames(mat)
  df <- df %>%
    pivot_longer(
      cols = c("good", "mid", "bad"),
      names_to = "to",
      values_to = "prob"
    )
  
  ggplot(df, aes(x = to, y = from, fill = prob)) +
    geom_tile(color = "white") +
    scale_fill_gradient(low = "white", high = "#1f77b4") +
    geom_text(aes(label = sprintf("%.2f", prob)), color = "black", fontface = "bold") +
    labs(
      title = "Markov Transition Matrix",
      x = "Next Day",
      y = "Current Day",
      fill = "Probability"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      axis.title = element_text(face = "bold")
    )
}

# Plot number of correct vs incorrect predictions
plot_prediction_accuracy_dist <- function(results) {
  ggplot(results, aes(x = correct)) +
    geom_bar(fill = "#1f77b4", alpha = 0.8) +
    scale_x_discrete(labels = c("FALSE" = "Incorrect", "TRUE" = "Correct")) +
    labs(
      title = "Prediction Accuracy Distribution",
      x = "Prediction Outcome",
      y = "Count"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      axis.title = element_text(face = "bold")
    )
}

# Plot prediction accuracy for different window sizes
plot_accuracy_vs_window <- function(df) {
  ggplot(df, aes(x = window, y = accuracy)) +
    geom_line(color = "#1f77b4", size = 1.2) +
    geom_point(size = 4, color = "#ff7f0e") +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
    labs(
      title = "Prediction Accuracy vs Window Size",
      x = "Window Size",
      y = "Prediction Accuracy"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      axis.title = element_text(face = "bold")
    )
}

# Plot actual vs predicted states (good/mid/bad) with correctness markers
plot_pred_vs_actual <- function(actual, predicted) {
  levels_states <- c("bad", "mid", "good")
  
  df <- data.frame(
    day = seq_along(actual),
    actual = factor(actual, levels = levels_states),
    predicted = factor(predicted, levels = levels_states)
  )
  
  df$accurate <- df$actual == df$predicted
  
  ggplot(df, aes(x = day)) +
    geom_line(aes(y = as.numeric(actual), color = "Actual"), size = 1.5) +
    geom_line(aes(y = as.numeric(predicted), color = "Predicted"),
              size = 1.2, linetype = "dashed") +
    geom_point(aes(
      y = as.numeric(predicted),
      fill = accurate
    ),
    shape = 21, size = 3, color = "black") +
    scale_color_manual(values = c("Actual" = "#2ca02c", "Predicted" = "#1f77b4")) +
    scale_fill_manual(values = c("TRUE" = "#2ca02c", "FALSE" = "#d62728")) +
    scale_y_continuous(
      breaks = 1:3,
      labels = levels_states
    ) +
    labs(
      title = "Actual vs Predicted Day Types",
      x = "Simulation Step",
      y = "Day Type",
      color = "",
      fill = "Prediction Accuracy"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      axis.title = element_text(face = "bold")
    )
}

# Plot mean accuracy ± SD for all window sizes
plot_accuracy_summary_all_windows <- function(all_results_df) {
  summary_df <- all_results_df %>%
    group_by(window) %>%
    summarize(
      mean_acc = mean(accuracy),
      sd_acc = sd(accuracy)
    )
  
  ggplot(summary_df, aes(x = window, y = mean_acc)) +
    geom_line(color = "#1f77b4", size = 1.2) +
    geom_point(size = 4, color = "#ff7f0e") +
    geom_errorbar(aes(ymin = mean_acc - sd_acc, ymax = mean_acc + sd_acc), width = 10, color = "#2ca02c") +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
    labs(
      title = "Mean Accuracy ± SD Across Window Sizes",
      x = "Window Size",
      y = "Prediction Accuracy"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      axis.title = element_text(face = "bold")
    )
}

# Plot rolling average of closing price
plot_rolling_avg <- function(data, window = 20) {
  data <- data %>%
    arrange(date) %>%
    mutate(
      rolling_avg = purrr::map_dbl(seq_along(close), function(i) {
        if (i < window) return(NA)
        mean(close[(i - window + 1):i])
      })
    )
  
  ggplot(data, aes(x = date)) +
    geom_line(aes(y = close), color = "steelblue", size = 1) +
    geom_line(aes(y = rolling_avg), color = "#ff7f0e", size = 1.2, linetype = "dashed") +
    labs(
      title = paste("Closing Price with", window, "Day Rolling Average"),
      x = "Date",
      y = "Price"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      axis.title = element_text(face = "bold")
    )
}

# Plot histogram of daily percent changes
plot_percent_change_hist <- function(data, bins = 30) {
  ggplot(data, aes(x = percent_change)) +
    geom_histogram(fill = "#2ca02c", color = "black", bins = bins, alpha = 0.7) +
    labs(
      title = "Histogram of Daily Percent Changes",
      x = "Daily Percent Change",
      y = "Count"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      axis.title = element_text(face = "bold")
    )

}
