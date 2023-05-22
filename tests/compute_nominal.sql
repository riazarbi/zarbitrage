-- Validates that the compute_nominal udf returns the expected value
-- We just did a manual workup of a single parameter set and make sure the UDF is givng us the same value
SELECT
CAST(
    compute_nominal(
                    500000, 
                    18, 
                    0.005,
                    15,
                    20000,
                    0.0026,
                    0.00015,
                    0,
                    367200,
                    0.001,
                    20)
        AS decimal(10,2) ) AS nominal 
        WHERE 
        nominal!=505291.63
