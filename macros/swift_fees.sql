{% macro swift_fees(amount) %}

{% set sql_statement %}
    with lower as (select * from {{ ref('swift_fees') }} where low_range<{{ amount }}),
    selector as (select max(low_range) as low_range, 1 as selector  from lower)
    select fee from lower 
    left join selector on
    selector.low_range=lower.low_range
    where selector.selector=1
{% endset %}

{%- set newest_processed_order = dbt_utils.get_single_value(sql_statement, default="'2020-01-01'") -%}

{{ return(newest_processed_order) }}

{% endmacro %}