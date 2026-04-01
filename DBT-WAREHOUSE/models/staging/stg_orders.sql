with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

renamed as (
    select
        {{ clean_string('order_id') }} as order_id,
        {{ clean_string('customer_id') }} as customer_id,
        {{ clean_string('order_status', case='lower') }} as order_status,
        safe_cast(order_purchase_timestamp as timestamp) as purchased_at,
        safe_cast(order_approved_at as timestamp) as approved_at,
        safe_cast(order_delivered_carrier_date as timestamp) as shipped_at,
        safe_cast(order_delivered_customer_date as timestamp) as delivered_at,
        safe_cast(order_estimated_delivery_date as timestamp) as estimated_delivery_at
    from source
)

select * from renamed
