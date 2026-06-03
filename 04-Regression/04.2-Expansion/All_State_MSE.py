import pandas as pd

# أسماء الملفات
input_file = "State_Regression_MSE_Results.xlsx"
output_file = "State_MSE_Tables.xlsx"

# قراءة البيانات من الورقة المطلوبة
df = pd.read_excel(input_file, sheet_name="All_State_MSE")

# ترتيب الصفوف والأعمدة بالشكل المطلوب
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

# إنشاء ملف الإخراج
with pd.ExcelWriter(output_file, engine="openpyxl") as writer:

    start_row = 0

    # المرور على جميع الولايات
    for state in sorted(df["STATE"].dropna().unique()):

        state_df = df[df["STATE"] == state]

        # إنشاء الجدول
        pivot_table = state_df.pivot_table(
            index="Target",
            columns="Model",
            values="MSE",
            aggfunc="first"
        )

        # ترتيب الصفوف والأعمدة
        pivot_table = pivot_table.reindex(
            index=target_order,
            columns=model_order
        )

        # كتابة اسم الولاية
        pd.DataFrame([[f"STATE: {state}"]]).to_excel(
            writer,
            sheet_name="All_States",
            startrow=start_row,
            index=False,
            header=False
        )

        # كتابة الجدول
        pivot_table.to_excel(
            writer,
            sheet_name="All_States",
            startrow=start_row + 1
        )

        # الانتقال إلى مكان الجدول التالي
        start_row += len(pivot_table) + 4

print(f"Tables saved successfully to: {output_file}")
