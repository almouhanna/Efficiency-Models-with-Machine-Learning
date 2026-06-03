# ==========================================================
# STATE-Based DEA and SFA Efficiency Models
# SFA-LOG + SFA-TRANSLOG + DEA-CRS/VRS/IRS/DRS
# Input-Oriented DEA
# Efficiency calculated within each STATE separately
# ==========================================================

library(readxl)
library(writexl)
library(Benchmarking)
library(frontier)

# 1. Read Excel File
input_file <- "ITAC_Database_Final.xlsx"
output_file <- "ITAC_Database_State_Efficiency.xlsx"

data <- read_excel(input_file)
names(data) <- trimws(names(data))

# 2. Define Variables
state_var <- "STATE"

input_vars <- c("EMPLOYEES", "COST_ENER", "PRODHOURS")
output_var <- "SALES"
required_vars <- c("ID", "FINA_YEAR", state_var, output_var, input_vars)

# 3. Keep Valid Records Only
data <- data[complete.cases(data[, required_vars]), ]
data <- data[data$SALES > 0 &
               data$EMPLOYEES > 0 &
               data$COST_ENER > 0 &
               data$PRODHOURS > 0, ]
cat("Number of valid records used:", nrow(data), "\n")
cat("Number of states:", length(unique(data$STATE)), "\n")

# 4. Create Empty Efficiency Columns
data$SFA_LOG <- NA_real_
data$SFA_TRANSLOG <- NA_real_

data$DEA_CRS <- NA_real_
data$DEA_VRS <- NA_real_
data$DEA_IRS <- NA_real_
data$DEA_DRS <- NA_real_

# 5. Run Models Separately for Each STATE
states <- unique(data$STATE)
for (st in states) {
  cat("\n====================================\n")
  cat("Processing STATE:", st, "\n")
  cat("====================================\n")
  state_index <- which(data$STATE == st)
  state_data <- data[state_index, ]
  cat("Number of records in this state:", nrow(state_data), "\n")
  
  # Define Inputs and Output for this state
  x <- as.matrix(state_data[, input_vars])
  y <- as.matrix(state_data[, output_var])
  
  # 5.1 SFA-LOG Model
  tryCatch({
    sfa_log <- Benchmarking::sfa(log(x), log(y))
    data$SFA_LOG[state_index] <- as.numeric(Benchmarking::te.sfa(sfa_log))
    cat("SFA-LOG completed successfully.\n")
  }, error = function(e) {
    cat("SFA-LOG failed for STATE:", st, "\n")
    cat("Reason:", e$message, "\n")
  })
  
  # 5.2 Create Log Variables for SFA-TRANSLOG
  state_data$ln_SALES <- log(state_data$SALES)
  state_data$ln_EMPLOYEES <- log(state_data$EMPLOYEES)
  state_data$ln_COST_ENER <- log(state_data$COST_ENER)
  state_data$ln_PRODHOURS <- log(state_data$PRODHOURS)
  
  # 5.3 SFA-TRANSLOG Model
  tryCatch({
    sfa_translog <- frontier::sfa(
      ln_SALES ~
        ln_EMPLOYEES +
        ln_COST_ENER +
        ln_PRODHOURS +
        
        I(0.5 * ln_EMPLOYEES^2) +
        I(0.5 * ln_COST_ENER^2) +
        I(0.5 * ln_PRODHOURS^2) +
        
        I(ln_EMPLOYEES * ln_COST_ENER) +
        I(ln_EMPLOYEES * ln_PRODHOURS) +
        I(ln_COST_ENER * ln_PRODHOURS),
      
      data = state_data, timeEffect = FALSE)
    
    data$SFA_TRANSLOG[state_index] <- as.numeric(frontier::efficiencies(sfa_translog))
    cat("SFA-TRANSLOG completed successfully.\n")
  }, error = function(e) {
    cat("SFA-TRANSLOG failed for STATE:", st, "\n")
    cat("Reason:", e$message, "\n")
  })
  
  # 5.4 DEA Models - Input-Oriented
  tryCatch({
    dea_crs <- Benchmarking::dea(X = x, Y = y, RTS = "crs", ORIENTATION = "in")
    dea_vrs <- Benchmarking::dea(X = x, Y = y, RTS = "vrs", ORIENTATION = "in")
    dea_irs <- Benchmarking::dea(X = x, Y = y, RTS = "irs", ORIENTATION = "in")
    dea_drs <- Benchmarking::dea(X = x, Y = y, RTS = "drs", ORIENTATION = "in")
    
    data$DEA_CRS[state_index] <- as.numeric(Benchmarking::efficiencies(dea_crs))
    data$DEA_VRS[state_index] <- as.numeric(Benchmarking::efficiencies(dea_vrs))
    data$DEA_IRS[state_index] <- as.numeric(Benchmarking::efficiencies(dea_irs))
    data$DEA_DRS[state_index] <- as.numeric(Benchmarking::efficiencies(dea_drs))
    
    cat("DEA models completed successfully.\n")
  }, error = function(e) {
    cat("DEA models failed for STATE:", st, "\n")
    cat("Reason:", e$message, "\n")
  })
}

# 6. Print Summary
cat("\nSummary of State-Based Efficiency Scores:\n")
print(summary(data[, c("SFA_LOG", "SFA_TRANSLOG", "DEA_CRS", 
                       "DEA_VRS", "DEA_IRS", "DEA_DRS")]))

cat("\nNumber of Efficient DMUs:\n")
cat("DEA_CRS:", sum(round(data$DEA_CRS, 6) == 1, na.rm = TRUE), "\n")
cat("DEA_VRS:", sum(round(data$DEA_VRS, 6) == 1, na.rm = TRUE), "\n")
cat("DEA_IRS:", sum(round(data$DEA_IRS, 6) == 1, na.rm = TRUE), "\n")
cat("DEA_DRS:", sum(round(data$DEA_DRS, 6) == 1, na.rm = TRUE), "\n")

cat("\nMean Efficiency:\n")
cat("SFA_LOG:", mean(data$SFA_LOG, na.rm = TRUE), "\n")
cat("SFA_TRANSLOG:", mean(data$SFA_TRANSLOG, na.rm = TRUE), "\n")
cat("DEA_CRS:", mean(data$DEA_CRS, na.rm = TRUE), "\n")
cat("DEA_VRS:", mean(data$DEA_VRS, na.rm = TRUE), "\n")
cat("DEA_IRS:", mean(data$DEA_IRS, na.rm = TRUE), "\n")
cat("DEA_DRS:", mean(data$DEA_DRS, na.rm = TRUE), "\n")

# 7. Save Results
write_xlsx(data, output_file)
cat("\nResults saved successfully as:\n")
cat(output_file, "\n")

