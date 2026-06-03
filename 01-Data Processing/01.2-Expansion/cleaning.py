import pandas as pd

# Name of input file
input_file = "ITAC_Database_NoMissing.xlsx"

# Name of output file
output_file = "ITAC_Database_Cleaned.xlsx"

# Read Excel file
df = pd.read_excel(input_file)

# Remove extra spaces from column names
df.columns = df.columns.str.strip()

# Data cleaning based on value ranges
cleaned_df = df[
    # EMPLOYEES: 
    (df["EMPLOYEES"] >= 50) &
    
    # PRODHOURS: 
    (df["PRODHOURS"] > 2000) &

    # EN_plant_cost:
    (df["EN_plant_cost"] > 0) &    
    
    # SALES: 
    (df["SALES"] > 10000.00)
]

# Save cleaned dataset
cleaned_df.to_excel(output_file, index=False)

# Print results
print("Number of records before cleaning:", len(df))
print("Number of records after cleaning:", len(cleaned_df))
print("Number of deleted records:", len(df) - len(cleaned_df))
print(f"\nThe file was saved as:\n{output_file}")
