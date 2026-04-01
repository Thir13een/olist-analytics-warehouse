with geolocation as (
    select * from {{ ref('stg_geolocation') }}
)

select
    zip_code_prefix,
    city,
    state,
    lat,
    lng
from geolocation
