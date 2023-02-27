USE sakila;

#Write the queries for extracting the count of rows in any 5 tables of your choice in the Sakila Database
SELECT COUNT(*) FROM actor;
SELECT COUNT(*) FROM city;
SELECT COUNT(*) FROM film;
SELECT COUNT(*) FROM language;
SELECT COUNT(*) FROM store;

#Prepare a list of films sorted by release year in descending order
SELECT * FROM film ORDER BY release_year DESC;

#What is the minimum, maximum and average payment received in the payment table?
SELECT MIN(amount) AS minpay FROM payment;
SELECT MAX(amount) AS maxpay FROM payment;
SELECT AVG(amount) AS avgpay FROM payment;

#Prepare a list of all payments that are higher than the mean payment.
SELECT * FROM payment WHERE amount > (SELECT AVG(amount) FROM payment);

#Prepare a list of movies that are rated R or NC-17 and longer than 90 mins.
SELECT title, rating, length FROM film
	WHERE rating IN ("R", "NC-17") AND length > 90;

#Prepare a list of movies that are rated R or NC-17 and include Deleted Scenes.
SELECT title, rating, special_features FROM film 
	WHERE rating IN ("R", "NC-17") AND special_features REGEXP "Deleted";
    
#Prepare a list of movies that are rated R or NC-17 and include either Deleted Scenes or Behind the Scenes. 
SELECT title, rating, special_features FROM film
	WHERE rating IN ("R", "NC-17") AND special_features REGEXP "Deleted|Behind";
    
#Report the title, Description of the movie or movies that have the words “squirrel” or “monkey” and list them in a descending order of replacement_cost, followed by the descending order of rental_rate.
SELECT title, description, replacement_cost, rental_rate FROM film
	WHERE description REGEXP "squirrel|monkey"
		ORDER BY replacement_cost DESC, rental_rate DESC;

#Report the count of movies such that the difference between their replacement_cost and rental_rate is less than 10.00       
SELECT COUNT(title) FROM film
	WHERE replacement_cost-rental_rate < 10.00;

#Read through as many movie descriptions as you want from the table film and create a shortlist of your own top 3 funniest movie descriptions. Now write a query (or can be three queries) that displays the film title, description for those movies in lower case.
SELECT LOWER(title), LOWER(description) FROM film
	WHERE title IN ("Annie Identity", "Betrayed Rear", "Breaking Home");