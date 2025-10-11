WITH customer_ltv AS (
SELECT
      customerkey,
      cleaned_name,
      SUM(total_net_revenue) AS total_ltv
FROM cohort_analysis
GROUP BY
customerkey,
cleaned_name
), customer_segments AS(
SELECT
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th_percentil,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th_percentil
FROM customer_ltv
), segment_values AS(
SELECT 
     c.*,
     CASE 
     	WHEN c.total_ltv < ltv_25th_percentil THEN '1_LOW_VALUE'
     	WHEN c.total_ltv <= ltv_75th_percentil THEN '2_MID_VALUE'
     	ELSE '3_HIGH VALUE'
     END AS customer_segment
     
FROM customer_ltv c ,
     customer_segments cs 
     ) 
SELECT
customer_segment,
SUM(total_ltv) AS total_ltv,
COUNT(customerkey) AS customer_count,
SUM(total_ltv)/COUNT(customerkey) AS AVG_ltv
FROM segment_values
GROUP BY
customer_segment
ORDER BY
customer_segment DESC
