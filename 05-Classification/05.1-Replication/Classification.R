library(readxl)
library(mlr3)
library(mlr3learners)
library(mlr3verse)

# Read Excel File
input_file <- "ITAC_Database_Classification_5.xlsx"
data <- read_excel(input_file)

# Remove Extra Spaces from Column Names
names(data) <- trimws(names(data))

# Convert Target Variables to Factor
target_vars <- c("SFA_LOG_cat", "SFA_TRANSLOG_cat", "DEA_CRS_cat",
                 "DEA_VRS_cat", "DEA_IRS_cat", "DEA_DRS_cat")
data[target_vars] <- lapply(data[target_vars], as.factor)

# Predictor Variables
predictors <- c("EMPLOYEES", "USAGE_ELEC", "USAGE_NAT", "PRODHOURS",
                "COST_ELEC", "COST_NAT", "SALES")

# Machine Learning Classification Models
learner_lda <- lrn("classif.lda")     # LDA
learner_dt <- lrn("classif.rpart")    # Decision Tree
learner_rf <- lrn("classif.ranger")   # Random Forest
learner_svm <- lrn("classif.svm")     # Support Vector Machine
learner_knn <- lrn("classif.kknn")    # K-Nearest Neighbor

# Combine Learners
learners <- list(learner_lda, learner_dt, learner_rf, learner_svm, learner_knn)

# Cross Validation
cv5 <- rsmp("cv", folds = 5)

# Run Classification for Each Target Variable
all_results <- list()

for (target_var in target_vars) {
  cat("\n====================================\n")
  cat("Target Variable:", target_var, "\n")
  cat("====================================\n")
  
  # Create Dataset
  selected_vars <- c(predictors, target_var)
  dfc <- data[, selected_vars]
  
  # Create Classification Task
  task <- TaskClassif$new(id = target_var, backend = dfc, target = target_var)
  
  # Benchmark Grid
  bm_grid <- benchmark_grid(tasks = task, learners = learners, resamplings = cv5)
  
  # Run Benchmark
  bm <- benchmark(bm_grid)
  
  # Aggregate Results
  results <- bm$aggregate(measures = msrs(c("classif.acc", "classif.ce")))
  
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
cat("FINAL CLASSIFICATION RESULTS\n")
cat("====================================\n")
print(final_results)

