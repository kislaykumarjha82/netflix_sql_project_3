--netflix project 

drop table if exists netflix;
create table netflix(
show_id	varchar(6),
type varchar(10),
title varchar(150),
director varchar(208),
casts varchar(1000),
country  varchar(150),
date_added varchar(50),
release_year int ,
rating	varchar(10),
duration varchar(15),
listed_in	varchar(100),
description varchar(250)
);

select * from netflix;
select distinct type from netflix;


/* 15 business problems(netflix)
1. Count the number of Movies vs TV Shows
2. Find the most common rating for movies and TV shows
3. List all movies released in a specific year (e.g., 2020)
4. Find the top 5 countries with the most content on Netflix
5. Identify the longest movie
6. Find content added in the last 5 years
7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
8. List all TV shows with more than 5 seasons
9. Count the number of content items in each genre
10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!
11. List all movies that are documentaries
12. Find all content without a director
13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category. */


--Task 1. Count the number of Movies vs TV Shows
select type, 
count(*) as total_content
from netflix
group by type;

--Task 2. Find the most common rating for movies and TV shows
select type,
rating 
from(select
type,
rating,
count(*),
rank() over( Partition by type order by count(*) Desc) as ranking
from netflix
group by 1,2) as t1
where ranking = 1;

--Task 3. List all movies released in a specific year (e.g., 2020)
--filter 2020
--movies
select * from netflix
where type = 'Movie' 
and 
release_year=2020;

--Task4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM
(
 SELECT 
 UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
 COUNT(*) AS total_content
FROM netflix GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

--Task 5. Identify the longest movie
select * from netflix
where type ='movie' 
and
duration =(select max(duration) from netflix)

--Task 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--Task 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from  netflix
where director ilike '%Rajiv Chilaka%';

--Task 8.List all TV shows with more than 5 seasons
select * from netflix where type= 'TV Show' and SPLIT_PART(duration, ' ', 1)::INT > 5;

--Task 9. Count the number of content items in each genre
SELECT 
UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
COUNT(*) AS total_content
FROM netflix
GROUP BY 1;
/*Task10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!*/
SELECT 
    country,
    release_year,
COUNT(show_id) AS total_release,
ROUND(
 COUNT(show_id)::numeric /
(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC LIMIT 5;

--Task11. List all movies that are documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- Task 12. Find all content without a director
select * from netflix 
where director is null

--Task 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--Task 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;
/*-- Task 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category. */
SELECT 
category,
COUNT(*) AS content_count
FROM (
SELECT 
CASE 
WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
ELSE 'Good'
END AS category
FROM netflix
) AS categorized_content
GROUP BY category;



