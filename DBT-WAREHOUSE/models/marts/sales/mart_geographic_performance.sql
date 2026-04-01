with customers as (
    select * from {{ ref('dim_customers') }}
),

geolocation as (
    select * from {{ ref('dim_geolocation') }}
),

orders as (
    select * from {{ ref('fct_orders') }}
),

customer_geo_orders as (
    select
        customers.customer_id,
        customers.zip_code_prefix,
        customers.city as customer_city,
        customers.state as customer_state,
        geolocation.lat,
        geolocation.lng,
        orders.order_id,
        orders.order_status,
        orders.order_value,
        orders.payment_value,
        orders.avg_review_score,
        orders.is_delivered,
        orders.is_late_delivery
    from customers
    left join geolocation
        on customers.zip_code_prefix = geolocation.zip_code_prefix
    left join orders
        on customers.customer_id = orders.customer_id
),

final as (
    select
        zip_code_prefix,
        customer_city,
        customer_state,
        lat,
        lng,
        concat(cast(lat as string), ', ', cast(lng as string)) as lat_lng,
        count(distinct customer_id) as customer_count,
        count(distinct order_id) as order_count,
        countif(is_delivered) as delivered_order_count,
        countif(is_late_delivery) as late_delivery_order_count,
        sum(order_value) as total_order_value,
        sum(payment_value) as total_payment_value,
        avg(avg_review_score) as avg_review_score
    from customer_geo_orders
    group by 1, 2, 3, 4, 5
)

select * from final
