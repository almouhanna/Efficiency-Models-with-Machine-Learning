import pandas as pd

input_file = "State_Classification_Accuracy_Results_2.xlsx"
output_file = "Average_Accuracy_Table.xlsx"

df = pd.read_excel(
    input_file,
    sheet_name="All_State_Accuracy"
)

target_order = [
    "SFA_LOG",
    "SFA_TRANSLOG",
    "DEA_CRS",
    "DEA_VRS",
    "DEA_IRS",
    "DEA_DRS"
]

model_order = [
    "Logistic_Regression",
    "LDA",
    "QDA",
    "Naive_Bayes",
    "Decision_Tree",
    "Random_Forest",
    "SVM",
    "KNN"
]

table = df.pivot_table(
    index="Target",
    columns="Model",
    values="Accuracy",
    aggfunc="mean"
)

table = table.reindex(
    index=target_order,
    columns=model_order
)

table.to_excel(output_file)

print("Table saved successfully.")
print(table)
