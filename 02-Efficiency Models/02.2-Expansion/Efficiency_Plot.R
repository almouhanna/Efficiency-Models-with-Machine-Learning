# ==========================================================
# Plot Efficiency Score Distributions by STATE
# DEA + SFA Models
# One plot for each STATE
# ==========================================================
library(readxl)
library(ggplot2)
library(tidyr)
library(dplyr)

# 1. Read Excel File
input_file <- "ITAC_Database_State_Efficiency.xlsx"
data <- read_excel(input_file)

# Remove Extra Spaces from Column Names
names(data) <- trimws(names(data))

# Clean STATE values
data$STATE <- toupper(trimws(data$STATE))

# 2. Select Efficiency Columns
efficiency_cols <- c("DEA_VRS", "DEA_CRS", "DEA_DRS",
                     "DEA_IRS", "SFA_LOG", "SFA_TRANSLOG")

# 3. Create Output Folder
output_folder <- "State_Efficiency_Distribution_Plots"

if (!dir.exists(output_folder)) {
  dir.create(output_folder)
}

# 4. Get List of States
states <- sort(unique(data$STATE))

# 5. Create and Save Plot for Each STATE
for (st in states) {
  cat("\n====================================\n")
  cat("Creating plot for STATE:", st, "\n")
  cat("====================================\n")
  
  # Filter data for current state
  state_data <- data %>% filter(STATE == st)
  
  # Select efficiency columns
  efficiency_data <- state_data %>% select(all_of(efficiency_cols))
  
  # Convert to Long Format
  plot_data <- efficiency_data %>% pivot_longer(cols = everything(),
                 names_to = "Model", values_to = "Efficiency")
  
  # Remove NA / NaN / Inf values
  plot_data <- plot_data %>% filter(is.finite(Efficiency))
  
  # Set model order
  plot_data$Model <- factor(plot_data$Model,
                            levels = c("DEA_VRS", "DEA_CRS", "DEA_DRS",
                                       "DEA_IRS", "SFA_LOG", "SFA_TRANSLOG"))
  
  # Skip state if there are no valid efficiency values
  if (nrow(plot_data) == 0) {
    cat("No valid efficiency values for STATE:", st, "\n")
    next
  }
  
  # Create Plot
  p <- ggplot(plot_data, aes(x = Efficiency)) +
    geom_histogram(aes(y = ..density..), bins = 20,
                   fill = "lightblue", color = "black", alpha = 0.6) +
    geom_density(color = "darkblue", linewidth = 1) +
    facet_wrap(~ Model, scales = "free", ncol = 3) +
    theme_gray(base_size = 12) +
    labs(title = paste("Frequency Distribution of Efficiency Models - STATE:", st),
         x = "Efficiency", y = "Density")
  
  # Save Plot
  output_file <- file.path(output_folder,
                           paste0("Efficiency_Distributions_", st, ".png"))
  
  ggsave(filename = output_file,
         plot = p, width = 12, height = 8, dpi = 300)
  
  cat("Plot saved successfully as:\n")
  cat(output_file, "\n")
}

# Final Message
cat("\n====================================\n")
cat("ALL STATE PLOTS CREATED SUCCESSFULLY\n")
cat("====================================\n")

