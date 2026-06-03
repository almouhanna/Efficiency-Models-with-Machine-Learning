# ==========================================================
# State-Level Classification Accuracy Results
# 8 Classification Models
# Logistic Regression + LDA + QDA + Naive Bayes
# Decision Tree + Random Forest + SVM + KNN
# ==========================================================

library(readxl)
library(dplyr)
library(mlr3)
library(mlr3learners)
library(mlr3verse)
library(openxlsx)

# 1. Read Excel File
input_file <- "ITAC_Database_State_Classification_2.xlsx"
data <- read_excel(input_file)

# Remove extra spaces from column names
names(data) <- trimws(names(data))

# 2. Define Variables
state_col <- "STATE"
target_vars <- c("SFA_LOG", "SFA_TRANSLOG", "DEA_CRS",
                 "DEA_VRS", "DEA_IRS", "DEA_DRS")
predictors <- c("SALES", "EMPLOYEES", "COST_ENER", "PRODHOURS")

# Convert target variables to factors
data[target_vars] <- lapply(data[target_vars], as.factor)

# 3. Define Classification Models
learners <- list(
  lrn("classif.multinom", predict_type = "response"),
  lrn("classif.lda", predict_type = "response"),
  lrn("classif.qda", predict_type = "response"),
  lrn("classif.naive_bayes", predict_type = "response"),
  lrn("classif.rpart", predict_type = "response"),
  lrn("classif.ranger", predict_type = "response"),
  lrn("classif.svm", predict_type = "response"),
  lrn("classif.kknn", predict_type = "response")
)

model_names <- c("Logistic_Regression", "LDA", "QDA", "Naive_Bayes",
                 "Decision_Tree", "Random_Forest", "SVM", "KNN")
names(learners) <- model_names

# 4. Cross Validation
cv5 <- rsmp("cv", folds = 5)

# 5. Run Classification by State and Target
all_results <- list()
error_log <- list()
states <- sort(unique(data[[state_col]]))
for (state in states) {
  cat("\n====================================\n")
  cat("STATE:", state, "\n")
  cat("====================================\n")
  
  state_data <- data %>% filter(.data[[state_col]] == state)
  for (target_var in target_vars) {
    
    cat("Target:", target_var, "\n")
    selected_vars <- c(predictors, target_var)
    dfc <- state_data[, selected_vars]
    dfc <- na.omit(dfc)
    dfc[[target_var]] <- as.factor(dfc[[target_var]])
    
    if (length(unique(dfc[[target_var]])) < 2) {
      error_log[[length(error_log) + 1]] <- data.frame(
        STATE = state, Target = target_var, Model = NA,
        Issue = "Skipped: target has less than 2 classes")
      next
    }
    if (nrow(dfc) < 5) {
      error_log[[length(error_log) + 1]] <- data.frame(
        STATE = state, Target = target_var, Model = NA,
        Issue = "Skipped: fewer than 5 rows")
      next
    }
    task <- TaskClassif$new(
      id = paste(state, target_var, sep = "_"),
      backend = dfc, target = target_var)
    for (model_name in model_names) {
      learner <- learners[[model_name]]$clone()
      result_row <- tryCatch({
        rr <- resample(task = task, learner = learner,
                       resampling = cv5, store_models = FALSE)
        acc <- rr$aggregate(msr("classif.acc"))
        data.frame(STATE = state, Target = target_var,
                   Model = model_name, Accuracy = acc)
      }, error = function(e) {
        error_log[[length(error_log) + 1]] <<- data.frame(
          STATE = state, Target = target_var,
          Model = model_name, Issue = e$message)
        data.frame(STATE = state, Target = target_var,
                   Model = model_name, Accuracy = NA)
      })
      all_results[[length(all_results) + 1]] <- result_row
    }
  }
}

# 6. Combine Results
final_results <- bind_rows(all_results)
average_accuracy_by_model <- final_results %>% group_by(Model) %>%
  summarise(Average_Accuracy = mean(Accuracy, na.rm = TRUE),
            .groups = "drop") %>% arrange(desc(Average_Accuracy))
average_accuracy_by_target <- final_results %>% group_by(Target) %>%
  summarise(Average_Accuracy = mean(Accuracy, na.rm = TRUE),
            .groups = "drop") %>% arrange(desc(Average_Accuracy))
average_accuracy_by_state <- final_results %>% group_by(STATE) %>%
  summarise(Average_Accuracy = mean(Accuracy, na.rm = TRUE),
            .groups = "drop") %>% arrange(desc(Average_Accuracy))
if (length(error_log) > 0) {
  error_results <- bind_rows(error_log)
} else {
  error_results <- data.frame(Message = "No errors or skipped cases")
}

# 7. Export Results to Excel
output_file <- "State_Classification_Accuracy_Results.xlsx"

wb <- createWorkbook()

addWorksheet(wb, "All_State_Accuracy")
writeData(wb, "All_State_Accuracy", final_results)

addWorksheet(wb, "Average_Accuracy_By_Model")
writeData(wb, "Average_Accuracy_By_Model", average_accuracy_by_model)

addWorksheet(wb, "Average_Accuracy_By_Target")
writeData(wb, "Average_Accuracy_By_Target", average_accuracy_by_target)

addWorksheet(wb, "Average_Accuracy_By_State")
writeData(wb, "Average_Accuracy_By_State", average_accuracy_by_state)

addWorksheet(wb, "Errors_and_Skipped")
writeData(wb, "Errors_and_Skipped", error_results)

for (sheet in names(wb)) {
  freezePane(wb, sheet, firstRow = TRUE)
  setColWidths(wb, sheet, cols = 1:20, widths = "auto")
}

saveWorkbook(wb, output_file, overwrite = TRUE)

# 8. Print Summary
cat("\n====================================\n")
cat("FINAL CLASSIFICATION ACCURACY RESULTS SAVED\n")
cat("====================================\n")
cat("Output file:", output_file, "\n\n")

print(average_accuracy_by_model)

