with source as (
    select * from {{ source('raw', 'raw_customers') }}
),

renamed as (
    select
        {{ clean_string('customer_id') }} as customer_id,
        {{ clean_string('customer_unique_id') }} as customer_unique_id,
        {{ clean_string('customer_zip_code_prefix') }} as zip_code_prefix,
        {{ clean_string('customer_city', case='lower') }} as city,
        {{ clean_string('customer_state', case='upper') }} as state
    from source
)

select * from renamed
