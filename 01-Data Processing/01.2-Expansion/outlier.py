import pandas as pd

# Name of input file 
input_file = "ITAC_Database_Cleaned.xlsx"

# Name of out put file
output_file = "ITAC_Database_IQR.xlsx"

df = pd.read_excel(input_file)

df.columns = df.columns.str.strip()

numeric_columns = df.select_dtypes(include=['number']).columns

cleaned_df = df.copy()

# Apply Boxplot (IQR)
for col in numeric_columns:

    Q1 = cleaned_df[col].quantile(0.25)
    Q3 = cleaned_df[col].quantile(0.75)

    IQR = Q3 - Q1

    lower_bound = Q1 - 1.5 * IQR
    upper_bound = Q3 + 1.5 * IQR

    cleaned_df = cleaned_df[
        (cleaned_df[col] >= lower_bound) &
        (cleaned_df[col] <= upper_bound)
    ]

cleaned_df.to_excel(output_file, index=False)

print("Number of records before deleting outlier:", len(df))
print("Number of records after deleting outlier:", len(cleaned_df))
print("Number of deleted records:", len(df) - len(cleaned_df))

print(f"\nThe file was saved as:\n{output_file}")
