WITH percentiles AS (
    SELECT 
        hour, 
        return, 
        percent_rank() OVER (ORDER BY return) AS percentile 
    FROM 
        returns
    WHERE 
        kraken='XXBTZUSD' AND 
        principal=500000 AND 
        hour BETWEEN now() - INTERVAL 14 DAY AND now() )
SELECT 
    hour, 
    CAST(return AS DECIMAL(8,4)) AS return , 
    CAST(percentile AS DECIMAL(8,2)) AS percentile 
FROM percentiles 
WHERE hour IN (SELECT max(hour) FROM percentiles);