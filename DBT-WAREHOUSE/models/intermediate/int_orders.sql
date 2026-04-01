with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

reviews as (
    select * from {{ ref('stg_reviews') }}
),

order_item_agg as (
    select
        order_id,
        count(*) as order_item_count,
        count(distinct product_id) as distinct_product_count,
        count(distinct seller_id) as distinct_seller_count,
        sum(price) as gross_item_value,
        sum(freight_value) as freight_value,
        min(shipping_limit_at) as first_shipping_limit_at,
        max(shipping_limit_at) as last_shipping_limit_at
    from order_items
    group by 1
),

payment_agg as (
    select
        order_id,
        count(*) as payment_count,
        sum(payment_value) as payment_value,
        max(payment_sequential) as max_payment_sequential,
        max(payment_installments) as max_payment_installments
    from payments
    group by 1
),

review_agg as (
    select
        order_id,
        count(*) as review_count,
        avg(cast(review_score as numeric)) as avg_review_score,
        min(review_score) as min_review_score,
        max(review_score) as max_review_score,
        max(created_at) as latest_review_created_at,
        max(answered_at) as latest_review_answered_at,
        countif(review_comment_title is not null) as reviews_with_title_count,
        countif(review_comment_message is not null) as reviews_with_message_count
    from reviews
    group by 1
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_status,
        orders.purchased_at,
        orders.approved_at,
        orders.shipped_at,
        orders.delivered_at,
        orders.estimated_delivery_at,
        coalesce(order_item_agg.order_item_count, 0) as order_item_count,
        coalesce(order_item_agg.distinct_product_count, 0) as distinct_product_count,
        coalesce(order_item_agg.distinct_seller_count, 0) as distinct_seller_count,
        coalesce(order_item_agg.gross_item_value, 0) as gross_item_value,
        coalesce(order_item_agg.freight_value, 0) as freight_value,
        order_item_agg.first_shipping_limit_at,
        order_item_agg.last_shipping_limit_at,
        coalesce(payment_agg.payment_count, 0) as payment_count,
        coalesce(payment_agg.payment_value, 0) as payment_value,
        coalesce(payment_agg.max_payment_sequential, 0) as max_payment_sequential,
        coalesce(payment_agg.max_payment_installments, 0) as max_payment_installments,
        coalesce(review_agg.review_count, 0) as review_count,
        review_agg.avg_review_score,
        review_agg.min_review_score,
        review_agg.max_review_score,
        review_agg.latest_review_created_at,
        review_agg.latest_review_answered_at,
        coalesce(review_agg.reviews_with_title_count, 0) as reviews_with_title_count,
        coalesce(review_agg.reviews_with_message_count, 0) as reviews_with_message_count
    from orders
    left join order_item_agg
        on orders.order_id = order_item_agg.order_id
    left join payment_agg
        on orders.order_id = payment_agg.order_id
    left join review_agg
        on orders.order_id = review_agg.order_id
)

select * from final
