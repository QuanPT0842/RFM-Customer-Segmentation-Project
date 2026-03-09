SELECT * FROM customer;
SELECT * FROM sales;
SELECT * FROM segment_scores;

-------- RFM Calculate ------
WITH RFM_Base AS (
    SELECT a.Customer_ID,
        Customer_Name,
        DATEDIFF(DAY, MAX(Order_Date), CONVERT(DATE, GETDATE())) AS Recency_Value,
        COUNT(Order_ID) AS Frequency_Value,
        ROUND(SUM(sales), 2) AS Monetary_Value
    FROM sales AS a
    INNER JOIN customer AS b
        ON a.Customer_ID = b.Customer_ID
    GROUP BY a.Customer_ID, Customer_Name
) 
-- SELECT * FROM RFM_Base;
, RFM_Score AS (
    SELECT *,
        NTILE(5) OVER (order by Recency_Value DESC) AS Recency_Score,
        NTILE(5) OVER (order by Frequency_Value ASC) AS Frequency_Score,
        NTILE(5) OVER (order by Monetary_Value ASC) AS Monetary_Score
    FROM RFM_Base
) 
-- SELECT * FROM RFM_Score;
, RFM_Segment_Score AS (
    SELECT *,
        CONCAT(Recency_Score, Frequency_Score, Monetary_Score) AS RFM_Overrall
    FROM RFM_Score
)
SELECT A.*,
    B.Segment
FROM RFM_Segment_Score AS A
LEFT JOIN segment_scores AS B
    ON A.RFM_Overrall = B.Scores
------------ DONE -----------
