with order_items as (
    select * from {{ ref('fct_order_items') }}
),

sellers as (
    select * from {{ ref('dim_sellers') }}
),

final as (
    select
        sellers.seller_id,
        sellers.zip_code_prefix,
        sellers.city,
        sellers.state,
        count(*) as order_item_count,
        count(distinct order_items.order_id) as order_count,
        count(distinct order_items.product_id) as distinct_product_count,
        sum(order_items.price) as gross_sales_value,
        sum(order_items.freight_value) as freight_value,
        sum(order_items.order_item_value) as total_sales_value,
        avg(order_items.price) as avg_item_price,
        avg(order_items.avg_review_score) as avg_review_score,
        countif(order_items.is_delivered) as delivered_item_count,
        countif(order_items.is_late_delivery) as late_delivery_item_count
    from sellers
    left join order_items
        on sellers.seller_id = order_items.seller_id
    group by 1, 2, 3, 4
)

select * from final
