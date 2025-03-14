#!/usr/bin/env python3
import pandas as pd
import argparse

def get_tax(df, level = "g", taxcol = "clade_name") -> pd.DataFrame:
    tax = "kpcofgst"
    
    if level not in tax:
        raise ValueError(f"Invalid taxonomic level: '{level}'. Choose from {list(tax)}")
    
    pos = tax.index(level)
    
    # Filter rows containing the specified taxonomic level while excluding deeper levels
    next_level = tax[pos + 1] if pos + 1 < len(tax) else None
    df = df[df[taxcol].str.contains(f"{level}__")]
    if next_level:
        df = df[~df[taxcol].str.contains(f"{next_level}__")]

    # Create empty columns for taxonomic levels up to the selected level
    tax_levels = list(tax[: pos + 1])
    for tx in tax_levels:
        df[tx] = pd.NA

    # Extract taxonomic names using `.apply()`
    def extract_taxonomy(row):
        tax_dict = {tx.split("__")[0]: tx.split("__")[1] for tx in row.split("|") if "__" in tx}
        return pd.Series([tax_dict.get(t, pd.NA) for t in tax_levels], index=tax_levels)
    
    df[tax_levels] = df[taxcol].apply(extract_taxonomy)

    return df.drop(columns = [taxcol])


def reformat(df) -> pd.DataFrame:
    samples = df.columns[df.dtypes != object]
    tax = df.columns[df.dtypes == object]
    long_df = pd.melt(
        df,
        id_vars = tax, value_vars = samples,
        value_name = "reads", var_name = "sample"
    )
    long_df = long_df.sort_values(by = ["reads"], ascending = False).reset_index(drop = True)

    return long_df

def main():
    parser = argparse.ArgumentParser(description="Process Metaphlan abundance table and extract taxonomic levels.")
    parser.add_argument("-i", "--input", type = str, required = True,
                        help = "Path to the Metaphlan abundance table (TSV format).")
    parser.add_argument("-l", "--levels", type = str, default = "PFGS",
                        help="Taxonomic levels to extract (default: 'PFGS'). Choose from 'KPCOFGST'.")

    args = parser.parse_args()

    # Read input file, skipping the first row
    metaphlan_df = pd.read_csv(args.input, sep = "\t", skiprows = 1)

    # Process selected taxonomic levels
    for tax in args.levels:
        tx = tax.lower()
        df = get_tax(metaphlan_df, level = tx)
        df = reformat(df)
        output_file = f"{tax}_counts.csv"
        df.to_csv(output_file, index=False)
        print(f"Saved: {output_file}")

if __name__ == "__main__":
    main()