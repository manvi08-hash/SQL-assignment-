# Q1 (a)
USE classicmodels;

SELECT employeeNumber, firstName, lastName
FROM employees
WHERE jobTitle = 'Sales Rep' AND reportsTo = 1102
LIMIT 0, 1000;
# Q1 (b)
SELECT DISTINCT productLine
FROM products
WHERE productLine LIKE '%cars';
# Q2 
SELECT customerNumber, customerName,
       CASE
           WHEN country IN ('USA', 'Canada') THEN 'North America'
           WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
           ELSE 'Other'
       END AS CustomerSegment
FROM customers;
# Q3 (a)
SELECT productCode, SUM(quantityOrdered) AS totalOrderQuantity
FROM orderdetails
GROUP BY productCode
ORDER BY totalOrderQuantity DESC
LIMIT 10;
# Q3 (b) 
SELECT MONTHNAME(paymentDate) AS month, COUNT(*) AS totalPayments
FROM payments
GROUP BY month
HAVING totalPayments > 20
ORDER BY totalPayments DESC;
# Q4 (a)
CREATE DATABASE Customers_Orders;

USE Customers_Orders;

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);
# Q4 (b) 
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CHECK (total_amount > 0)
);
# Q5 
SELECT c.country, COUNT(o.orderNumber) AS orderCount
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY orderCount DESC
LIMIT 8;
# Q6 
CREATE TABLE project (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male', 'Female'),
    ManagerID INT
);
INSERT INTO project (EmployeeID, FullName, Gender, ManagerID) VALUES
(1, 'Pranaya', 'Male', 3),
(2, 'Priyanka', 'Female', 1),
(3, 'Preety', 'Female', NULL),
(4, 'Anurag', 'Male', 1),
(5, 'Sambit', 'Male', 1),
(6, 'Rajesh', 'Male', 3),
(7, 'Hina', 'Female', 3);
select m.fullname as "managername",e.fullname as "empname" from project e join project m
on e.managerid=m.employeeid;
# Q7 
create table facility(
Facility_ID int not null,
Name varchar(100),
State varchar(100),
Country varchar(100)
);
alter table facility modify Facility_id int auto_increment primary key;
alter table facility add City varchar(100) not null after name;
describe facility;
# Q8 
CREATE VIEW product_category_sales AS
SELECT
    pl.productLine AS productLine,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM
    productlines pl
    JOIN products p ON pl.productLine = p.productLine
    JOIN orderdetails od ON p.productCode = od.productCode
    JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY
    pl.productLine;
# Q9
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_country_payments`(IN input_year INT,  IN input_country VARCHAR(255))
BEGIN
  DECLARE total_amount DECIMAL(10,2);
  SELECT 
    YEAR(p.paymentdate) AS payment_year,
    c.country,
    CONCAT(FORMAT(SUM(amount)/1000, 0),'K') AS Total_Amount
  FROM Payments p
  JOIN Customers c ON p.customernumber = c.customernumber
  WHERE YEAR(p.paymentdate) = input_year
    AND c.country = input_country
  GROUP BY YEAR(p.paymentdate), c.country
  ORDER BY YEAR(p.paymentdate), c.country;
END$$
DELIMITER ;
#Q10 (a)
SELECT 
    customerNumber,
    customerName,
    order_count,
    RANK() OVER (ORDER BY order_count DESC) AS rank_order,
    DENSE_RANK() OVER (ORDER BY order_count DESC) AS dense_rank_order
FROM (
    SELECT 
        c.customerNumber,
        c.customerName,
        COUNT(o.orderNumber) AS order_count
    FROM 
        customers c
        JOIN orders o ON c.customerNumber = o.customerNumber
    GROUP BY 
        c.customerNumber, c.customerName
) AS subquery
ORDER BY 
    order_count DESC;
#Q10 (b)
WITH monthly_order_counts AS (
    SELECT
        YEAR(orderDate) AS order_year,
        MONTHNAME(orderDate) AS order_month,
        COUNT(orderNumber) AS order_count
    FROM
        orders
    GROUP BY
        YEAR(orderDate), MONTH(orderDate), MONTHNAME(orderDate)
),
yoy_change AS (
    SELECT
        order_year,
        order_month,
        order_count,
        LAG(order_count) OVER (PARTITION BY order_month ORDER BY order_year) AS prev_year_order_count
    FROM
        monthly_order_counts
)
SELECT
    order_year,
    order_month,
    order_count,
    CASE 
        WHEN prev_year_order_count IS NULL THEN 'N/A'
        ELSE CONCAT(ROUND((order_count - prev_year_order_count) * 100.0 / prev_year_order_count, 0), '%')
    END AS yoy_percentage_change
FROM
    yoy_change
ORDER BY
    order_year, FIELD(order_month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
#Q11
SELECT 
    productLine,
    COUNT(*) AS product_count
FROM 
    products
WHERE 
    buyPrice > (SELECT AVG(buyPrice) FROM products)
GROUP BY 
    productLine;
#Q12
CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(50),
    EmailAddress VARCHAR(100)
);

DELIMITER //

CREATE PROCEDURE InsertEmp_EH (
    IN p_EmpID INT,
    IN p_EmpName VARCHAR(50),
    IN p_EmailAddress VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Handle the error
        SELECT 'Error occurred' AS ErrorMessage;
    END;
    
    -- Insert statement
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress) 
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);
END //

DELIMITER ;
#Q13
CREATE TABLE Emp_BIT (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date DATE,
    Working_hours INT
);

INSERT INTO Emp_BIT (Name, Occupation, Working_date, Working_hours) VALUES
('Robin', 'Scientist', '2020-10-04', 12),
('Warner', 'Engineer', '2020-10-04', 10),
('Peter', 'Actor', '2020-10-04', 13),
('Marco', 'Doctor', '2020-10-04', 14),
('Brayden', 'Teacher', '2020-10-04', 12),
('Antonio', 'Business', '2020-10-04', 11);
DELIMITER //

CREATE TRIGGER before_insert_Emp_BIT
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END //

DELIMITER ;
