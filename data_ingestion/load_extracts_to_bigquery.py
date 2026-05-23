from google.cloud import bigquery
from dotenv import load_dotenv
import os

# Load .env from root folder
load_dotenv(os.path.join(os.path.dirname(__file__), '..', '.env'))

def load_to_bigquery(df, table_name):

    project_id  = os.getenv("GCP_PROJECT_ID")
    dataset_id  = os.getenv("GCP_DATASET_ID")
    credentials = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")

    # Debug — confirm everything is loading
    print(f"Project  : {project_id}")
    print(f"Dataset  : {dataset_id}")
    print(f"Key file : {credentials}")

    # Create BigQuery client
    client = bigquery.Client(project=project_id)

    # Full table reference
    table_ref = f"{project_id}.{dataset_id}.{table_name}"

    # Load config — WRITE_TRUNCATE means overwrite if table already exists
    job_config = bigquery.LoadJobConfig(
        write_disposition="WRITE_TRUNCATE",
        autodetect=True        # BigQuery figures out column types automatically
    )

    # Load the DataFrame into BigQuery
    job = client.load_table_from_dataframe(df, table_ref, job_config=job_config)
    job.result()  # wait until done

    print(f"Loaded {len(df)} rows into {table_ref}")

if __name__ == "__main__":
    from extract_fuel_prices import extract_fuel_prices
    from extract_fx_rates import extract_fx_rates

    # Extract fuel prices
    df_fuel = extract_fuel_prices()

    # Then load
    load_to_bigquery(df_fuel, "jet_fuel_prices")

    # Extract fuel prices
    df_fx_rates = extract_fx_rates()

    # Then load
    load_to_bigquery(df_fx_rates, "fx_rates")