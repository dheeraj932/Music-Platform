SELECT artist, COUNT(*) AS NumberOfSongs
FROM Artist_table_SQL
JOIN Songs_table ON Artist_table_SQL.artist_ID = Songs_table.artist_ID
GROUP BY artist
ORDER BY NumberOfSongs DESC
LIMIT 10;

SELECT device_type, COUNT(*) AS UserCount
FROM devices
JOIN has ON devices.device_iD = has.device_iD
GROUP BY device_type
ORDER BY UserCount DESC;

SELECT DATE_FORMAT(date, '%Y-%m') AS PurchaseMonth, Concat('$ ',round(SUM(amount),2)) AS TotalRevenue
FROM transactions
GROUP BY PurchaseMonth
ORDER BY PurchaseMonth
LIMIT 10;

SELECT plan_name, COUNT(purchases.plan_iD) AS Subscribers
FROM plans
JOIN purchases ON plans.plan_iD = purchases.plan_iD
GROUP BY plan_name
ORDER BY Subscribers DESC;

SELECT artist, COUNT(follows.user_id) AS FollowerCount,
       RANK() OVER (ORDER BY COUNT(follows.user_id) DESC) AS PopularityRank
FROM artist_table_SQL
JOIN follows ON artist_table_SQL.artist_iD = follows.user_id
GROUP BY artist
ORDER BY FollowerCount DESC
LIMIT 10;

SELECT DISTINCT Users.user_id, Users.email,
SUM(Plans.price) OVER (PARTITION BY Users.user_id) AS estimated_ltv
FROM Users
JOIN Transactions ON Users.user_id = Transactions.user_id
JOIN Plans ON Transactions.plan_id = Plans.plan_id
LIMIT 10;

SELECT song_ids, title,
round(CAST(likes AS FLOAT) / play_count,2) AS satisfaction_ratio
FROM songs_table
WHERE play_count > 0
ORDER BY satisfaction_ratio DESC
LIMIT 10;

SELECT Playlists.playlist_id,
COUNT(DISTINCT songs_table.`top genre`) AS unique_genres
FROM Playlists
JOIN Contains ON Playlists.playlist_id = Contains.playlist_id
JOIN songs_table ON Contains.song_id = songs_table.song_ids
GROUP BY Playlists.playlist_id
ORDER BY unique_genres DESC
LIMIT 10;

SELECT `top genre`, round(AVG(likes),0) AS average_likes FROM songs_table
GROUP BY `top genre`
ORDER BY average_likes DESC
LIMIT 10;

WITH UserSpend AS (
  SELECT
    users.user_id,
    users.name as user_name,
    SUM(transactions.amount) AS total_spend
  FROM transactions
  JOIN users ON transactions.user_id = users.user_id
  GROUP BY users.user_id,users.name
)
SELECT
  user_name,
  concat('$ ',round(total_spend,2)) as Total_Spend,
  RANK() OVER (ORDER BY total_spend DESC) AS spend_rank
FROM UserSpend
LIMIT 10;

WITH RECURSIVE UserPlaylistContributions AS (
  SELECT
    c.user_id,
    c.playlist_id,
    1 AS ContributionDepth
  FROM `create` c
  WHERE c.user_id IS NOT NULL

  UNION ALL

  SELECT
    c2.user_id,
    upc.playlist_id,
    upc.ContributionDepth + 1
  FROM `create` c2
  JOIN UserPlaylistContributions upc ON c2.playlist_id = upc.playlist_id
  WHERE c2.user_id != upc.user_id
),
DistinctContributors AS (
  SELECT
    playlist_id,
    COUNT(DISTINCT user_id) AS NumberOfContributors
  FROM UserPlaylistContributions
  GROUP BY playlist_id
)
SELECT
  dc.playlist_id,
  p.playlist_name,
  dc.NumberOfContributors
FROM DistinctContributors dc
JOIN playlists p ON dc.playlist_id = p.playlist_id
ORDER BY dc.NumberOfContributors DESC, dc.playlist_id
LIMIT 10;

