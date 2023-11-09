/*This file contains PLSQL code to manage the Products and Customers relationship. I created a package to manipulate the products and customers' data.
Features:
-To Add a Product
-To Add a Customer
-Associate a product with a customer
-Retrieve all products associated with a customer
-Retrieve all customers associated with a product
-Update Customer First Name and Last Name
-Right Transaction Management
-Field validation and exception handling
-Safeguarding sensitive data and preventing SQL Injection(In the below package, I created two PL/SQL procedures, AddCustomer and AddProduct, which insert records into the Customers and Products tables, respectively. These procedures use parameterized queries, which are inherently protected against SQL injection because the parameters are automatically sanitized by the Oracle Database engine)
*/
--  PL/SQL package to encapsulate the operations
CREATE OR REPLACE PACKAGE CustomerProductService AS
    -- 1): Add a new customer
    PROCEDURE AddCustomer(
        p_First_Name IN Customers.First_Name%TYPE,
        p_Last_Name IN Customers.Last_Name%TYPE,
        p_Email_Office IN Customers.Email_Office%TYPE,
        p_Email_Personal IN Customers.Email_Personal%TYPE,
        p_Family_Members IN Customers.Family_Members%TYPE
    );
    
    -- 2): Add a new product
    PROCEDURE AddProduct(
        p_Book_Title IN Products.Book_Title%TYPE,
        p_Book_Price IN Products.Book_Price%TYPE,
        p_Book_Quantity IN Products.Book_Quantity%TYPE
    );
    
    -- 3): Associate a product with a customer
    PROCEDURE AssociateProductWithCustomer(
        p_Customer_ID IN Customers.Customer_ID%TYPE,
        p_Product_ID IN Products.Product_ID%TYPE,
        p_Quantity   IN Products.Book_Quantity%TYPE
    );
    
    -- 4): Retrieve all products associated with a customer
    FUNCTION GetProductsForCustomer(
        p_Customer_ID IN Customers.Customer_ID%TYPE
    ) RETURN SYS_REFCURSOR;
    
    -- 5): Retrieve all customers associated with a product
    FUNCTION GetCustomersForProduct(
        p_Product_ID IN Products.Product_ID%TYPE
    ) RETURN SYS_REFCURSOR;
    -- 6): Update Customer First Name and Last Name
PROCEDURE UpdateCustomer(
        p_Customer_ID IN Customers.Customer_ID%TYPE,
        p_New_First_Name IN Customers.First_Name%TYPE,
        p_New_Last_Name IN Customers.Last_Name%TYPE
    );
END CustomerProductService;
/

