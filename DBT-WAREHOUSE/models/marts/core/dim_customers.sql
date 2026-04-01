with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('fct_orders') }}
),

customer_order_agg as (
    select
        customer_id,
        count(*) as order_count,
        countif(is_delivered) as delivered_order_count,
        countif(is_canceled) as canceled_order_count,
        min(purchased_at) as first_order_at,
        max(purchased_at) as last_order_at,
        sum(order_value) as lifetime_order_value,
        sum(payment_value) as lifetime_payment_value,
        avg(avg_review_score) as avg_order_review_score
    from orders
    group by 1
),

unique_customer_order_count as (
    select
        customers.customer_unique_id,
        count(distinct orders.order_id) as unique_customer_order_count
    from orders
    inner join {{ ref('stg_customers') }} as customers
        on orders.customer_id = customers.customer_id
    group by 1
),

final as (
    select
        customers.customer_id,
        customers.customer_unique_id,
        customers.zip_code_prefix,
        customers.city,
        customers.state,
        coalesce(customer_order_agg.order_count, 0) as order_count,
        coalesce(customer_order_agg.delivered_order_count, 0) as delivered_order_count,
        coalesce(customer_order_agg.canceled_order_count, 0) as canceled_order_count,
        customer_order_agg.first_order_at,
        customer_order_agg.last_order_at,
        coalesce(customer_order_agg.lifetime_order_value, 0) as lifetime_order_value,
        coalesce(customer_order_agg.lifetime_payment_value, 0) as lifetime_payment_value,
        customer_order_agg.avg_order_review_score,
        coalesce(unique_customer_order_count.unique_customer_order_count, 0) as unique_customer_order_count
    from customers
    left join customer_order_agg
        on customers.customer_id = customer_order_agg.customer_id
    left join unique_customer_order_count
        on customers.customer_unique_id = unique_customer_order_count.customer_unique_id
)

select * from final
