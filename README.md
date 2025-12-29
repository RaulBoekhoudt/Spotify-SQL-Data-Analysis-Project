# Spotify SQL Analytics & Performance Tuning Project

**Difficulty level:** Advanced
**Dataset source:** Public Spotify dataset (Kaggle)

## Project Summary

This project explores a large Spotify dataset using **PostgreSQL**, with a strong focus on advanced querying techniques and database performance optimisation. The work covers the full workflow from schema design and data exploration through to analytical querying and execution-plan analysis.

The main objective is to demonstrate practical SQL skills that are directly relevant to data analytics and consulting roles, including query design, optimisation, and interpretation of results.

---

## Dataset Description

The dataset contains track-level information enriched with audio features and engagement metrics sourced from streaming platforms. Key dimensions include:

* Artist, track, album, and album type
* Audio features such as danceability, energy, tempo, and loudness
* Engagement metrics including views, likes, comments, and streams
* Flags indicating licensing and official video status

---

## Database Schema

The dataset was loaded into a relational table designed to support analytical querying:

```sql
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
```

---

## Analytical Workflow

### 1. Initial Data Exploration

Before writing complex queries, the dataset was inspected to understand distributions, value ranges, and relationships between variables. This step helped inform later aggregation and filtering strategies.

---

### 2. SQL Analysis

A broad range of SQL queries were written and grouped by complexity to reflect progressive skill development.

#### Basic Analysis

* Filtering tracks based on stream counts
* Simple aggregations by artist and album
* Boolean condition filtering

#### Intermediate Analysis

* Aggregations combined with `GROUP BY`
* Ranking and ordering results
* Comparing platform-level engagement metrics

#### Advanced Analysis

* Window functions for ranking within partitions
* Common Table Expressions (CTEs)
* Nested queries for comparative metrics

Example of an advanced CTE-based query:

```sql
WITH energy_stats AS (
    SELECT
        album,
        MAX(energy) AS max_energy,
        MIN(energy) AS min_energy
    FROM spotify
    GROUP BY album
)
SELECT
    album,
    max_energy - min_energy AS energy_range
FROM energy_stats
ORDER BY energy_range DESC;
```

---

## Performance Optimisation Case Study

### Baseline Analysis

To assess performance, query execution was examined using `EXPLAIN ANALYSE`. A filter on the `artist` column revealed unnecessary sequential scans, leading to avoidable execution time.

**Observed metrics (before optimisation):**

* Execution time: ~7 ms
* Planning time: ~0.17 ms

---

### Index Implementation

To address this, an index was added on the artist field:

```sql
CREATE INDEX idx_artist ON spotify(artist);
```

---

### Post-Optimisation Results

After indexing, the same query was re-evaluated:

* Execution time reduced to ~0.15 ms
* Planning time significantly improved
* Query plan switched from sequential scan to index scan

This clearly demonstrates how targeted indexing can materially improve query performance on analytical workloads.

---

## Practice Query Set

### Entry Level

1. Identify tracks exceeding one billion streams
2. List albums with corresponding artists
3. Aggregate total comments for licensed tracks
4. Filter tracks released as singles
5. Count tracks per artist

### Intermediate Level

1. Average danceability per album
2. Top five tracks by energy
3. Official video engagement analysis
4. Album-level view aggregation
5. Platform comparison between Spotify and YouTube

### Advanced Level

1. Top three tracks per artist using window functions
2. Tracks exceeding average liveness
3. Album-level energy dispersion using CTEs
4. Energy-to-liveness ratio analysis
5. Cumulative likes ordered by views

---

## Tools & Technologies

* **Database:** PostgreSQL
* **SQL Concepts:** DDL, aggregation, subqueries, window functions, CTEs
* **Optimisation:** Indexing, execution-plan analysis
* **Environment:** pgAdmin 4 / PostgreSQL CLI

---

## Running the Project

1. Install PostgreSQL and a SQL client
2. Create the database and table schema
3. Load the dataset into PostgreSQL
4. Execute analytical queries
5. Inspect and optimise performance using `EXPLAIN ANALYSE`

---

## Potential Extensions

* Build dashboards in Power BI or Tableau
* Test performance with larger synthetic datasets
* Explore composite and partial indexes
* Compare optimisation strategies across different query patterns

---

## Licence

This project is released under the MIT Licence and is intended for educational and portfolio use.

