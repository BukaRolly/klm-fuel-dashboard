import requests
import pandas as pd
from dotenv import load_dotenv
import os

load_dotenv(os.path.join(os.path.dirname(__file__), '..', '.env'))

def extract_fuel_prices():

    url = "https://api.eia.gov/v2/petroleum/pri/spt/data/"

    params = {
        "api_key": os.getenv("FUEL_PRICE_API_KEY"),
        "frequency": "monthly",
        "data[0]": "value",
        "facets[series][]": "EER_EPJK_PF4_RGC_DPG",
        "start": "2015-01",
        "length": 5000
    }

    response = requests.get(url, params=params)
    print("EIA Status:", response.status_code)

    rows = response.json()["response"]["data"]
    df_fuel_prices = pd.DataFrame(rows)

    # Convert value column to numeric first so we can do math on it
    df_fuel_prices["value"] = pd.to_numeric(df_fuel_prices["value"])

    # Add new column: price per litre (divide by 3.78541)
    df_fuel_prices["value_per_litre"] = df_fuel_prices["value"] / 3.78541

    # Rename Date column to Year Month
    df_fuel_prices=df_fuel_prices.rename(columns={"period": "year_month"})

    print(f"Rows extracted: {len(df_fuel_prices)}")

    return df_fuel_prices

if __name__ == "__main__":
    extract_fuel_prices()