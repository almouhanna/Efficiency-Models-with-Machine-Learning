import pandas as pd

input_file = "State_Regression_MSE_Results.xlsx"
output_file = "State_MSE_Tables.xlsx"

df = pd.read_excel(input_file, sheet_name="All_State_MSE")

target_order = [
    "SFA_LOG",
    "SFA_TRANSLOG",
    "DEA_CRS",
    "DEA_VRS",
    "DEA_IRS",
    "DEA_DRS"
]

model_order = [
    "Multiple_Linear_Regression",
    "Regression_Tree",
    "Random_Forest",
    "Support_Vector_Regression",
    "KNN_Regression",
    "Ridge_Regression",
    "Lasso_Regression",
    "Elastic_Net"
]

with pd.ExcelWriter(output_file, engine="openpyxl") as writer:

    start_row = 0
    
    for state in sorted(df["STATE"].dropna().unique()):

        state_df = df[df["STATE"] == state]
        
        pivot_table = state_df.pivot_table(
            index="Target",
            columns="Model",
            values="MSE",
            aggfunc="first"
        )
        
        pivot_table = pivot_table.reindex(
            index=target_order,
            columns=model_order
        )
        
        pd.DataFrame([[f"STATE: {state}"]]).to_excel(
            writer,
            sheet_name="All_States",
            startrow=start_row,
            index=False,
            header=False
        )
        
        pivot_table.to_excel(
            writer,
            sheet_name="All_States",
            startrow=start_row + 1
        )
        
        start_row += len(pivot_table) + 4

print(f"Tables saved successfully to: {output_file}")
