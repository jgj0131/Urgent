import pandas as pd

# List of file paths
file_paths = [
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-2.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-3.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-4.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-5.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-6.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-7.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-8.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-9.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-10.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-11.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-12.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-13.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-14.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-15.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-16.xlsx',
    '/Users/janggukjin/Downloads/12_04_01_E_%EA%B3%B5%EC%A4%91%ED%99%94%EC%9E%A5%EC%8B%A4%EC%A0%95%EB%B3%B4-17.xlsx'
]

# Read each Excel file and append to a list of DataFrames

dfs = [pd.read_excel(file, engine='openpyxl') for file in file_paths]

# Concatenate all DataFrames into one
combined_df = pd.concat(dfs, ignore_index=True)

# Save the combined DataFrame to a new Excel file
combined_df.to_excel('combined_output.xlsx', index=False)

print("Files have been combined successfully!")
