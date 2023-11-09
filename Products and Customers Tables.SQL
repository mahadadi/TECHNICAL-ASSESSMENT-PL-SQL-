/*
---------------------------------------------------------------------------------------------------------------
Firstly I create the tables to illustrate a relationship between Customers and Tables
---------------------------------------------------------------------------------------------------------------
*/

- Table to store Customer data
CREATE TABLE Customers (
    Customer_ID NUMBER PRIMARY KEY,
    First_Name VARCHAR2(50),
    Last_Name VARCHAR2(50),
    Email_Office VARCHAR2(100),
    Email_Personal VARCHAR2(100),
    Family_Members NUMBER
);

-- Table to store Product data
CREATE TABLE Products (
    Product_ID NUMBER PRIMARY KEY,
    Book_Title VARCHAR2(100),
    Book_Price NUMBER,
    Book_Quantity NUMBER
);

-- Create a table to associate customers with products
CREATE TABLE Customer_Products (
    Customer_ID NUMBER,
    Product_ID NUMBER,
    Quantity   NUMBER,
    Trans_Date DATE,
    CONSTRAINT cust_prod_fk1 FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    CONSTRAINT cust_prod_fk2 FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);