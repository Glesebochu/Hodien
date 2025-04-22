import pandas as pd

# Read the CSV file
csv_file = 'backend/nlp_pipeline/data/test_detector.csv'  # Your input file
tsv_file = 'backend/nlp_pipeline/data/test_detector.tsv'  # Output file

# Load CSV into a DataFrame with proper handling of quoted fields and bad lines
df = pd.read_csv(csv_file, delimiter=',', quotechar='"', on_bad_lines='skip')

# Save as TSV (tab-separated)
df.to_csv(tsv_file, sep='\t', index=False)