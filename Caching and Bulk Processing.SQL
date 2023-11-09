/*
-------------------------------------------------------------------------------------------------------------
Caching and bulk processing are advanced techniques that can significantly improve the performance of database operation.
-------------------------------------------------------------------------------------------------------------

*/
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Bulk processing is particularly useful when dealing with large datasets and can be implemented using PL/SQL collections like PL/SQL tables and BULK COLLECT.
--Here is the example to update product quantities in bulk
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--PL/SQL block for bulk updating product quantities
DECLARE
    TYPE ProductIDList IS TABLE OF NUMBER;
    TYPE NewQuantityList IS TABLE OF NUMBER;
    l_ProductIDs ProductIDList;
    l_NewQuantities NewQuantityList;
BEGIN
    l_ProductIDs := ProductIDList(123, 124, 125); -- IDs of products to update
    l_NewQuantities := NewQuantityList(50, 60, 70); -- New quantities

    -- Bulk update using FORALL
    FORALL i IN 1..l_ProductIDs.COUNT
        UPDATE Products
        SET Book_Quantity = l_NewQuantities(i)
        WHERE Product_ID = l_ProductIDs(i);

    COMMIT;
END;

-- Using FORALL statement to perform a bulk update of product quantities, which is more efficient than individual updates in a loop.


-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Result Cache is used to store query results in memory for faster retrieval of data
-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Result Cache for the query
CREATE OR REPLACE FUNCTION GetProductByTitleCached(p_Title VARCHAR2)
RETURN NUMBER  RESULT_CACHE RELIES_ON(Products)
AS
  quantity number;
BEGIN

    SELECT BOOK_QUANTITY
    INTO quantity
    FROM Products
    WHERE Book_Title = p_Title;
    
  RETURN quantity;
END;

SELECT GetProductByTitleCached('Programming') from dual;

--By using RESULT_CACHE it will not execute queries multiple times if same input will be provided