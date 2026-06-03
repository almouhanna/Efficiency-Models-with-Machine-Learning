import pandas as pd

# Read Excel File
input_file = "ITAC_Database_Cleaned.xlsx"
output_file = "ITAC_Database_Final.xlsx"
df = pd.read_excel(input_file)


# Remove Extra Spaces from Column Names
df.columns = df.columns.str.strip()

# Rename Columns
df = df.rename(columns={
    "EC_plant_cost": "COST_ELEC",
    "EC_plant_usage": "USAGE_ELEC",

    "E2_plant_cost": "COST_NAT",
    "E2_plant_usage": "USAGE_NAT"
})

# Reorder Columns
df = df[[
    "ID",
    "SALES",
    "EMPLOYEES",
    "USAGE_ELEC",
    "USAGE_NAT",
    "PRODHOURS",
    "COST_ELEC",
    "COST_NAT"
]]

# Save Final Excel File
df.to_excel(output_file, index=False)

# Print Confirmation
print("Columns renamed successfully.")
print("\nFinal column order:")
print(df.columns.tolist())
print(f"\nThe file was saved as:\n{output_file}")
