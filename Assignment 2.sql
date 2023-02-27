USE sakila;

#Calculate the total amount ($) of all transactions for each of the top 100 customers
 SELECT customer.customer_id, SUM(amount) AS totalamount	FROM customer
	JOIN payment ON customer.customer_id = payment.customer_id
	GROUP BY customer_id
    ORDER BY customer_id LIMIT 100;
 
 
#Compute the total number of rentals for movies that have one or more of the following words in its description: ‘cat’, ‘boy’, ‘love’.
 SELECT COUNT(rental_id) AS rental_count FROM rental
	JOIN inventory ON rental.inventory_id = inventory.inventory_id
    JOIN film ON inventory.film_id = film.film_id
    WHERE description REGEXP ('cat|boy|love');


#What is the average running time of films by category?
SELECT category.name, AVG (length) AS avg_length FROM film
    JOIN film_category 
    ON film.film_id = film_category.film_id
    JOIN category
    ON category.category_id = film_category.category_id
    GROUP BY category.name;
 
 
#Which first names appear more than once in the customer table?
 SELECT first_name, COUNT(*) FROM customer
    GROUP BY first_name
    HAVING COUNT(*)>1;
 
 
#List average payment amounts by store address.
 SELECT address.address, AVG (amount) AS p FROM payment 
    JOIN customer ON payment.customer_id=customer.customer_id
    JOIN store ON customer.store_id = store.store_id
    JOIN address ON store.address_id = address.address_id
    GROUP BY address;
 
#Using join obtain the list of movies in English Language that start with letter K
 SELECT title FROM film
    JOIN language
    ON language.language_id=film.language_id
    WHERE title like 'K%' AND name ='English';

#Without using joins obtain the list of movies in English Language that start with letter K.
SELECT title FROM film
    WHERE film.language_id IN
   (SELECT language_id FROM language WHERE name ='English')
    AND title like 'K%';


#Find out the list of addresses that lie in the city/cities that have the maximum number of addresses in the address table.
SELECT address, city FROM address
    JOIN city ON address.city_id = city.city_id
    WHERE city.city IN (SELECT city FROM address
    JOIN city ON address.city_id = city.city_id
    GROUP BY city.city
    HAVING COUNT(address.address) = (SELECT MAX(count1) FROM
   (SELECT city.city, COUNT(address.address) AS count1 FROM address
    JOIN city ON address.city_id = city.city_id
    GROUP BY city.city) AS maxaddresses));
 

#List the film titles and count of their inventories (copies), for movies that have two or more copies of the film available.
SELECT title, COUNT(inventory_id) AS inventory_count FROM film, inventory 
    WHERE film.film_id=inventory.film_id
    GROUP BY title 
    HAVING inventory_count >=2;


#List a query that list the film genres and gross revenue for that genre, conditional to the gross revenue for that genre being higher than average gross revenue per genre. 
CREATE VIEW grossrev AS
	SELECT category.name, SUM(payment.amount) AS grossrev FROM category 
    JOIN film_category ON category.category_id = film_category.category_id
    JOIN film ON film_category.film_id = film.film_id
    JOIN inventory ON film.film_id = inventory.film_id
    JOIN rental ON inventory.inventory_id = rental.inventory_id
    JOIN payment ON rental.rental_id = payment.rental_id
    GROUP BY category.name;
    
SELECT * FROM grossrev WHERE grossrev > (SELECT AVG(grossrev) FROM grossrev);





