with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),

renamed as (
    select
        {{ clean_string('order_id') }} as order_id,
        safe_cast(order_item_id as int64) as order_item_id,
        {{ clean_string('product_id') }} as product_id,
        {{ clean_string('seller_id') }} as seller_id,
        safe_cast(shipping_limit_date as timestamp) as shipping_limit_at,
        safe_cast(price as numeric) as price,
        safe_cast(freight_value as numeric) as freight_value
    from source
)

select * from renamed
