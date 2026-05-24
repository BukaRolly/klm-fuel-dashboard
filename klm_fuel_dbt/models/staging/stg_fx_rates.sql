-- models/staging/stg_fx_rates.sql
-- ─────────────────────────────────────────────────────────
-- Staging: ECB EUR/USD Exchange Rates
-- Source : klm_fuel_dashboard_data.fx_rates
-- What   : Cleans column names and adds inverse rate
-- ─────────────────────────────────────────────────────────

with source as (

    select *
    from {{ source('klm_fuel_dashboard_data', 'fx_rates') }}

),

renamed as (

    select
       -- Time
        cast(concat(year_month, '-01') as date)              as rate_date,
        extract(year  from cast(concat(year_month, '-01') as date))  as rate_year,
        extract(month from cast(concat(year_month, '-01') as date))  as rate_month,

        -- Rate
        cast(eur_usd_rate as numeric)               as eur_usd_rate,

        -- Inverse rate — EUR per 1 USD
        round(1.0 / cast(eur_usd_rate as numeric), 6)
                                                    as usd_eur_rate

    from source
    where eur_usd_rate is not null

)

select * from renamed