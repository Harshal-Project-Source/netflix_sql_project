-- Netflix Project

CREATE TABLE netflix
(
	 show_id VARCHAR(6),
	 type VARCHAR(10),
	 title VARCHAR(150),
	 director VARCHAR(208),
	 castS VARCHAR(1000),
	 country VARCHAR(150),
	 date_added VARCHAR(50),
	 relesase_year INT,
	 rating VARCHAR(10),
	 duration VARCHAR(15),
	 listed_in VARCHAR(100),
	 description VARCHAR(250)
);

SELECT * FROM netflix;

SELECT COUNT (*) AS total_content
FROM netflix;

SELECT DISTINCT TYPE
FROM netflix;

-- 1.Count the number of Movies vs TV Shows

SELECT type, COUNT (*) AS total_content  
FROM netflix
GROUP  BY type;

-- 2.List all movies released in a specific year (e.g., 2020)

SELECT type,title, relesase_year
FROM netflix
where type like 'Movie' and relesase_year = 2020;

-- 3.Problem Statement: Find directors who have directed more than 5 movies.

SELECT director
FROM netflix
WHERE Type = 'Movie'
GROUP BY director
HAVING COUNT(*) > 5;

-- 4.Problem Statement: Create an index to optimize searching by genre (Listed_in column).

CREATE INDEX idx_genre ON netflix(Listed_in);

-- 5.Problem Statement: Create a view that shows the top 10 highest-rated movies.

CREATE VIEW TopRatedMovies AS
SELECT title, rating, relesase_Year
FROM netflix
WHERE Type = 'Movie'
ORDER BY rating DESC
LIMIT 10;

-- 6.Problem Statement: Create a temporary table to store movies released in the last 5 years.

CREATE TEMPORARY TABLE RecentMovies AS
SELECT title, relesase_year
FROM Netflix
WHERE type = 'Movie' 
  AND relesase_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 5;

-- 7.Problem Statement: Write a stored procedure to insert a new movie into the database.

CREATE PROCEDURE AddMovie(
    IN p_title VARCHAR(150),
    IN p_director VARCHAR(208),
    IN p_country VARCHAR(150),
    IN p_relesase_year Int,
    IN p_rating VARCHAR(10),
    IN p_duration INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO netflix (title, director, country, relesase_year, rating, Type, duration)
    VALUES (p_title, p_director, p_country, p_relesase_year, p_rating, 'Movie', p_duration);
END;
$$

-- 8.Problem Statement: Optimize the query to show the top 5 movies by rating.

SELECT title, rating
FROM netflix
WHERE Type = 'Movie'
ORDER BY rating DESC
LIMIT 5;
-- Ensure an index on the Ratings column
CREATE INDEX idx_ratings ON netflix(rating);

-- 9.Problem Statement: Use a JOIN to list movies and TV shows along with their casts.

SELECT n.Title, n.Type, n.Casts
FROM netflix n
JOIN netflix n2 ON n.Casts = n2.Casts
WHERE n.Type IN ('Movie', 'TV Show');

-- 10.Problem Statement: Create a trigger that sets the default rating for new movies to 'Not Rated'

CREATE OR REPLACE FUNCTION SetDefaultRating() 
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the Ratings is NULL, if so set it to 'Not Rated'
    IF NEW.Rating IS NULL THEN
        NEW.Rating := 'Not Rated';
    END IF;
    -- Return the modified NEW row
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 2: Create the trigger that calls the function
CREATE TRIGGER SetDefaultRating
BEFORE INSERT ON netflix
FOR EACH ROW
EXECUTE FUNCTION SetDefaultRating();

-- 11.Problem Statement: Extract the first 30 characters of the Description column for movies.

SELECT Title, SUBSTRING(Description, 1, 30) AS Short_Description
FROM netflix
WHERE Type = 'Movie';

-- 12.Problem Statement: Find movies that do not have a rating.

SELECT Title, rating
FROM netflix
WHERE Type = 'Movie'
AND Rating IS NULL;

-- 13.Problem Statement: Create a view that shows all TV Shows released in 2023.

CREATE VIEW TVShows2023 AS
SELECT Title, Relesase_Year
FROM netflix
WHERE Type = 'TV Show' AND Relesase_Year = 2023;

-- 14.Problem Statement: Count the number of movies in each genre using a window function.

SELECT Title, Listed_in, COUNT(*) OVER (PARTITION BY Listed_in) AS Genre_Count
FROM netflix
WHERE Type = 'Movie';

-- 15.Problem Statement: Use a CTE to find the top 5 countries with the most movies.

WITH CountryMovieCount AS (
    SELECT Country, COUNT(*) AS MovieCount
    FROM netflix
    WHERE Type = 'Movie'
    GROUP BY Country
)
SELECT Country, MovieCount
FROM CountryMovieCount
ORDER BY MovieCount DESC
LIMIT 5;

-- 16.Problem Statement: Create a temporary table to store the top 10 movies by release year.

CREATE TEMPORARY TABLE TopMovies AS
SELECT Title, Relesase_Year, Rating
FROM netflix
WHERE Type = 'Movie'
ORDER BY Relesase_Year DESC
LIMIT 10;

-- 17.Problem Statement: Optimize the query to efficiently search for movies released between the years 2010 and 2020.


CREATE INDEX idx_release_year ON netflix(Relesase_Year);

-- Optimized query to fetch movies released between 2010 and 2020

SELECT Title, Relesase_Year, Rating
FROM netflix
WHERE Type = 'Movie' AND Relesase_Year BETWEEN 2010 AND 2020;

-- Explanation: An index on the Release_Year column can significantly speed up queries that filter by a range of years.

-- End. 