with order_items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select * from {{ ref('fct_orders') }}
),

final as (
    select
        order_items.order_id,
        order_items.order_item_id,
        order_items.product_id,
        order_items.seller_id,
        orders.customer_id,
        orders.order_status,
        orders.purchased_at,
        orders.approved_at,
        orders.shipped_at,
        orders.delivered_at,
        orders.estimated_delivery_at,
        order_items.shipping_limit_at,
        order_items.price,
        order_items.freight_value,
        order_items.price + order_items.freight_value as order_item_value,
        orders.payment_count,
        orders.payment_value as order_payment_value,
        orders.review_count,
        orders.avg_review_score,
        orders.is_delivered,
        orders.is_canceled,
        orders.is_unavailable,
        orders.is_late_delivery,
        case
            when orders.shipped_at is not null then timestamp_diff(orders.shipped_at, orders.purchased_at, hour)
        end as shipping_lead_hours,
        case
            when orders.delivered_at is not null then timestamp_diff(orders.delivered_at, orders.purchased_at, hour)
        end as delivery_lead_hours
    from order_items
    inner join orders
        on order_items.order_id = orders.order_id
)

select * from final
