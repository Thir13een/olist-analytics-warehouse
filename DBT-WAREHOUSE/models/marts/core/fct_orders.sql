with orders as (
    select * from {{ ref('int_orders') }}
),

final as (
    select
        order_id,
        customer_id,
        order_status,
        purchased_at,
        approved_at,
        shipped_at,
        delivered_at,
        estimated_delivery_at,
        order_item_count,
        distinct_product_count,
        distinct_seller_count,
        gross_item_value,
        freight_value,
        gross_item_value + freight_value as order_value,
        payment_count,
        payment_value,
        max_payment_sequential,
        max_payment_installments,
        review_count,
        avg_review_score,
        min_review_score,
        max_review_score,
        latest_review_created_at,
        latest_review_answered_at,
        reviews_with_title_count,
        reviews_with_message_count,
        first_shipping_limit_at,
        last_shipping_limit_at,
        order_status = 'delivered' as is_delivered,
        order_status = 'canceled' as is_canceled,
        order_status = 'unavailable' as is_unavailable,
        order_item_count > 0 as has_order_items,
        payment_count > 0 as has_payment,
        review_count > 0 as has_review,
        case
            when approved_at is not null then timestamp_diff(approved_at, purchased_at, hour)
        end as approval_lead_hours,
        case
            when shipped_at is not null then timestamp_diff(shipped_at, purchased_at, hour)
        end as shipping_lead_hours,
        case
            when delivered_at is not null then timestamp_diff(delivered_at, purchased_at, hour)
        end as delivery_lead_hours,
        case
            when estimated_delivery_at is not null then timestamp_diff(estimated_delivery_at, purchased_at, hour)
        end as estimated_delivery_lead_hours,
        case
            when delivered_at is not null and estimated_delivery_at is not null
                then timestamp_diff(delivered_at, estimated_delivery_at, day)
        end as delivered_vs_estimated_days,
        case
            when delivered_at is not null and estimated_delivery_at is not null
                then delivered_at > estimated_delivery_at
        end as is_late_delivery
    from orders
)

select * from final
