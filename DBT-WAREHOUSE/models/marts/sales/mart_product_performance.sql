with order_items as (
    select * from {{ ref('fct_order_items') }}
),

products as (
    select * from {{ ref('dim_products') }}
),

final as (
    select
        products.product_id,
        products.product_category_name,
        products.product_category_name_en,
        count(*) as order_item_count,
        count(distinct order_items.order_id) as order_count,
        count(distinct order_items.customer_id) as customer_count,
        count(distinct order_items.seller_id) as seller_count,
        sum(order_items.price) as gross_sales_value,
        sum(order_items.freight_value) as freight_value,
        sum(order_items.order_item_value) as total_sales_value,
        avg(order_items.price) as avg_item_price,
        avg(order_items.avg_review_score) as avg_review_score,
        countif(order_items.is_delivered) as delivered_item_count,
        countif(order_items.is_late_delivery) as late_delivery_item_count
    from products
    left join order_items
        on products.product_id = order_items.product_id
    group by 1, 2, 3
)

select * from final
