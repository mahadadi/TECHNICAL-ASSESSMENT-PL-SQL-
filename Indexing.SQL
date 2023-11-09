/*
Using indexes on columns that are frequently searched or used in WHERE clauses can significantly improve query performance, especially when dealing with large datasets.
*/

--example:

CREATE INDEX Customers_FirstName_IDX
    ON Customers (First_Name);

CREATE INDEX Products_Title_IDX
    ON Products (Book_Title);

--I created the indexes on the First_Name column of the Customers table and the Book_Title column of the Products table, so when I run the query it significantly improve query performance.

SELECT *
FROM Customers
WHERE First_Name = 'Ahad';

--In this query, the Customers_FirstName_IDX index will be used to quickly locate all customers with the first name 'Ahad'