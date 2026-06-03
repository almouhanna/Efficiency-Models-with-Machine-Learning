# ==========================================================
# STATE-Based Normalization and Discretization
# Normalization within each STATE separately
# Classification within each STATE separately
# Classes: 2, 3, and 5
# ==========================================================

library(readxl)
library(writexl)
library(arules)

# Normalization
# ==========================================================
input_file_r  <- "ITAC_Database_State_Efficiency.xlsx"
output_file_r <- "ITAC_Database_State_Regression.xlsx"

data_r <- read_excel(input_file_r)

# Remove Extra Spaces from Column Names
names(data_r) <- trimws(names(data_r))

# Clean STATE values
data_r$STATE <- toupper(trimws(data_r$STATE))

# Normalization Function
normFun <- function(x) {(x - min(x)) / (max(x) - min(x))}

vars_to_normalize <- c("SALES", "EMPLOYEES", "COST_ENER",
                       "PRODHOURS", "SFA_LOG", "SFA_TRANSLOG",
                       "DEA_CRS", "DEA_VRS", "DEA_IRS", "DEA_DRS")

# Apply Normalization within each STATE
states <- unique(data_r$STATE)

for (st in states) {
  cat("\n====================================\n")
  cat("Normalizing STATE:", st, "\n")
  cat("====================================\n")
  
  state_index <- which(data_r$STATE == st)
  
  data_r[state_index, vars_to_normalize] <-
    lapply(data_r[state_index, vars_to_normalize], normFun)
}

# Save Results
write_xlsx(data_r, output_file_r)

# Print Confirmation
cat("State-based normalization completed successfully.\n")
cat("\nThe file was saved as:\n")
cat(output_file_r, "\n")

# Discretization
# ==========================================================

# Read Excel File
input_file_c <- "ITAC_Database_State_Regression.xlsx"
data_original <- read_excel(input_file_c)

# Remove Extra Spaces from Column Names
names(data_original) <- trimws(names(data_original))

# Clean STATE values
data_original$STATE <- toupper(trimws(data_original$STATE))

vars_to_classify <- c("SFA_LOG", "SFA_TRANSLOG", "DEA_CRS",
                      "DEA_VRS", "DEA_IRS", "DEA_DRS")

# Different Numbers of Classes
class_levels <- list("2" = c('B', 'A'),
                     "3" = c('C', 'B', 'A'),
                     "5" = c('E', 'D', 'C', 'B', 'A'))

# Apply Discretization
for (num_classes in names(class_levels)) {
  cat("\n====================================\n")
  cat("Processing", num_classes, "Classes\n")
  cat("====================================\n")
  
  # Copy Original Dataset
  data_c <- data_original
  
  # Output File Name
  output_file_c <- paste0("ITAC_Database_State_Classification_",
                          num_classes, ".xlsx")
  
  # Labels
  current_labels <- class_levels[[num_classes]]
  
  # Apply Discretization within each STATE
  states <- unique(data_c$STATE)
  
  for (st in states) {
    cat("\nClassifying STATE:", st, "\n")
    state_index <- which(data_c$STATE == st)
    for (var_name in vars_to_classify) {
      new_col_name <- paste0(var_name, "_cat")
      if (!(new_col_name %in% names(data_c))) {
        data_c[[new_col_name]] <- NA
      }
      data_c[[new_col_name]][state_index] <- as.character(
        discretize(data_c[[var_name]][state_index],
                   method = "interval",
                   breaks = as.numeric(num_classes),
                   labels = current_labels)
      )
    }
  }
  
  # Remove Original Variables
  data_c <- data_c[, !(names(data_c) %in% vars_to_classify)]
  
  # Save Results
  write_xlsx(data_c, output_file_c)
  
  # Print Confirmation
  cat("\nClassification completed successfully.\n")
  cat("\nNew categorical variables created:\n")
  print(paste0(vars_to_classify, "_cat"))
  cat("\nThe file was saved as:\n")
  cat(output_file_c, "\n")
}

# Final Message
cat("\n====================================\n")
cat("ALL FILES CREATED SUCCESSFULLY\n")
cat("====================================\n")
