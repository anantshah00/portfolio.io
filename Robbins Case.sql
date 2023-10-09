CREATE database carservice; 
USE carservice;

CREATE TABLE customer(
customerID INT,
first_name VARCHAR(50),
last_name VARCHAR(50),
email VARCHAR(100),
address VARCHAR(100),
city VARCHAR(100),
zip INT,
telephone INT); 

CREATE TABLE vehicle(
vehicleID INT,
customerID INT,
make VARCHAR(50),
model VARCHAR(100),
year INT,
color VARCHAR(100)
); 

CREATE TABLE technician(
techID int,
first_name VARCHAR(50),
last_name VARCHAR(50),
telephone VARCHAR(100),
certification VARCHAR(10),
email VARCHAR(100)
); 

CREATE TABLE appointment(
appointmentID INT,
dateofapt datetime,
techID INT,
customerID INT); 

CREATE TABLE service(
serviceID INT,
appointmentID INT,
customerID INT,
techID INT,
vehicleID INT,
description VARCHAR(250),
price int,
cost int
); 

SELECT*FROM service;
SELECT*FROM appointment;
SELECT*FROM technician;
SELECT*FROM vehicle;
SELECT*FROM customers;

-- Because data was generated randomly, it is possible, even likely, that some of
-- the customers have no appointments. Create a query that lists all customers having no appointments.
-- Note that there might be other inconsistencies in the data that we will not worry about for this
-- exercise.

Create view customer_noapp as
SELECT customer.customerID, customer.first_name, customer.last_name
FROM customer
LEFT JOIN appointment USING (customerID)
WHERE appointment.appointID IS NULL;
SELECT * FROM customer_noapp;

-- Write a query that displays each make and model in one column, i.e. Jaguar F-
-- Type, Robbins has serviced. Each make and model should appear only once in the result set. For this
-- query ignore the year of manufacture.

SELECT DISTINCT CONCAT(make, ' ', model) AS "Make and Model"
FROM vehicle;

-- Robbins needs to have a list of technicians and their contact information
-- to contact them in the event of a schedule change call. Create a query that lists all technicians and
-- their contact information.


SELECT first_name, last_name, email, telephone
FROM technician;

-- Robbins would like to create a query that shows all of the
-- appointments and services for a specific date. Include any relevant data columns. As an example of
-- this type of query write it choosing any date that you know has appointments

SELECT customer.first_name, customer.last_name, appointment.date, 
technician.techID, technician.first_name AS technicianfirstname, technician.last_name AS technicianlastname
FROM appointment
JOIN technician ON appointment.techID = technician.techID
JOIN customer ON appointment.customerID = customer.CustomerID
JOIN vehicle ON appointment.customerID = vehicle.customerID
WHERE appointment.date = "2023-06-09"
ORDER BY appointment.date LIMIT 1
;

-- To implement a commercial excellence program, Robbins would like to contact
-- customers who haven’t been in for an oil service in the last 120 days. Write a query to identify these
-- customers and include their phone number, email and vehicle info

SELECT customer.CustomerID,
       customer.first_name,
       customer.last_name,
       customer.telephone,
       Customer.email,
       vehicle.vehicleID,
       Vehicle.make,
       Vehicle.color,
       Vehicle.model,
       vehicle.year
FROM customer
JOIN vehicle ON customer.CustomerID = vehicle.CustomerID
WHERE vehicle.CustomerID NOT IN (
    SELECT DISTINCT customer.CustomerID
    FROM customer
    JOIN service ON customer.CustomerID = service.customerID
    JOIN appointment ON appointment.appointID = service.appointmentID
    WHERE service.description = 'oil service'
    AND appointment.date>= DATE_SUB(CURDATE(), INTERVAL 120 DAY)
);

-- Robbins would like to see how much revenue each
-- technician is responsible for. Create a query that displays each technician, number of
-- appointments they have overseen, average revenue and the total revenue generated from
-- these appointments. Note the technician name should appear in one field for the query. The
-- query should be sorted with highest revenue listed first

SELECT
    CONCAT(Technician.first_name, ' ', Technician.last_name) AS TechnicianName,
    COUNT(Appointment.appointID) AS NumberOfAppointments,
    AVG(Service.Price) AS AverageRevenue,
    SUM(Service.Price) AS TotalRevenue
FROM Technician
LEFT JOIN Appointment ON Technician.techID = Appointment.techID
LEFT JOIN Service ON Appointment.appointID = Service.appointmentID
GROUP BY TechnicianName
ORDER BY TotalRevenue DESC;


-- Build a query that displays the total revenue,
-- (price), dollars spent (cost), gross margin (price – cost) and percentage of gross margin for
-- each of the services. Each service should be listed only once. Sort by highest Gross Margin
-- first

SELECT description AS Service_Description,
SUM(price) AS Total_Revenue,
ROUND(SUM(cost),2) as Total_Cost,
ROUND(SUM(price-cost),2) AS Gross_Margin,
ROUND((SUM(price-cost)/SUM(price))*100,2) AS GM_Percentage
FROM service
GROUP BY description
ORDER BY Gross_Margin DESC;

-- Create a query that displays the top ten customers by revenue
SELECT customer.customerID, customer.first_name, customer.last_name, sum(service.price) AS TotalRevenue
FROM customer
JOIN service ON customer.customerID = service.customerID
GROUP BY customer.customerID, customer.first_name, customer.last_name 
ORDER BY TotalRevenue LIMIT 10;

-- Robbins would like to determine if they experience a constant level
-- of Appointments each month. Write a query that counts the number appointments in each month,
-- and year. The query should display the month name and the number of visits corresponding to each
-- month in each year

SELECT DATE_FORMAT(date, '%Y-%m') AS YearMonth,
COUNT(*) AS AppointmentCount
FROM appointment
GROUP BY YearMonth
ORDER BY YearMonth;
