select
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
from {{ ref('stg_payments') }}
where payment_value < 0
