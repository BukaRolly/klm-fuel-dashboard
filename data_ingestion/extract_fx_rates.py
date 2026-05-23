import requests
import pandas as pd
from dotenv import load_dotenv
import os

load_dotenv(os.path.join(os.path.dirname(__file__), '..', '.env'))

def extract_fx_rates():

    url = "https://data-api.ecb.europa.eu/service/data/EXR/M.USD.EUR.SP00.A"

    params = {
        "format": "jsondata",
        "startPeriod": "2015-01"
    }

    response = requests.get(url, params=params)
    print("ECB Status:", response.status_code)

    data = response.json()

    # Get dates from structure
    dates = data["structure"]["dimensions"]["observation"][0]["values"]

    # Get observations from dataSets
    observations = data["dataSets"][0]["series"]["0:0:0:0:0"]["observations"]

    # Combine them into rows
    rows = []
    for index, values in observations.items():
        rows.append({
            "month":        dates[int(index)]["id"],   # "2015-01"
            "eur_usd_rate": values[0]                  # 1.1621
        })

    # Turn into DataFrame
    df_fx_rates = pd.DataFrame(rows)

    # Add inverse rate — USD per EUR to EUR per USD
    df_fx_rates["usd_eur_rate"] = 1 / df_fx_rates["eur_usd_rate"]

    # Rename Date column to Year Month
    df_fx_rates=df_fx_rates.rename(columns={"month": "year_month"})

    print(f"Rows extracted: {len(df_fx_rates)}")

    return df_fx_rates

if __name__ == "__main__":
    extract_fx_rates()