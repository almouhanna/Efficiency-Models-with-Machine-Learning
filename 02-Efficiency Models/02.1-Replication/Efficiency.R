# ==========================================================
# DEA and SFA Efficiency Models
# SFA-LOG + SFA-TRANSLOG + DEA-CRS/VRS/IRS/DRS
# Input-Oriented DEA
# ==========================================================
library(readxl)
library(writexl)
library(Benchmarking)
library(frontier)

# 1. Read Excel File
input_file <- "ITAC_Database_Final.xlsx"
output_file <- "ITAC_Database_Efficiency_Results.xlsx"
data <- read_excel(input_file)
names(data) <- trimws(names(data))

# 2. Define Variables
input_vars <- c("EMPLOYEES", "USAGE_ELEC", "USAGE_NAT",
                "PRODHOURS", "COST_ELEC", "COST_NAT")
output_var <- "SALES"
required_vars <- c(output_var, input_vars)

# 3. Keep Valid Records Only
data <- data[complete.cases(data[, required_vars]), ]
data <- data[data$SALES > 0 & data$EMPLOYEES > 0 &
             data$USAGE_ELEC > 0 & data$USAGE_NAT > 0 &
             data$PRODHOURS > 0 & data$COST_ELEC > 0 &
             data$COST_NAT > 0,]
cat("Number of records used:", nrow(data), "\n")

# 4. Define Inputs and Output
x <- as.matrix(data[, input_vars])
y <- as.matrix(data[, output_var])

# 5. SFA-LOG Model
sfa_log <- Benchmarking::sfa(log(x), log(y))
summary(sfa_log)
data$SFA_LOG <- as.numeric(Benchmarking::te.sfa(sfa_log))

# 6. Create Log Variables for SFA-TRANSLOG
data$ln_SALES <- log(data$SALES)
data$ln_EMPLOYEES  <- log(data$EMPLOYEES)
data$ln_USAGE_ELEC <- log(data$USAGE_ELEC)
data$ln_USAGE_NAT  <- log(data$USAGE_NAT)
data$ln_PRODHOURS  <- log(data$PRODHOURS)
data$ln_COST_ELEC  <- log(data$COST_ELEC)
data$ln_COST_NAT   <- log(data$COST_NAT)

# 7. SFA-TRANSLOG Model
sfa_translog <- frontier::sfa(
  ln_SALES ~
    ln_EMPLOYEES +
    ln_USAGE_ELEC +
    ln_USAGE_NAT +
    ln_PRODHOURS +
    ln_COST_ELEC +
    ln_COST_NAT +
    
    I(0.5 * ln_EMPLOYEES^2) +
    I(0.5 * ln_USAGE_ELEC^2) +
    I(0.5 * ln_USAGE_NAT^2) +
    I(0.5 * ln_PRODHOURS^2) +
    I(0.5 * ln_COST_ELEC^2) +
    I(0.5 * ln_COST_NAT^2) +
    
    I(ln_EMPLOYEES * ln_USAGE_ELEC) +
    I(ln_EMPLOYEES * ln_USAGE_NAT) +
    I(ln_EMPLOYEES * ln_PRODHOURS) +
    I(ln_EMPLOYEES * ln_COST_ELEC) +
    I(ln_EMPLOYEES * ln_COST_NAT) +
    
    I(ln_USAGE_ELEC * ln_USAGE_NAT) +
    I(ln_USAGE_ELEC * ln_PRODHOURS) +
    I(ln_USAGE_ELEC * ln_COST_ELEC) +
    I(ln_USAGE_ELEC * ln_COST_NAT) +
    
    I(ln_USAGE_NAT * ln_PRODHOURS) +
    I(ln_USAGE_NAT * ln_COST_ELEC) +
    I(ln_USAGE_NAT * ln_COST_NAT) +
    
    I(ln_PRODHOURS * ln_COST_ELEC) +
    I(ln_PRODHOURS * ln_COST_NAT) +
    
    I(ln_COST_ELEC * ln_COST_NAT),
  
  data = data, timeEffect = FALSE)
summary(sfa_translog)
data$SFA_TRANSLOG <- as.numeric(frontier::efficiencies(sfa_translog))

# 8. DEA Models - Input-Oriented
dea_crs <- Benchmarking::dea(X = x, Y = y, RTS = "crs", ORIENTATION = "in")
dea_vrs <- Benchmarking::dea(X = x, Y = y, RTS = "vrs", ORIENTATION = "in")
dea_irs <- Benchmarking::dea(X = x, Y = y, RTS = "irs", ORIENTATION = "in")
dea_drs <- Benchmarking::dea(X = x, Y = y, RTS = "drs", ORIENTATION = "in")

data$DEA_CRS <- as.numeric(Benchmarking::efficiencies(dea_crs))
data$DEA_VRS <- as.numeric(Benchmarking::efficiencies(dea_vrs))
data$DEA_IRS <- as.numeric(Benchmarking::efficiencies(dea_irs))
data$DEA_DRS <- as.numeric(Benchmarking::efficiencies(dea_drs))

# 9. Remove Temporary Log Columns
data <- data[, !(names(data) %in% c("ln_SALES", "ln_EMPLOYEES", "ln_USAGE_ELEC",
                                    "ln_USAGE_NAT", "ln_PRODHOURS",
                                    "ln_COST_ELEC", "ln_COST_NAT"))]

# 10. Print Summary
cat("\nSummary of Efficiency Scores:\n")
print(summary(data[, c("SFA_LOG", "SFA_TRANSLOG", "DEA_CRS", 
                       "DEA_VRS", "DEA_IRS", "DEA_DRS")]))

cat("\nNumber of Efficient DMUs:\n")
cat("DEA_CRS:", sum(round(data$DEA_CRS, 6) == 1), "\n")
cat("DEA_VRS:", sum(round(data$DEA_VRS, 6) == 1), "\n")
cat("DEA_IRS:", sum(round(data$DEA_IRS, 6) == 1), "\n")
cat("DEA_DRS:", sum(round(data$DEA_DRS, 6) == 1), "\n")

cat("\nMean Efficiency:\n")
cat("SFA_LOG:", mean(data$SFA_LOG, na.rm = TRUE), "\n")
cat("SFA_TRANSLOG:", mean(data$SFA_TRANSLOG, na.rm = TRUE), "\n")
cat("DEA_CRS:", mean(data$DEA_CRS, na.rm = TRUE), "\n")
cat("DEA_VRS:", mean(data$DEA_VRS, na.rm = TRUE), "\n")
cat("DEA_IRS:", mean(data$DEA_IRS, na.rm = TRUE), "\n")
cat("DEA_DRS:", mean(data$DEA_DRS, na.rm = TRUE), "\n")

# 11. Save Results
write_xlsx(data, output_file)
cat("\nResults saved successfully as:\n")
cat(output_file, "\n")