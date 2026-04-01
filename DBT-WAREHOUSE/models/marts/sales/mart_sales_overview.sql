with orders as (
    select * from {{ ref('fct_orders') }}
),

final as (
    select
        date(purchased_at) as order_date,
        count(*) as order_count,
        countif(is_delivered) as delivered_order_count,
        countif(is_canceled) as canceled_order_count,
        countif(is_unavailable) as unavailable_order_count,
        countif(has_review) as reviewed_order_count,
        countif(is_late_delivery) as late_delivery_order_count,
        sum(order_item_count) as total_items_sold,
        sum(order_value) as total_order_value,
        sum(payment_value) as total_payment_value,
        avg(order_value) as avg_order_value,
        avg(payment_value) as avg_payment_value,
        avg(avg_review_score) as avg_review_score,
        avg(approval_lead_hours) as avg_approval_lead_hours,
        avg(shipping_lead_hours) as avg_shipping_lead_hours,
        avg(delivery_lead_hours) as avg_delivery_lead_hours,
        avg(delivered_vs_estimated_days) as avg_delivered_vs_estimated_days
    from orders
    group by 1
)

select * from final
