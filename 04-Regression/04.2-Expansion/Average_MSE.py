import pandas as pd

# أسماء الملفات
input_file = "State_Regression_MSE_Results.xlsx"
output_file = "Average_MSE_Table.xlsx"

# قراءة البيانات
df = pd.read_excel(
    input_file,
    sheet_name="All_State_MSE"
)

# ترتيب الصفوف والأعمدة
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

# إنشاء الجدول وحساب المتوسط
table = df.pivot_table(
    index="Target",
    columns="Model",
    values="MSE",
    aggfunc="mean"
)

# ترتيب الصفوف والأعمدة
table = table.reindex(
    index=target_order,
    columns=model_order
)

# حفظ الملف
table.to_excel(output_file)

print("Table saved successfully.")
print(table)
