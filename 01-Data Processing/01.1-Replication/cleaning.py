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

    # EMPLOYEES: from 50 to 460
    (df["EMPLOYEES"] >= 50) &
    (df["EMPLOYEES"] <= 460) &

    # EC_plant_usage: from 2478 to 17146886
    (df["EC_plant_usage"] >= 2478) &
    (df["EC_plant_usage"] <= 17146886) &

    # E2_plant_usage: from 1001 to 77212
    (df["E2_plant_usage"] >= 1001) &
    (df["E2_plant_usage"] <= 77212) &

    # PRODHOURS: from 2008 to 8763
    (df["PRODHOURS"] >= 2008) &
    (df["PRODHOURS"] <= 8763) &

    # EC_plant_cost: from 3581.00 to 602507.00
    (df["EC_plant_cost"] >= 3581.00) &
    (df["EC_plant_cost"] <= 602507.00) &

    # E2_plant_cost: from 38.00 to 249817.00
    (df["E2_plant_cost"] >= 38.00) &
    (df["E2_plant_cost"] <= 249817.00) &

    # SALES: from 10000.00 to 113000000.00
    (df["SALES"] >= 10000.00) &
    (df["SALES"] <= 113000000.00)

]

# Save cleaned dataset
cleaned_df.to_excel(output_file, index=False)

# Print results
print("Number of records before cleaning:", len(df))
print("Number of records after cleaning:", len(cleaned_df))
print("Number of deleted records:", len(df) - len(cleaned_df))
print(f"\nThe file was saved as:\n{output_file}")
