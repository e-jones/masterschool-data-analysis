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
  COUNT(*) as num_trips
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

-- Documentation of Window Functions
```

## Additional Reading
Window functions can get really cool. See some more great examples here:
https://cloud.google.com/bigquery/docs/reference/standard-sql/window-function-calls