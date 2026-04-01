with source as (
    select * from {{ source('raw', 'raw_product_category_translation') }}
),

renamed as (
    select
        {{ clean_string('product_category_name') }} as product_category_name,
        {{ clean_string('product_category_name_english') }} as product_category_name_en
    from source
)

select * from renamed
