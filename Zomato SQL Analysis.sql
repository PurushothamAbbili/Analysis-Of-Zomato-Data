CREATE DATABASE Zomato_DB;

USE Zomato_DB;

DROP TABLE IF EXISTS goldusers_signup;

CREATE TABLE goldusers_signup(
	userid INT PRIMARY KEY NOT NULL,
    gold_signup_date DATE
);

INSERT INTO goldusers_signup
	(userid, gold_signup_date)
 VALUES 
	(1,'2017-09-22'),
	(3,'2017-04-21');

DROP TABLE IF EXISTS users;

CREATE TABLE users(
	userid INT NOT NULL,
    signup_date DATE
);

INSERT INTO users
	(userid, signup_date) 
 VALUES 
	(1,'2014-09-02'),
	(2,'2015-01-15'),
	(3,'2014-04-11');

DROP TABLE IF EXISTS sales;

CREATE TABLE sales(
    userid INT NOT NULL,
    created_date DATE,
    product_id INT
);

INSERT INTO sales
	(userid, created_date, product_id) 
 VALUES 
	(1,'2017-04-19',2),
	(3,'2019-12-18',1),
	(2,'2020-07-20',3),
	(1,'2019-10-23',2),
	(1,'2018-03-19',3),
	(3,'2016-12-20',2),
	(1,'2016-11-09',1),
	(1,'2016-05-20',3),
	(2,'2017-09-24',1),
	(1,'2017-03-11',2),
	(1,'2016-03-11',1),
	(3,'2016-11-10',1),
	(3,'2017-12-07',2),
	(3,'2016-12-15',2),
	(2,'2017-11-08',2),
	(2,'2018-09-10',3);


DROP TABLE IF EXISTS product;

CREATE TABLE product(
    product_id INT NOT NULL,
    product_name VARCHAR(30),
    price INT
);

INSERT INTO product
	(product_id, product_name, price) 
 VALUES
	(1,'p1',980),
	(2,'p2',870),
	(3,'p3',330);
    
SHOW TABLES;

SELECT * FROM goldusers_signup;
SELECT * FROM product;
SELECT * FROM sales;
SELECT * FROM users;

-- 1. What is the total amount each customer spent on zomato?
SELECT 
	s.userid,
    SUM(p.price) AS TotalAmount
FROM
	sales s 
JOIN
	product p 
ON 
	s.product_id = p.product_id
GROUP BY 
	s.userid
ORDER BY
	1;
    

-- 2. How many days has each customer visited zomato?
SELECT
	userid,
	COUNT(DISTINCT created_date) AS NoOfDays
FROM
	sales
GROUP BY 
	userid;
    

-- 3. what was the first product purchased by each customer?
WITH FinalTable AS(
	SELECT
		s.userid,
        s.created_date AS FirstOrderdDate,
		p.product_name,
		RANK() OVER(PARTITION BY s.userid ORDER BY created_date) AS rnk
	FROM
		sales s 
	JOIN
		product p
	ON
		s.product_id = p.product_id)

SELECT
	*
FROM
	FinalTable
WHERE
	rnk = 1;
    
    
-- 4. what is the most purchased item on the menu & how many times was it purchased by all customers?
WITH FinalTable AS(
	SELECT
		s.userid,
        s.created_date,
        s.product_id,
        p.product_name
	FROM
		sales s
	JOIN
		product p
	ON
		s.product_id = p.product_id
)

SELECT 
	MAX(product_id) AS MostPurchasedItem,
    COUNT(product_id) AS TotalNoOfTimesPurchased
FROM
	FinalTable;
    
    
-- 5. Which item was most popular for each customer?
WITH sales_count AS(
  SELECT 
    userid, 
    product_id, 
    COUNT(product_id) AS cnt 
  FROM 
    sales 
  GROUP BY 
    userid, 
    product_id
),
ranked_sales AS(
  SELECT 
    *, 
    RANK() OVER (PARTITION BY userid ORDER BY cnt DESC) AS rnk 
  FROM 
    sales_count
)
SELECT 
  * 
FROM 
  ranked_sales 
WHERE 
  rnk = 1;
  
  
-- 6. Which item was purchased first by customers after they become a member?
SELECT 
	*
FROM(
	SELECT 
		c.*,
		RANK() OVER(PARTITION BY userid ORDER BY created_date ) AS rnk
	FROM(
		SELECT 
			a.userid,
			a.created_date,
			a.product_id,
			b.gold_signup_date
		FROM
			sales a
		INNER JOIN
			goldusers_signup b
		ON
			a.userid = b.userid
		AND 
			created_date >= gold_signup_date
	) c
) d
WHERE  rnk = 1;


-- 7. Which item was purchased just before the customer became a member?
SELECT 
	*
FROM(
	SELECT 
		c.*,
		RANK() OVER(PARTITION BY userid ORDER BY created_date DESC ) AS rnk
	FROM(
		SELECT 
			a.userid,
			a.created_date,
			a.product_id,
			b.gold_signup_date
		FROM
			sales a
		INNER JOIN
			goldusers_signup b
		ON
			a.userid = b.userid
		AND 
			created_date <= gold_signup_date
	) c
) d
WHERE  rnk = 1;


-- 8. what are the total orders and amount spent for each member before they become a member?
SELECT 
	userid,
	COUNT(created_date) AS order_purchased,
	SUM(price) AS total_amt_spent
FROM(
	SELECT 
		c.*,
		d.price
	FROM(
		SELECT
			a.userid,
			a.created_date,
			a.product_id,
			b.gold_signup_date
		FROM
			sales a
		INNER JOIN
			goldusers_signup b
		ON 
			a.userid = b.userid
		AND 
			created_date <= gold_signup_date
	) c
INNER JOIN 
	product d
ON 
	c.product_id = d.product_id
)e
GROUP  BY 
	userid;
    

-- 9. Rank all transactions of the customers
SELECT
	*,
	Rank() OVER(PARTITION BY userid ORDER BY created_date) AS rnk
FROM   
	sales;
    
    
-- 10. Rank all transactions for each member whenever they are zomato gold members for every nongold member transaction marked as NA
SELECT 
	e.*,
	CASE 
		WHEN rnk = 0 THEN 'na'
		ELSE rnk
		END AS rnkk
FROM(
	SELECT 
		c.*,
		CASE
				WHEN gold_signup_date IS NULL THEN 0
				ELSE RANK() OVER(PARTITION BY userid ORDER BY created_date DESC)
			END  AS rnk
	FROM(
		SELECT
			a.userid,
			a.created_date,
			a.product_id,
			b.gold_signup_date
		FROM
			sales a
		LEFT JOIN
			goldusers_signup b
		ON
			a.userid = b.userid
		AND 
			created_date >= gold_signup_date
	)c
)e; 