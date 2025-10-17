import pandas as pd

# Loads the dataset
x = "railway.xlsx" 
df = pd.read_excel(x, sheet_name="railway")

# Store the results
validation_results = {}

# Duplicates
duplicates = df[df['Transaction ID'].duplicated(keep=False)]
validation_results['Transaction_ID_duplicates'] = len(duplicates)
if len(duplicates) > 0:
    print("\n Duplicate transaction IDs found:")
    print(duplicates)

# Null check
imp_columns = [
    'Transaction ID','Date of Purchase','Time of Purchase','Date of Journey',
    'Departure Time','Arrival Time','Actual Arrival Time','Price',
    'Purchase Type','Payment Method','Ticket Class','Ticket Type','Journey Status'
]
nulls = {col: df[col].isna().sum() for col in imp_columns}
validation_results['Nulls'] = nulls
for col, count in nulls.items():
    if count > 0:
        print(f"\n Column '{col}' has {count} null values:")
        print(df[df[col].isna()])

# Primary key check 
validation_results['Transaction_ID_unique'] = df['Transaction ID'].is_unique
validation_results['Transaction_ID_not_null'] = df['Transaction ID'].notna().all()

# Price check
bad_price = df[(df['Price'].isna()) | (df['Price'] < 0)]
if not bad_price.empty:
    print("\n Invalid price values (null or negative):")
    print(bad_price)

# Summary
print("\n Validation summary:")
for check, result in validation_results.items():
    print(f"{check}: {result}")

