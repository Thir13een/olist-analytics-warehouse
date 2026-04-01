select
    order_id,
    customer_id,
    order_status,
    purchased_at,
    approved_at,
    shipped_at,
    delivered_at,
    estimated_delivery_at
from {{ ref('stg_orders') }}
where order_status = 'delivered'
  and delivered_at is null
