select 
    hour, 
    kraken, 
    principal, 
    nominal, 
    nominal/principal-1 as return 
from {{ ref('int_nominal') }}