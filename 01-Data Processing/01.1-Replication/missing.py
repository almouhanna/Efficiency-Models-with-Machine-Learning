import pandas as pd

# Name of input file 
input_file = "ITAC_Database_20260519.xlsx"

# Name of out put file
output_file = "ITAC_Database_NoMissing.xlsx"

df = pd.read_excel(input_file)

df.columns = df.columns.str.strip()

# Delete a record containing a missing code
cleaned_df = df.dropna().copy()

cleaned_df.to_excel(output_file, index=False)

print("Number of records before deleting missing values:", len(df))
print("Number of records after deleting missing values:", len(cleaned_df))
print("Number of deleted records:", len(df) - len(cleaned_df))

print(f"\nThe file was saved as:\n{output_file}")
