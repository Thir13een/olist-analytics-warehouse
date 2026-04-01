with source as (
    select * from {{ source('raw', 'raw_sellers') }}
),

renamed as (
    select
        {{ clean_string('seller_id') }} as seller_id,
        {{ clean_string('seller_zip_code_prefix') }} as zip_code_prefix,
        {{ clean_string('seller_city', case='lower') }} as city,
        {{ clean_string('seller_state', case='upper') }} as state
    from source
)

select * from renamed
