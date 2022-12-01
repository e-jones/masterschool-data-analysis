/*
-- Example Masterschool queries on a BigQuery Public Dataset
-- Highest passenger Count
-- Highest tip amount
-- Longest trip (miles, and time)
*/

SELECT  
  MAX(trip_distance) AS longest_distance,
  MAX(tip_amount) AS highest_tip,
  MAX(passenger_count) AS most_passengers,
  AVG(trip_distance) AS avg_distance,
  AVG(tip_amount) AS avg_tip
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022` 