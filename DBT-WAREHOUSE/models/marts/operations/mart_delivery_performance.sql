with orders as (
    select * from {{ ref('fct_orders') }}
),

final as (
    select
        date(purchased_at) as order_date,
        order_status,
        count(*) as order_count,
        countif(is_delivered) as delivered_order_count,
        countif(is_late_delivery) as late_delivery_order_count,
        avg(approval_lead_hours) as avg_approval_lead_hours,
        avg(shipping_lead_hours) as avg_shipping_lead_hours,
        avg(delivery_lead_hours) as avg_delivery_lead_hours,
        avg(delivered_vs_estimated_days) as avg_delivered_vs_estimated_days
    from orders
    group by 1, 2
)

select * from final
