-- Advance SQL project on spotify datasets

-- create table
DROP TABLE IF EXISTS spotify;

CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(200),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

SELECT *
FROM spotify;

-- EDA

SELECT COUNT(DISTINCT artist)
FROM spotify;

SELECT COUNT(DISTINCT album_type)
FROM spotify;

SELECT DISTINCT album_type
FROM spotify;

SELECT MAX(duration_min)
FROM spotify;

SELECT MIN(duration_min)
FROM spotify;

SELECT *
FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT channel
FROM spotify;

SELECT DISTINCT most_played_on
FROM spotify;

-- Buisness Problems

-- 1 Retrieve the names of all tracks that have more than 1 billion streams.
SELECT track,
       stream
FROM spotify
WHERE stream > 1000000000;

-- 2 List all albums along with their respective artists.
SELECT DISTINCT album,
                artist
FROM spotify;

-- 3 Get the total number of comments for tracks where licensed = TRUE.
SELECT SUM(comments) AS total_comments
FROM spotify
WHERE licensed = 'True';

-- 4 Find all tracks that belong to the album type single.
SELECT track,
       album_type
FROM spotify
WHERE album_type ILIKE '%single%';

-- 5 Count the total number of tracks by each artist.
SELECT COUNT(track) AS total_track,
       artist
FROM spotify
GROUP BY 2
ORDER BY 1 DESC;

-- 6 Calculate the average danceability of tracks in each album.
SELECT album,
       AVG(danceability) AS avg_dnc
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;

-- 7 Find the top 5 tracks with the highest energy values.
SELECT DISTINCT track,
                energy
FROM spotify
ORDER BY energy DESC
LIMIT 5;

-- 8 List all tracks along with their views and likes where official_video = TRUE.
SELECT track,
       SUM(views) AS total_views,
       SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC;

-- 9 For each album, calculate the total views of all associated tracks.
SELECT album,
       track,
       SUM(views) AS total_views
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 10 Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT *
FROM (
    SELECT track,
           COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS youtube_stream,
           COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS spotify_stream
    FROM spotify
    GROUP BY 1
) AS t1
WHERE spotify_stream > youtube_stream
  AND youtube_stream != 0
ORDER BY spotify_stream DESC;

-- 11 Find the top 3 most-viewed tracks for each artist using window functions.
WITH ranking_artist AS (
    SELECT artist,
           track,
           SUM(views) AS total_views,
           DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
    FROM spotify
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC
)
SELECT *
FROM ranking_artist
WHERE rank <= 3;

-- 12 Write a query to find tracks where the liveness score is above the average.
SELECT *
FROM spotify
WHERE liveness > (
    SELECT AVG(liveness)
    FROM spotify
);

-- 13 Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH cte AS (
    SELECT album,
           MAX(energy) AS highest_energy,
           MIN(energy) AS lowest_energy
    FROM spotify
    GROUP BY 1
)
SELECT album,
       highest_energy - lowest_energy AS energy_diff
FROM cte
ORDER BY 2 DESC;

create index artist_index on 
spotify (artist);

create index album_index on 
spotify (album);