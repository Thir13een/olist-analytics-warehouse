with source as (
    select * from {{ source('raw', 'raw_reviews') }}
),

renamed as (
    select
        {{ clean_string('review_id') }} as review_id,
        {{ clean_string('order_id') }} as order_id,
        safe_cast(review_score as int64) as review_score,
        {{ clean_string('review_comment_title') }} as review_comment_title,
        {{ clean_string('review_comment_message') }} as review_comment_message,
        safe_cast(review_creation_date as timestamp) as created_at,
        safe_cast(review_answer_timestamp as timestamp) as answered_at
    from source
)

select * from renamed
