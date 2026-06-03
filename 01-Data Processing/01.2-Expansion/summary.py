import pandas as pd

# Input file name
input_file = "ITAC_Database_IQR.xlsx"

# Output file name
output_file = "Summary.xlsx"

df = pd.read_excel(input_file)

df.columns = df.columns.str.strip()

if "ID" in df.columns:
    df = df.drop(columns=["ID"])

numeric_df = df.select_dtypes(include=['number'])

# Calculate summary statistics
summary = pd.DataFrame({
    "Minimum": numeric_df.min(),
    "1st quartile": numeric_df.quantile(0.25),
    "Median": numeric_df.median(),
    "Mean": numeric_df.mean(),
    "3rd quartile": numeric_df.quantile(0.75),
    "Maximum": numeric_df.max()
})

summary.index.name = "Variable"
summary.reset_index(inplace=True)

summary.to_excel(output_file, index=False)

print("Summary statistics file created successfully.")
print(f"\nOutput file:\n{output_file}")
