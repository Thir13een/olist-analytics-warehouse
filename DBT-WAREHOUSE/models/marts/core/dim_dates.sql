with date_bounds as (
    select
        min(date(purchased_at)) as min_date,
        max(date(purchased_at)) as max_date
    from {{ ref('fct_orders') }}
),

date_spine as (
    select date_day
    from date_bounds,
    unnest(generate_date_array(min_date, max_date)) as date_day
),

final as (
    select
        date_day,
        extract(year from date_day) as year_number,
        extract(quarter from date_day) as quarter_number,
        extract(month from date_day) as month_number,
        format_date('%Y-%m', date_day) as year_month,
        extract(week from date_day) as week_number,
        extract(day from date_day) as day_of_month,
        extract(dayofweek from date_day) as day_of_week_number,
        format_date('%A', date_day) as day_name,
        format_date('%B', date_day) as month_name,
        case
            when extract(dayofweek from date_day) in (1, 7) then true
            else false
        end as is_weekend
    from date_spine
)

select * from final
