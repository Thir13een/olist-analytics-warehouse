# Staging Null Policy

This file defines how missing values should be handled in the `stg_*` models.

Policy labels:
- `required`: value should be present; keep `not_null` test.
- `optional`: null is business-valid; do not impute in staging.
- `conditional`: null is valid for some records; handle with downstream business rules, not blanket staging defaults.

## `stg_customers`

| Column | Policy | Action | Reason |
| --- | --- | --- | --- |
| `customer_id` | required | keep nulls as null in SQL, enforce `not_null` test | primary customer key |
| `customer_unique_id` | required | keep nulls as null in SQL, enforce `not_null` test | stable customer identity |
| `zip_code_prefix` | required | keep nulls as null in SQL, enforce `not_null` test | required for customer location |
| `city` | required | keep nulls as null in SQL, add `not_null` test later if source confirms completeness | core customer geography |
| `state` | required | keep nulls as null in SQL, add `not_null` test later if source confirms completeness | core customer geography |

## `stg_sellers`

| Column | Policy | Action | Reason |
| --- | --- | --- | --- |
| `seller_id` | required | keep nulls as null in SQL, enforce `not_null` test | primary seller key |
| `zip_code_prefix` | required | keep nulls as null in SQL, enforce `not_null` test | required for seller location |
| `city` | required | keep nulls as null in SQL, add `not_null` test later if source confirms completeness | core seller geography |
| `state` | required | keep nulls as null in SQL, add `not_null` test later if source confirms completeness | core seller geography |

## `stg_orders`

| Column | Policy | Action | Reason |
| --- | --- | --- | --- |
| `order_id` | required | keep nulls as null in SQL, enforce `not_null` test | primary order key |
| `customer_id` | required | keep nulls as null in SQL, enforce `not_null` test | order-customer relationship |
| `order_status` | required | keep nulls as null in SQL, enforce `not_null` and `accepted_values` tests | required business state |
| `purchased_at` | required | keep nulls as null in SQL, add `not_null` test later if confirmed | order creation timestamp |
| `approved_at` | conditional | keep nullable | not all orders are approved at the same lifecycle point |
| `shipped_at` | conditional | keep nullable | missing for unshipped or canceled orders |
| `delivered_at` | conditional | keep nullable | missing until delivered |
| `estimated_delivery_at` | conditional | keep nullable | expected to exist often, but do not impute blindly |

## `stg_order_items`

| Column | Policy | Action | Reason |
| --- | --- | --- | --- |
| `order_id` | required | keep nulls as null in SQL, enforce `not_null` test | parent order key |
| `order_item_id` | required | keep nulls as null in SQL, enforce `not_null` test | line-item sequence |
| `product_id` | required | keep nulls as null in SQL, enforce `not_null` test | order item product link |
| `seller_id` | required | keep nulls as null in SQL, enforce `not_null` test | order item seller link |
| `shipping_limit_at` | conditional | keep nullable | operational deadline may be missing in bad source rows |
| `price` | required | keep nulls as null in SQL, enforce `not_null` test | core financial measure |
| `freight_value` | required | keep nulls as null in SQL, enforce `not_null` test | core shipping cost measure |

## `stg_products`

| Column | Policy | Action | Reason |
| --- | --- | --- | --- |
| `product_id` | required | keep nulls as null in SQL, enforce `not_null` test | primary product key |
| `product_category_name` | optional | keep nullable | products may lack mapped category |
| `product_name_length` | optional | keep nullable | descriptive attribute can be absent |
| `product_description_length` | optional | keep nullable | descriptive attribute can be absent |
| `product_photos_qty` | optional | keep nullable | descriptive attribute can be absent |
| `product_weight_g` | optional | keep nullable | physical attribute can be absent |
| `product_length_cm` | optional | keep nullable | physical attribute can be absent |
| `product_height_cm` | optional | keep nullable | physical attribute can be absent |
| `product_width_cm` | optional | keep nullable | physical attribute can be absent |

## `stg_payments`

| Column | Policy | Action | Reason |
| --- | --- | --- | --- |
| `order_id` | required | keep nulls as null in SQL, enforce `not_null` test | payment-order relationship |
| `payment_sequential` | required | keep nulls as null in SQL, enforce `not_null` test | payment sequence key |
| `payment_type` | required | keep nulls as null in SQL, enforce `not_null` test | payment classification |
| `payment_installments` | optional | keep nullable | missing installments should not be coerced in staging |
| `payment_value` | required | keep nulls as null in SQL, enforce `not_null` test | core payment amount |

## `stg_reviews`

| Column | Policy | Action | Reason |
| --- | --- | --- | --- |
| `review_id` | required | keep nulls as null in SQL, enforce `not_null` test | review identifier |
| `order_id` | required | keep nulls as null in SQL, enforce `not_null` test | review-order relationship |
| `review_score` | required | keep nulls as null in SQL, enforce `not_null` and `accepted_values` tests | primary review metric |
| `review_comment_title` | optional | keep nullable | many reviews have score only |
| `review_comment_message` | optional | keep nullable | many reviews have score only |
| `created_at` | conditional | keep nullable | should exist often, but do not impute timestamps |
| `answered_at` | conditional | keep nullable | depends on review workflow completion |

## `stg_geolocation`

| Column | Policy | Action | Reason |
| --- | --- | --- | --- |
| `zip_code_prefix` | required | keep nulls as null in SQL, enforce `not_null` and `unique` tests | deduped geographic key |
| `lat` | optional | keep nullable | averaged coordinates may still be unavailable |
| `lng` | optional | keep nullable | averaged coordinates may still be unavailable |
| `city` | optional | keep nullable | raw geolocation rows can be incomplete |
| `state` | optional | keep nullable | raw geolocation rows can be incomplete |

## `stg_product_category_translation`

| Column | Policy | Action | Reason |
| --- | --- | --- | --- |
| `product_category_name` | required | keep nulls as null in SQL, enforce `not_null` and `unique` tests | source category key |
| `product_category_name_en` | required | keep nulls as null in SQL, enforce `not_null` test | required translation value |
