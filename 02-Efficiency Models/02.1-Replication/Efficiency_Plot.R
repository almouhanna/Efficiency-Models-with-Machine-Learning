# ==========================================================
# Plot Efficiency Score Distributions
# DEA + SFA Models
# ==========================================================
library(readxl)
library(ggplot2)
library(tidyr)
library(dplyr)

# 1. Read Excel File
input_file <- "ITAC_Database_Efficiency.xlsx"
data <- read_excel(input_file)

# 2. Select Efficiency Columns
efficiency_data <- data %>% select(DEA_VRS, DEA_CRS, DEA_DRS,
                                   DEA_IRS, SFA_LOG, SFA_TRANSLOG)

# 3. Convert to Long Format
plot_data <- efficiency_data %>% pivot_longer(cols = everything(),
             names_to = "Model", values_to = "Efficiency")

plot_data$Model <- factor(plot_data$Model, 
                   levels = c("DEA_VRS", "DEA_CRS", "DEA_DRS",
                              "DEA_IRS", "SFA_LOG", "SFA_TRANSLOG"))

# 4. Create Plot
p <- ggplot(plot_data, aes(x = Efficiency)) + geom_histogram(aes(y = ..density..),
     bins = 20, fill = "lightblue", color = "black", alpha = 0.6) +
     geom_density(color = "darkblue", linewidth = 1) +
     facet_wrap(~ Model, scales = "free", ncol = 3) +
     theme_gray(base_size = 12) +
     labs(title = "Frequency Distribution of Efficiency Models",
                   x = "Efficiency", y = "Density")

# 5. Show Plot
print(p)

# 6. Save Plot
ggsave(filename = "Efficiency_Distributions.png", plot = p,
                   width = 12, height = 8, dpi = 300)
cat("\nPlot saved successfully as:\n")
cat("Efficiency_Distributions.png\n")

