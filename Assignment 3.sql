USE sakila;

#Write a query that finds, for each customer X, another customer Y who has rented atleast one movie in common with X. Find all such pairs of Customers (X, Y) and against each pair, the number of overlapping movies. The query should thus have three columns. Order the results by the number of overlapping movies
CREATE VIEW customer_movie AS 
	(SELECT c.customer_id, i.film_id FROM customer c
    JOIN rental r on c.customer_id = r.customer_id
    JOIN inventory i on r.inventory_id = i.inventory_id);

SELECT cust1.customer_id AS Cust_X, cust2.customer_id AS Cust_Y, COUNT(cust1.film_id) FROM customer_movie cust1
	JOIN customer_movie cust2 ON cust1.film_id = cust2.film_id
    WHERE cust1.customer_id < cust2.customer_id
    GROUP BY cust1.customer_id, cust2.customer_id
    ORDER BY COUNT(cust1.film_id) DESC;
    
#Identify the five actors who share the greatest number of films with NICK WAHLBERG.
CREATE VIEW filmactors AS
	(SELECT actor.actor_id, actor.first_name, actor.last_name, film_actor.film_id FROM actor
    JOIN film_actor ON actor.actor_id = film_actor.actor_id);

SELECT act2.first_name AS actor_firstname, act2.last_name AS actor_lastname, COUNT(act2.film_id) FROM filmactors act1
	JOIN filmactors act2 ON act1.film_id = act2.film_id
    WHERE act1.first_name = "NICK" AND act1.last_name = "WAHLBERG"
    GROUP BY act2.first_name, act2.last_name
    ORDER BY COUNT(act2.film_id) DESC, actor_firstname LIMIT 6;

#Write a query that finds, for each customer X, another customer Y who has rented movies from the same actor. Find all such pairs of Customers (X, Y) and against each pair, the overlapping number of actors. The query should thus have three columns. Order the results by the number of overlapping actors
CREATE TABLE customer_actor AS
	(SELECT customer.customer_id, film_actor.actor_id FROM customer
    JOIN rental ON customer.customer_id = rental.customer_id
    JOIN inventory ON rental.inventory_id = inventory.inventory_id
    JOIN film ON inventory.film_id = film.film_id
    JOIN film_actor ON film.film_id = film_actor.film_id);

SELECT cust1.customer_id AS Cust_X, cust2.customer_id AS Cust_Y, COUNT(cust1.actor_id) FROM customer_actor cust1
	JOIN customer_actor cust2 ON cust1.actor_id = cust2.actor_id
	WHERE cust1.customer_id < cust2.customer_id
    GROUP BY cust1.customer_id, cust2.customer_id
    ORDER BY COUNT(cust1.actor_id) DESC;
    
#Write a query that finds, for each customer X, another customer Y who has rented movies from the same actor and calculate the number of such common films that they have rented out for these overlapping actors. Find all such pairs of Customers (X, Y) and against each pair, the overlapping number of actors, and the overlapping number of films of the actors that they have in common. Order the results by the number of overlapping films.
CREATE TABLE customer_actor_film AS
	(SELECT customer.customer_id, film_actor.actor_id, film_actor.film_id FROM customer
    JOIN rental ON customer.customer_id = rental.customer_id
    JOIN inventory ON rental.inventory_id = inventory.inventory_id
    JOIN film ON inventory.film_id = film.film_id
    JOIN film_actor ON film.film_id = film_actor.film_id);
    
SELECT cust1.customer_id AS Cust_X, cust2.customer_id AS Cust_Y, COUNT(cust1.actor_id), COUNT(cust1.film_id) FROM customer_actor_film cust1
	JOIN customer_actor_film cust2 ON cust1.actor_id = cust2.actor_id
	WHERE cust1.customer_id < cust2.customer_id
    GROUP BY cust1.customer_id, cust2.customer_id
    ORDER BY COUNT(cust1.film_id) DESC;

#Create a list of actor pairs along with the number of films that they have in common.
CREATE TABLE actor_movie AS 
	(SELECT actor.actor_id, film_actor.film_id FROM actor
    JOIN film_actor on actor.actor_id = film_actor.actor_id);

SELECT act1.actor_id AS Act_1, act2.actor_id AS Act_2, COUNT(act1.film_id) FROM actor_movie act1
	JOIN actor_movie act2 ON act1.film_id = act2.film_id
    WHERE act1.actor_id < act2.actor_id
    GROUP BY act1.actor_id, act2.actor_id
    ORDER BY COUNT(act1.film_id) DESC;
    
#Create a list of customers that have never rented out even a single movie from the top 5 actors (the list of top actors is calculated by rental volume).
CREATE VIEW top_actors AS
	(SELECT actor.actor_id, COUNT(rental.rental_id) AS rental_volume FROM actor
	JOIN film_actor ON actor.actor_id = film_actor.actor_id
    JOIN film ON film_actor.film_id = film.film_id
    JOIN inventory ON film.film_id = inventory.film_id
    JOIN rental ON inventory.inventory_id = rental.inventory_id
    GROUP BY actor.actor_id
	ORDER BY rental_volume DESC LIMIT 5);

CREATE VIEW top_actormovies AS
	(SELECT film_id FROM film_actor
	WHERE actor_id IN (SELECT actor_id FROM top_actors));

CREATE VIEW customer_seen_topactormovies AS
	(SELECT customer.customer_id FROM customer
	JOIN rental ON customer.customer_id = rental.customer_id
    JOIN inventory ON rental.inventory_id = inventory.inventory_id
    JOIN film ON inventory.film_id = film.film_id
    WHERE film.film_id IN (SELECT * FROM top_actormovies)
    GROUP BY customer.customer_id);

SELECT customer_id FROM customer
	WHERE customer_id NOT IN (SELECT * FROM customer_seen_topactormovies);