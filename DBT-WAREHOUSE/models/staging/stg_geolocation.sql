with source as (
    select * from {{ source('raw', 'raw_geolocation') }}
),

deduped as (
    select
        {{ clean_string('geolocation_zip_code_prefix') }} as zip_code_prefix,
        round(avg(safe_cast(geolocation_lat as float64)), 6) as lat,
        round(avg(safe_cast(geolocation_lng as float64)), 6) as lng,
        {{ clean_string("approx_top_count(cast(geolocation_city as string), 1)[offset(0)].value", case='lower') }} as city,
        {{ clean_string("approx_top_count(cast(geolocation_state as string), 1)[offset(0)].value", case='upper') }} as state
    from source
    group by 1
)

select * from deduped
