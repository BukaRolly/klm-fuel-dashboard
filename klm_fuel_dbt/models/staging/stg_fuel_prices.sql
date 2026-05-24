-- models/staging/stg_fuel_prices.sql
-- ─────────────────────────────────────────────────────────
-- Staging: EIA Jet Fuel Prices
-- Source : klm_fuel_dashboard_data.jet_fuel_prices
-- What   : Cleans column names and casts data types
-- ─────────────────────────────────────────────────────────

with source as (

    select *
    from {{ source('klm_fuel_dashboard_data', 'jet_fuel_prices') }}

),

renamed as (

    select
        -- Time
        cast(concat(year_month, '-01') as date)                         as price_date,
        extract(year  from cast(concat(year_month, '-01') as date))     as price_year,
        extract(month from cast(concat(year_month, '-01') as date))     as price_month,

        -- Price
        cast(value as numeric)                                          as price_usd_per_gallon,

        -- Convert to USD per tonne
        -- 1 gallon jet fuel = 3.228 kg → 1 tonne = 309.76 gallons
        round(cast(value as numeric) * 309.76, 2)                       as price_usd_per_tonne

    from source
    where value is not null

)

select * from renamed