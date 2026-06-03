import pandas as pd

# Input file name
input_file = "ITAC_Database_Cleaned.xlsx"

# Output file name
output_file = "Summary.xlsx"

df = pd.read_excel(input_file)

df.columns = df.columns.str.strip()

# Remove ID column if it exists
if "ID" in df.columns:
    df = df.drop(columns=["ID"])

numeric_df = df.select_dtypes(include=['number'])

# Create summary statistics table
summary = pd.DataFrame({
    "Minimum": numeric_df.min(),
    "1st quartile": numeric_df.quantile(0.25),
    "Median": numeric_df.median(),
    "Mean": numeric_df.mean(),
    "3rd quartile": numeric_df.quantile(0.75),
    "Maximum": numeric_df.max()
})

summary = summary.T

summary = summary.applymap(lambda x: f"{x:,.2f}")

summary.index.name = "Statistics"

with pd.ExcelWriter(output_file, engine='openpyxl') as writer:
    summary.to_excel(writer, sheet_name='Summary')

print("Summary statistics file created successfully.")
print(f"\nOutput file:\n{output_file}")
