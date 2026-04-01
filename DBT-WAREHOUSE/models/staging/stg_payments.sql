with source as (
    select * from {{ source('raw', 'raw_payments') }}
),

renamed as (
    select
        {{ clean_string('order_id') }} as order_id,
        safe_cast(payment_sequential as int64) as payment_sequential,
        {{ clean_string('payment_type', case='lower') }} as payment_type,
        safe_cast(payment_installments as int64) as payment_installments,
        safe_cast(payment_value as numeric) as payment_value
    from source
)

select * from renamed
