with customers as (
    select * from {{ ref('dim_customers') }}
),

final as (
    select
        customer_id,
        customer_unique_id,
        zip_code_prefix,
        city,
        state,
        order_count,
        delivered_order_count,
        canceled_order_count,
        first_order_at,
        last_order_at,
        lifetime_order_value,
        lifetime_payment_value,
        avg_order_review_score,
        case
            when order_count > 0 then lifetime_order_value / order_count
        end as avg_order_value,
        case
            when first_order_at is not null and last_order_at is not null
                then timestamp_diff(last_order_at, first_order_at, day)
        end as customer_lifespan_days,
        unique_customer_order_count > 1 as is_repeat_customer
    from customers
)

select * from final
