-- models/intermediate/int_fuel_prices_eur.sql
-- ─────────────────────────────────────────────────────────
-- Intermediate: Fuel Prices in EUR
-- Joins staging fuel prices with FX rates
-- Calculates EUR prices
-- ─────────────────────────────────────────────────────────

with fuel as (

    select * from {{ ref('stg_fuel_prices') }}

),

fx as (

    select * from {{ ref('stg_fx_rates') }}

),

joined as (

    select
        -- Time
        fuel.price_date,
        fuel.price_year,
        fuel.price_month,

        -- USD prices
        fuel.price_usd_per_gallon,
        fuel.price_usd_per_tonne,

        -- FX rate
        fx.eur_usd_rate,
        fx.usd_eur_rate,

        -- EUR prices
        round(fuel.price_usd_per_gallon * fx.usd_eur_rate, 4)
                                                as price_eur_per_gallon,
        round(fuel.price_usd_per_tonne * fx.usd_eur_rate, 2)
                                                as price_eur_per_tonne

    from fuel
    left join fx
        on  fuel.price_year  = fx.rate_year
        and fuel.price_month = fx.rate_month

)

select * from joined