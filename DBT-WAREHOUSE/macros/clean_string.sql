{% macro clean_string(field, case=None) -%}
    {%- set value_sql -%}
        nullif(trim(cast({{ field }} as string)), '')
    {%- endset -%}

    {%- if case == 'lower' -%}
        lower({{ value_sql }})
    {%- elif case == 'upper' -%}
        upper({{ value_sql }})
    {%- else -%}
        {{ value_sql }}
    {%- endif -%}
{%- endmacro %}