-- Create the package body
CREATE OR REPLACE PACKAGE BODY CustomerProductService AS
    -- 1): Add a new customer
    PROCEDURE AddCustomer(
        p_First_Name IN Customers.First_Name%TYPE,
        p_Last_Name IN Customers.Last_Name%TYPE,
        p_Email_Office IN Customers.Email_Office%TYPE,
        p_Email_Personal IN Customers.Email_Personal%TYPE,
        p_Family_Members IN Customers.Family_Members%TYPE
    ) IS
    v_Customer_id number ;
    BEGIN

	IF p_First_Name IS NULL OR p_Last_Name IS NULL THEN
         RAISE_APPLICATION_ERROR(-20001, 'first Name and Last Name must be provided');
    	END IF;
    	select nvl(max(Customer_ID),0)+1 into v_Customer_id from Customers;
        INSERT INTO Customers (Customer_ID, First_Name, Last_Name, Email_Office, Email_Personal, Family_Members)
        VALUES (v_Customer_id, p_First_Name, p_Last_Name, p_Email_Office, p_Email_Personal, p_Family_Members);
    END AddCustomer;
    
    -- 2): Add a new product
    PROCEDURE AddProduct(
        p_Book_Title IN Products.Book_Title%TYPE,
        p_Book_Price IN Products.Book_Price%TYPE,
        p_Book_Quantity IN Products.Book_Quantity%TYPE
    ) IS
    v_Product_id number;
    BEGIN
        select nvl(max(Product_ID),0)+1 into v_Product_id from Products;
        INSERT INTO Products (Product_ID, Book_Title, Book_Price, Book_Quantity)
        VALUES (v_Product_id, p_Book_Title, p_Book_Price, p_Book_Quantity);
    END AddProduct;
    
    -- 3): Associate a product with a customer
    PROCEDURE AssociateProductWithCustomer(
        p_Customer_ID IN Customers.Customer_ID%TYPE,
        p_Product_ID IN Products.Product_ID%TYPE,
        p_Quantity   IN Products.Book_Quantity%TYPE
    ) IS
    BEGIN
        INSERT INTO Customer_Products (Customer_ID, Product_ID, QUANTITY, Trans_Date)
        VALUES (p_Customer_ID, p_Product_ID, p_Quantity, sysdate);
    END AssociateProductWithCustomer;
    
    -- 4): Retrieve all products associated with a customer
    FUNCTION GetProductsForCustomer(
        p_Customer_ID IN Customers.Customer_ID%TYPE
    ) RETURN SYS_REFCURSOR IS
        c SYS_REFCURSOR;
    BEGIN
        OPEN c FOR
        SELECT p.Product_ID, p.Book_Title, p.Book_Price, p.Book_Quantity
        FROM Products p
        JOIN Customer_Products cp ON p.Product_ID = cp.Product_ID
        WHERE cp.Customer_ID = p_Customer_ID;
        RETURN c;
    END GetProductsForCustomer;
    
    -- 5): Retrieve all customers associated with a product
    FUNCTION GetCustomersForProduct(
        p_Product_ID IN Products.Product_ID%TYPE
    ) RETURN SYS_REFCURSOR IS
        c SYS_REFCURSOR;
    BEGIN
        OPEN c FOR
        SELECT c.Customer_ID, c.First_Name, c.Last_Name, c.Email_Office, c.Email_Personal, c.Family_Members
        FROM Customers c
        JOIN Customer_Products cp ON c.Customer_ID = cp.Customer_ID
        WHERE cp.Product_ID = p_Product_ID;
        RETURN c;
    END GetCustomersForProduct;
     
------------------------ This procedure demonstrate the right Transaction Management------------------------------

    -- 6): Update Customer First Name and Last Name
    PROCEDURE UpdateCustomer(
        p_Customer_ID IN Customers.Customer_ID%TYPE,
        p_New_First_Name IN Customers.First_Name%TYPE,
        p_New_Last_Name IN Customers.Last_Name%TYPE
    ) IS
    BEGIN
        -- Savepoint to mark the start of the transaction
        SAVEPOINT start_transaction;

        -- Update the customer's first name and last name
        UPDATE Customers
        SET First_Name = p_New_First_Name, Last_Name = p_New_Last_Name
        WHERE Customer_ID = p_Customer_ID;

        COMMIT;

        -- If any error occurs, then rollback to the save point
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                ROLLBACK TO start_transaction;
                DBMS_OUTPUT.PUT_LINE('No customer Found. Rolling back changes.');
    END UpdateCustomer;
END CustomerProductService;

-- Usage examples
-- 1): Add a new customer
BEGIN
    CustomerProductService.AddCustomer('Ahad', 'Imtiaz', 'ahad@gmail.com', 'ahad1@gmail.com', 1);
END;

-- 2): Add a new product
BEGIN
    CustomerProductService.AddProduct('Programming', 19.99, 100);
END;

-- 3): Associate a product with a customer
BEGIN
    CustomerProductService.AssociateProductWithCustomer(1, 1,40);
END;

-- 4): Retrieve all products associated with a customer
DECLARE
    products_cursor SYS_REFCURSOR;
BEGIN
    products_cursor := CustomerProductService.GetProductsForCustomer(1);
END;

-- 5): Retrieve all customers associated with a product
DECLARE
    customers_cursor SYS_REFCURSOR;
BEGIN
    customers_cursor := CustomerProductService.GetCustomersForProduct(1);
END;
