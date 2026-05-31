-- models/marts/fct_fuel_prices.sql
-- ─────────────────────────────────────────────────────────
-- Mart: Final Fuel Price Fact Table
-- This is what Power BI connects to
-- ─────────────────────────────────────────────────────────

with base as (

    select * from {{ ref('int_fuel_prices_eur') }}

),

annual_avg as (

    select
        price_year,
        round(avg(price_usd_per_tonne), 2)  as annual_avg_usd_per_tonne,
        round(avg(price_eur_per_tonne), 2)  as annual_avg_eur_per_tonne
    from base
    group by price_year

),

baseline as (

    select round(avg(price_usd_per_tonne), 2) as baseline_price
    from base
    where price_year = 2019

),

final as (

    select
        -- Time
        base.price_date,
        base.price_year,
        base.price_month,
        format_date('%b %Y', base.price_date)       as month_label,

        -- Price regime labels
        case
            when base.price_date between '2020-03-01' and '2020-12-01'
                then 'COVID Demand Collapse'
            when base.price_date between '2021-01-01' and '2021-12-01'
                then 'Recovery'
            when base.price_date between '2022-02-01' and '2022-12-01'
                then 'Ukraine War Spike'
            when base.price_date between '2023-01-01' and '2023-12-01'
                then 'Post-Spike Normalisation'
            when base.price_year >= 2024
                then 'Current'
            else 'Pre-COVID'
        end                                         as price_regime,

        -- USD prices
        base.price_usd_per_gallon,
        base.price_usd_per_tonne,

        -- EUR prices
        base.price_eur_per_gallon,
        round(base.price_eur_per_gallon / 3.78541, 4) as price_eur_per_litre,
        base.price_eur_per_tonne,

        -- FX
        base.eur_usd_rate,
        base.usd_eur_rate,

        -- YoY change
        round(
            (base.price_usd_per_tonne - lag(base.price_usd_per_tonne, 12)
                over (order by base.price_date))
            / nullif(lag(base.price_usd_per_tonne, 12)
                over (order by base.price_date), 0) * 100,
        2)                                          as price_yoy_pct_change,

        -- Annual averages
        annual_avg.annual_avg_usd_per_tonne,
        annual_avg.annual_avg_eur_per_tonne,

        -- Index 2019 = 100
        round(base.price_usd_per_tonne / baseline.baseline_price * 100, 1)
                                                    as price_index_2019_100

    from base
    left join annual_avg using (price_year)
    cross join baseline

)

select * from final
order by price_date