{% macro fee_lookup(provider,service) %}

{% set sql_statement %}
    select fee from {{ ref('fees')}} where provider='{{ provider}}' and service='{{ service }}'
{% endset %}

{%- set found_fee = dbt_utils.get_single_value(sql_statement) -%}

{{ return(found_fee) }}

{% endmacro %}