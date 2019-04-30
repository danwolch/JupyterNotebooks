WITH days AS (
    SELECT d
    FROM   generate_series( timestamp '2019-02-01'
                            , timestamp '2019-04-15'
                            , interval  '1 day') d
), amounts AS (
    SELECT d.d
      -- stripe does things in cents. divide by 100 to get dollars
      , SUM(coalesce(amount::int,0) / 100) as Revenue
    FROM days d
        LEFT JOIN stripe.charges c
            ON d.d = DATE_TRUNC('day', c.created)
                AND paid = true
                AND status = 'succeeded'
                AND refunded = false
                AND coalesce(amount_refunded,0) != amount
    GROUP BY 1
)

SELECT d
    , sum(revenue) OVER (ORDER BY d) AS cum_amt
FROM amounts
WHERE d >= '2019-02-25'
ORDER BY d
