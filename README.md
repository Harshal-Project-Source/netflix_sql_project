# Netflix Movies and TV Shows Data Analysis using SQL

![netflix logo](https://github.com/user-attachments/assets/42b6b9d7-9096-494b-9e57-b57da408b3d8)


## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type, COUNT (*) AS total_content  
FROM netflix
GROUP  BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT type,title, relesase_year
FROM netflix
where type like 'Movie' and relesase_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 3. Find directors who have directed more than 5 movies.

```sql
SELECT director
FROM netflix
WHERE Type = 'Movie'
GROUP BY director
HAVING COUNT(*) > 5;
```

**Objective:** Find Directors with More than 5 Movies.

### 4. Create an index to optimize searching by genre (Listed_in column).

```sql
CREATE INDEX idx_genre ON netflix(Listed_in);
```

**Objective:** Optimize Query for Searching by Genre

### 5. Create a view that shows the top 10 highest-rated movies.

```sql
CREATE VIEW TopRatedMovies AS
SELECT title, rating, relesase_Year
FROM netflix
WHERE Type = 'Movie'
ORDER BY rating DESC
LIMIT 10;
```

**Objective:** Create a View of Top 10 Rated Movies.

### 6. Create a temporary table to store movies released in the last 5 years.

```sql
CREATE TEMPORARY TABLE RecentMovies AS
SELECT title, relesase_year
FROM Netflix
WHERE type = 'Movie' 
  AND relesase_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 5;
```

**Objective:** Store Movies Released in the Last 5 Years.

### 7.Write a stored procedure to insert a new movie into the database. 

```sql
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
```

**Objective:** Stored Procedure to add a New Movie

### 8. Optimize the query to show the top 5 movies by rating.

```sql
SELECT title, rating
FROM netflix
WHERE Type = 'Movie'
ORDER BY rating DESC
LIMIT 5;

-- Ensure an index on the Ratings column
CREATE INDEX idx_ratings ON netflix(rating);
```

**Objective:** Optimize a Query for Viewing Top 5 Movies by Rating.

### 9. Use a JOIN to list movies and TV shows along with their casts.

```sql
SELECT n.Title, n.Type, n.Casts
FROM netflix n
JOIN netflix n2 ON n.Casts = n2.Casts
WHERE n.Type IN ('Movie', 'TV Show');
```

**Objective:** List Movies and TV Shows with Casts.

### 10. Create a trigger that sets the default rating for new movies to 'Not Rated'

```sql
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

```

**Objective:** Trigger: Set Default Rating for New Movies.

### 11. Extract the first 30 characters of the Description column for movies.

```sql
SELECT Title, SUBSTRING(Description, 1, 30) AS Short_Description
FROM netflix
WHERE Type = 'Movie';
```

**Objective:**  Extract Genre from the Description Column

### 12. Find movies that do not have a rating.

```sql
SELECT Title, rating
FROM netflix
WHERE Type = 'Movie'
AND Rating IS NULL;
```

**Objective:** Find Movies Not Rated.

### 13. Count the number of movies in each genre using a window function.

```sql
SELECT Title, Listed_in, COUNT(*) OVER (PARTITION BY Listed_in) AS Genre_Count
FROM netflix
WHERE Type = 'Movie';
```

**Objective:** Count Movies in Each Genre.

### 14. Use a CTE to find the top 5 countries with the most movies.

```sql
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
```

**Objective:** Find Top 5 Countries with the Most Movies.

### 15. Create a temporary table to store the top 10 movies by release year.

```sql
CREATE TEMPORARY TABLE TopMovies AS
SELECT Title, Relesase_Year, Rating
FROM netflix
WHERE Type = 'Movie'
ORDER BY Relesase_Year DESC
LIMIT 10;
```

**Objective:** Get the Top 10 Movies by Release Year.

### 16. Optimize the query to efficiently search for movies released between the years.

```sql
CREATE INDEX idx_release_year ON netflix(Relesase_Year);

-- Optimized query to fetch movies released between 2010 and 2020

SELECT Title, Relesase_Year, Rating
FROM netflix
WHERE Type = 'Movie' AND Relesase_Year BETWEEN 2010 AND 2020;

-- Explanation: An index on the Release_Year column can significantly speed up queries that filter by a range of years.
```

**Objective:** Optimize Query for Movies Released Between 2010 and 2020.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
