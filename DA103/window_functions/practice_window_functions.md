# More practice with Window Functions

In this example we will look at San Francisco Bike Share trip counts by day. We will combine our knowledge of aggregate functions and make changes to the "window" of data that we look at. 

## Explore the data

```sql
SELECT * FROM 
FROM `bigquery-public-data.san_francisco.bikeshare_trips`
LIMIT 10
```

## Calculate trips by day for a given year

```sql
SELECT 
  DATE(start_date) AS trip_date,
  COUNT(*) as num_trips
FROM `bigquery-public-data.san_francisco.bikeshare_trips`
  WHERE EXTRACT(YEAR FROM start_date) = 2015
  GROUP BY trip_date
```

## Count the total number of trips

- Yesterday's trips
- Tomorrow's trips
- This week's trip total
- All trips on or before this date

```sql
WITH trips_by_day AS
(
SELECT 
  DATE(start_date) AS trip_date,
  COUNT(*) AS num_trips
FROM `bigquery-public-data.san_francisco.bikeshare_trips`
  WHERE EXTRACT(YEAR FROM start_date) = 2015
  GROUP BY trip_date
)
SELECT 
  trip_date,
  num_trips,

  -- look at yesterdays row
  LAG(num_trips, 1)
      OVER (
            ORDER BY trip_date
            ) AS yesterdays_total_trips,

  -- look at tomorrow's row
  LEAD(num_trips, 1)
      OVER (
            ORDER BY trip_date
            ) AS tomorrows_total_trips,

  -- sum the rows from the past week
  SUM(num_trips) 
      OVER (
            ORDER BY trip_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            ) AS rolling_7_day_trip_count,

  -- sum all of the rows that happened before
  SUM(num_trips) 
      OVER (
            ORDER BY trip_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS cumulative_trip_count

FROM trips_by_day
ORDER BY trip_date
```

## Bonus: Cumulative trips by Station Name
```sql
WITH trips_by_day AS
(
SELECT 
  DATE(start_date) AS trip_date,
  start_station_name,
  COUNT(*) AS num_trips
FROM `bigquery-public-data.san_francisco.bikeshare_trips`
  WHERE EXTRACT(YEAR FROM start_date) = 2015
  GROUP BY 
  	trip_date,
  	start_station_name
)
SELECT 
  trip_date,
  num_trips,
  start_station_name,

  -- sum all of the rows that happened before
  SUM(num_trips) 
      OVER (
      		PARTITION BY start_station_name
            ORDER BY trip_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS cumulative_trip_count


FROM trips_by_day
ORDER BY trip_date
```


## In-class exercise

```sql
WITH daily_trips AS (
  SELECT 
    EXTRACT(YEAR FROM DATE(start_date)) AS year,
    DATE(start_date) AS trip_date,
    COUNT(trip_id) AS total_trips
  FROM `bigquery-public-data.san_francisco.bikeshare_trips`
  GROUP BY year, trip_date
  ORDER BY trip_date
)

SELECT 
  *,
  -- RANK() OVER(
  --   ORDER BY trip_date
  -- ) AS day_order,

  -- RANK() OVER(
  --   ORDER BY total_trips DESC
  -- ) AS most_popular_days_overall,

  -- RANK() OVER(
  --   PARTITION BY year
  --   ORDER BY total_trips DESC
  -- ) AS most_popular_days_by_year,

  -- yesterdays total rides
  LAG(total_trips,1,0) OVER(ORDER BY trip_date) AS yesterdays_rides,

  total_trips - LAG(total_trips,1,0) OVER(ORDER BY trip_date) AS change_from_yesterday,

  -- tomorrow's total rides
  LEAD(total_trips,1,0) OVER(ORDER BY trip_date) AS tomorrow_rides,
  LEAD(total_trips,365,0) OVER(ORDER BY trip_date) AS this_day_next_year,

  -- rolling weeks avg rides
  -- running average by day for all time:
  AVG(total_trips) OVER(ORDER BY trip_date) AS avg_trip_count_all_time,

  -- running average by day BY EACH YEAR (look at Jan 1st to see the avg reset)
  AVG(total_trips) OVER(PARTITION BY YEAR ORDER BY trip_date) AS avg_trip_count_by_time,

  -- rolling 7 day average ("rolling window"). Smooths the data over:
  AVG(total_trips) OVER(
    ORDER BY trip_date
    -- Looks back at the 6 rows before the current row and the current row itself
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7_day_avg_trip_count,

 -- running sum (cumulative sum) "running total"
  SUM(total_trips) OVER(
    ORDER BY trip_date
    -- Looks back as far as we can (unbounded) and sum all the trips including todays
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_cumulative_total_trips,

 -- running sum (cumulative sum) "running total"
  SUM(total_trips) OVER(
    ORDER BY trip_date
    -- Looks back as far as we can (unbounded) and sum all the trips including todays
    -- BY THE WAY: This code below is the "default" and 
    -- will actually return the same results!!
    -- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_cumulative_total_trips_v2

FROM daily_trips
ORDER BY trip_date
```

## Additional Reading
Window functions can get really cool. See some more great examples here:
https://cloud.google.com/bigquery/docs/reference/standard-sql/window-function-calls