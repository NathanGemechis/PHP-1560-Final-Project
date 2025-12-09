# Stock Day Prediction using Markov Chains

## Overview
Estimate stock daily returns, categorize days into "good", "mid", or "bad", and predict the next day type using a Markov transition matrix. Monte Carlo simulations are used to evaluate prediction accuracy for different window sizes.

## Scripts

- **clean_data.R**
  - Cleans raw stock price data:
    - Renames columns (`Date`, `Close/Last`, `Open`, `High`, `Low`, `Volume`)  
    - Converts dates to `Date` type  
    - Converts price/volume columns to numeric  
    - Removes rows with missing values  
    - Orders data by descending date  
  - Computes daily changes and percent changes  
  - Categorizes each day as `good`, `mid`, or `bad`  

- **algorithm.R**
  - Predicts next day type using a Markov transition matrix:
    - Counts transitions over a specified window  
    - Builds 3×3 transition probability matrix  
    - Predicts next day based on last observed day in window  

- **simulation.R**
  - Runs Monte Carlo simulations to estimate prediction accuracy:
    - Samples random windows from the data  
    - Predicts next day type and compares to actual  
    - Stores per-rep results (`predicted`, `actual`, `correct`)  
    - Computes overall accuracy per window size  

- **visualizations.R**
  - Visualizes stock data, state classifications, and model performance:
    - Daily percent changes over time (`plot_percent_changes()`)
    - Day type classification timeline (`plot_day_types()`)
    - Markov transition matrix heatmap (`plot_transition_matrix()`)
    - Prediction accuracy distribution (`plot_prediction_accuracy_dist()`)
    - Prediction accuracy vs. window size (`plot_accuracy_vs_window()`)
    - Actual vs predicted day types (`plot_pred_vs_actual()`)
    - Mean accuracy ± SD across all windows (`plot_accuracy_summary_all_windows()`)


- **pipeline.R**
  - Loads all scripts and raw stock data  
  - Cleans data and generates `df`  
  - Loops over multiple window sizes (e.g., 100, 150, …, 500):
    - Runs Monte Carlo simulations per window  
    - Stores mean accuracy and individual rep results  
    - Generates all plots for exploration and analysis  
  - Prints summary tables and accuracy plots  

## How to Run

1. Place all scripts and your stock CSV file in the same directory.  
2. Open `pipeline.R` in R.  
3. Edit the path to your stock CSV in `pipeline.R`:  
   ```r
   raw_data <- read_csv("C:/path/to/your/stock.csv")
