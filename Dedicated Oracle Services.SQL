/*
-------------------------------------------------------------------------------------------------------------
Dedicated Oracle Services with specific goal settings are a way to manage the resources and prioritize the execution of PL/SQL blocks 
-------------------------------------------------------------------------------------------------------------

*/
-- Firstly we will define service for the PL/SQL block or task that need to prioritize. 

CREATE SERVICE product_service

--Second step is to set specific performance goals for it. In this example we want to prioritize low response time

BEGIN
  DBMS_SERVICE.MODIFY_SERVICE(
    service_name => 'product_service',
    AQ_HA_NOTIFICATIONS => 0,
    PERFORMANCE_CLASS => 'Low',
    IDLE_TIME => 30
  );
END;

--- Now need to assign the PL/SQL block to the service

ALTER SESSION SET SERVICE_NAME = 'product_service';

-- Now we can run our PLSQL code here
BEGIN
 SELECT Book_Title, Book_Price, Book_Quantity FROM Products ;
END;

By using dedicated Oracle Services with specific goal settings, you can better manage and optimize the interactions between customers and products in your database