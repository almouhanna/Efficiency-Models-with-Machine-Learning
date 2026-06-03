import pandas as pd

# Read Excel File
input_file = "ITAC_Database_IQR.xlsx"
output_file = "ITAC_Database_Final.xlsx"
df = pd.read_excel(input_file)


# Remove Extra Spaces from Column Names
df.columns = df.columns.str.strip()

# Rename Columns
df = df.rename(columns={
    "FY": "FINA_YEAR",
    "EN_plant_cost": "COST_ENER"       
})

# Reorder Columns
df = df[[
    "ID",
    "FINA_YEAR",
    "STATE",
    "SALES",
    "EMPLOYEES",
    "COST_ENER",    
    "PRODHOURS"    
]]

# Save Final Excel File
df.to_excel(output_file, index=False)

# Print Confirmation
print("Columns renamed successfully.")
print("\nFinal column order:")
print(df.columns.tolist())
print(f"\nThe file was saved as:\n{output_file}")
