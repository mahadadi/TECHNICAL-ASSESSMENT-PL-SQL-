/*
-------------------------------------------------------------------------------------------------------------
DBMS_SCHEDULER can be used to schedule tasks and jobs at specific time intervals. If we discuss the products and customers relationship, I want to schedule a job to update the product quantity in the Products table every day at a specific time which is 9AM.
-------------------------------------------------------------------------------------------------------------
Firstly Procedure will be created.
*/
-- This procedure can be merged into the package as well, but here is just an example of scheduling on products--

CREATE OR REPLACE PROCEDURE UpdateProductQuantity(
    p_ProductID NUMBER,
    p_NewQuantity NUMBER
) AS
BEGIN
    UPDATE Products
    SET Book_Quantity = p_NewQuantity
    WHERE Product_ID = p_ProductID;
    COMMIT;
END;

--Now, Create a DBMS_SCHEDULER job to schedule the procedure:--

BEGIN
    DBMS_SCHEDULER.create_job (
        job_name        => 'UPDATE_PRODUCT_QUANTITY_JOB',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN UpdateProductQuantity(1, 50); END;',
        start_date      => SYSDATE,
        repeat_interval => 'FREQ=DAILY; BYHOUR=9; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE
    );
END;
--Repeat interval indicates that this procedure will run at 9 AM daily.
/
