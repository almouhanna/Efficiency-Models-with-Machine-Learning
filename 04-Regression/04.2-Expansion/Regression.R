library(readxl)
library(mlr3)
library(mlr3learners)
library(mlr3verse)

# Read Excel File
input_file <- "ITAC_Database_Regression.xlsx"
data <- read_excel(input_file)

# Remove Extra Spaces from Column Names
names(data) <- trimws(names(data))

# Target Variables
target_vars <- c("SFA_LOG", "SFA_TRANSLOG", "DEA_CRS",
                 "DEA_VRS", "DEA_IRS", "DEA_DRS")

# Predictor Variables
predictors <- c("EMPLOYEES", "USAGE_ELEC", "USAGE_NAT",
                "PRODHOURS", "COST_ELEC", "COST_NAT", "SALES")

# Machine Learning Learners
learnerA <- lrn("regr.lm")
learnerB <- lrn("regr.rpart", minsplit = 20, cp = 0.01, maxdepth = 30)
learnerC <- lrn("regr.ranger", num.trees = 500) # , alpha = 0.5
learnerD <- lrn("regr.svm", kernel = "radial")
learnerE <- lrn("regr.kknn", k = 7)

learners <- list(learnerA, learnerB, learnerC, learnerD, learnerE)

# Cross Validation
cv5 <- rsmp("cv", folds = 5)

# Run Benchmark for Each Target Variable
all_results <- list()

for (target_var in target_vars) {
  cat("\n====================================\n")
  cat("Target Variable:", target_var, "\n")
  cat("====================================\n")
  
  # Create Dataset
  selected_vars <- c(predictors, target_var)
  df <- data[, selected_vars]
  
  # Create Regression Task
  task <- TaskRegr$new(id = target_var, backend = df, target = target_var)
  
  # Benchmark Grid
  bm_grid <- benchmark_grid(tasks = task, learners = learners, 
                            resamplings = cv5)
  
  # Run Benchmark
  bm <- benchmark(bm_grid)
  
  # Aggregate Results
  results <- bm$aggregate(measures = msrs(c("regr.mse", "regr.rmse",
                                            "regr.mae", "regr.bias",
                                            "regr.srho", "regr.rsq")))
  
  # Add Target Variable Name
  results$Target <- target_var
  
  # Print Results
  print(results)
  
  # Store Results
  all_results[[target_var]] <- results
}

# Combine All Results
final_results <- do.call(rbind, all_results)

# Print Final Results
cat("\n====================================\n")
cat("FINAL RESULTS\n")
cat("====================================\n")
print(final_results)