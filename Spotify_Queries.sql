-- SQL Project

DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
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

SELECT * FROM spotify;

-- EDA
SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT DISTINCT artist FROM spotify;

SELECT DISTINCT album FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT (artist, album) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;

SELECT * FROM spotify WHERE duration_min = (SELECT MAX(duration_min) FROM spotify);

SELECT track, album_type, duration_min FROM spotify WHERE duration_min > 0.75*((SELECT MAX(duration_min) FROM spotify));

SELECT MIN(duration_min) FROM spotify; -- 0 duration

SELECT * FROM spotify WHERE duration_min = (SELECT MIN(duration_min) FROM spotify); -- 2 songs found

DELETE FROM spotify WHERE duration_min = 0;

SELECT DISTINCT channel FROM spotify;

SELECT DISTINCT most_played_on FROM spotify;
SELECT COUNT(most_played_on) FROM spotify WHERE most_played_on = 'Youtube';
SELECT COUNT(most_played_on) FROM spotify WHERE most_played_on = 'Spotify';

SELECT * FROM spotify WHERE LENGTH(track) = 0;
SELECT * FROM spotify WHERE LENGTH(artist) = 0;
SELECT * FROM spotify WHERE LENGTH(album) = 0;

SELECT track, artist FROM spotify GROUP BY track, artist;



--------------------------------------------------------------------------
-- Now we will go through a list of questions and answer them one by one
--------------------------------------------------------------------------

-- Easy Questions

-- Q.1 Retrieve names of all tracks with more than 1 billion streams
SELECT track, stream FROM spotify WHERE stream >= 1_000_000_000;

-- Q.2 List all albums alongtheir respective artist
SELECT DISTINCT(artist, album) FROM spotify;

-- Q.3 Get total number of comments for licensed tracks
SELECT SUM(COMMENTS) AS total_comments FROM spotify WHERE licensed = TRUE;

-- Q.4 Get the names of all singles
SELECT track FROM spotify WHERE album_type = 'single';

-- Q.5 Count the total number of tracks per artist
SELECT 
	artist, COUNT(DISTINCT(title)) AS total_songs
FROM spotify 
	GROUP BY artist 
	ORDER BY total_songs ASC;


-- Medium questions

-- Q.1 Calculate average danceability of tracks per album

SELECT 
	album, AVG(danceability) AS avg_danceability 
FROM spotify 
	GROUP BY album
	ORDER BY avg_danceability DESC;

-- Q.2 Find the top 5 tracks with the highest energy value
SELECT 
	track, artist, album, energy 
FROM spotify 
	ORDER BY energy DESC 
	LIMIT 5;

-- Q.3 List all tracks along with their views and likes where official_video = TRUE

SELECT track, 
	SUM(views) as total_views,
	SUM(likes) as total_likes 
FROM spotify
	WHERE official_video = TRUE
	GROUP BY track -- tracks can be repeated, thus why we group to add
	ORDER BY total_views DESC;


-- Q.4 For each album, calculate the total number of views of all associated tracks

SELECT 
	album,
	track,
	SUM(views) AS total_views
FROM spotify
	GROUP BY album, track -- tracks and albums can be repeated, thus the grouping
	ORDER BY total_views DESC;

-- Q.5	Retrieve the track names that have been streamed on spotify more than youtube


SELECT * FROM
	(SELECT
		track,
		COALESCE( SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) as streamed_on_spotify,
		COALESCE( SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS streamed_on_youtube
	FROM spotify
	GROUP BY track) AS table1
		WHERE streamed_on_spotify > streamed_on_youtube
		AND streamed_on_youtube <> 0;


-- Advanced questions

-- Q.1 Find top 3 most viewed tracks for each artist using window functions

WITH ranking_artist AS (
	SELECT
		artist, track,
		SUM(views) as total_views,
		DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
	FROM spotify
		GROUP BY artist, track
		ORDER BY artist, total_views DESC
)
SELECT * 
FROM ranking_artist
	WHERE rank <=3;

-- Q.2 Write a query to find tracks where the liveness score is above average

SELECT
	track,
	artist,
	liveness
FROM spotify
	WHERE liveness > (SELECT AVG(liveness) FROM spotify);

-- Q.3 Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album
WITH get_energy_values AS (
	SELECT 
		album,
		MAX(energy) AS highest_energy,
		MIN(energy) AS lowest_energy
	FROM spotify
		GROUP BY album
)
SELECT album, highest_energy - lowest_energy AS energy_difference 
FROM get_energy_values
	ORDER BY energy_difference DESC;



--------------------------------------------------------------------------
-- Optimization
--------------------------------------------------------------------------

CREATE INDEX artist_index ON spotify(artist);

EXPLAIN ANALYZE
SELECT
	artist, track, views
FROM spotify
	WHERE artist = 'Gorillaz'
		AND
	most_played_on = 'Youtube'
ORDER BY stream DESC LIMIT 25;
