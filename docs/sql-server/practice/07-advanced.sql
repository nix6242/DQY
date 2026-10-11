USE DQY_SQL_Lab;
GO
CREATE OR ALTER VIEW dbo.vw_PaidOrderTotals
AS
SELECT o.OrderID,o.CustomerID,o.OrderDate,
       CAST(SUM(oi.Quantity*oi.UnitPrice) AS decimal(18,2)) AS OrderTotal
FROM dbo.Orders o JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID
WHERE o.Status='Paid'
GROUP BY o.OrderID,o.CustomerID,o.OrderDate;
GO
CREATE OR ALTER VIEW dbo.vw_FactPaidSales
AS
SELECT o.OrderID,oi.ProductID,o.CustomerID,CAST(o.OrderDate AS date) AS OrderDate,
       oi.Quantity,oi.UnitPrice,CAST(oi.Quantity*oi.UnitPrice AS decimal(18,2)) AS LineAmount
FROM dbo.Orders o JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID
WHERE o.Status='Paid';
GO
CREATE OR ALTER PROCEDURE dbo.usp_GetPaidOrdersByDate
    @FromDate date,
    @ToDateExclusive date
AS
BEGIN
    SET NOCOUNT ON;
    IF @FromDate IS NULL OR @ToDateExclusive IS NULL OR @FromDate>=@ToDateExclusive
        THROW 50201,N'Ngày đầu phải nhỏ hơn ngày cuối; ngày cuối không bao gồm.',1;
    SELECT OrderID,CustomerID,OrderDate,OrderTotal FROM dbo.vw_PaidOrderTotals
    WHERE OrderDate>=@FromDate AND OrderDate<@ToDateExclusive
    ORDER BY OrderDate,OrderID;
END;
GO
-- Ví dụ đơn có 1 sản phẩm. Hệ thống thật thường cần input nhiều dòng/TVP,
-- idempotency và quy tắc hủy/hoàn tiền riêng; không tự gọi proc cho từng line của 1 đơn.
CREATE OR ALTER PROCEDURE dbo.usp_CreateOrder
    @CustomerID int,
    @ProductID int,
    @Quantity int,
    @OrderID int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @OrderID=NULL;
    IF @Quantity IS NULL OR @Quantity<=0 THROW 50202,N'Quantity phải > 0.',1;
    IF @CustomerID IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.Customers WHERE CustomerID=@CustomerID)
        THROW 50203,N'CustomerID không tồn tại.',1;
    DECLARE @Started bit=CASE WHEN @@TRANCOUNT=0 THEN 1 ELSE 0 END;
    IF @Started=1 BEGIN TRANSACTION;
    ELSE SAVE TRANSACTION CreateOrderSave;
    BEGIN TRY
        DECLARE @Price decimal(18,2),@Stock int;
        SELECT @Price=Price,@Stock=Stock FROM dbo.Products WITH(UPDLOCK,HOLDLOCK) WHERE ProductID=@ProductID;
        IF @Price IS NULL THROW 50204,N'ProductID không tồn tại.',1;
        IF @Stock<@Quantity THROW 50205,N'Tồn kho không đủ.',1;
        UPDATE dbo.Products SET Stock=Stock-@Quantity
        WHERE ProductID=@ProductID AND Stock>=@Quantity;
        IF @@ROWCOUNT<>1 THROW 50206,N'Không cập nhật được tồn kho.',1;
        INSERT dbo.Orders(CustomerID,OrderDate,Status) VALUES(@CustomerID,SYSUTCDATETIME(),'Pending');
        SET @OrderID=CONVERT(int,SCOPE_IDENTITY());
        INSERT dbo.OrderItems(OrderID,ProductID,Quantity,UnitPrice) VALUES(@OrderID,@ProductID,@Quantity,@Price);
        IF @Started=1 COMMIT;
    END TRY
    BEGIN CATCH
        SET @OrderID=NULL;
        IF @Started=1 AND XACT_STATE()<>0 ROLLBACK;
        ELSE IF @Started=0 AND XACT_STATE()=1 ROLLBACK TRANSACTION CreateOrderSave;
        -- XACT_STATE=-1 trong caller transaction: caller phải ROLLBACK toàn bộ.
        THROW;
    END CATCH;
END;
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Orders') AND name=N'IX_Orders_Status_OrderDate')
    CREATE INDEX IX_Orders_Status_OrderDate ON dbo.Orders(Status,OrderDate) INCLUDE(CustomerID);
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Orders') AND name=N'IX_Orders_CustomerID_OrderDate')
    CREATE INDEX IX_Orders_CustomerID_OrderDate ON dbo.Orders(CustomerID,OrderDate) INCLUDE(Status);
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.OrderItems') AND name=N'IX_OrderItems_ProductID')
    CREATE INDEX IX_OrderItems_ProductID ON dbo.OrderItems(ProductID) INCLUDE(Quantity,UnitPrice);
GO
-- KPI Power BI: fact grain=(OrderID,ProductID), 11 rows, 6 orders, 4 customers,
-- 20 units, 57.2m revenue; bảng Customers/Products là dimensions.
IF (SELECT COUNT(*) FROM dbo.vw_FactPaidSales)<>11 THROW 50210,N'Fact phải có 11 dòng.',1;
IF (SELECT SUM(LineAmount) FROM dbo.vw_FactPaidSales)<>57200000 THROW 50211,N'Fact revenue sai.',1;
IF (SELECT COUNT(DISTINCT CustomerID) FROM dbo.vw_FactPaidSales)<>4 THROW 50212,N'Active Customers phải là 4.',1;
SELECT COUNT(*) AS FactRows,COUNT(DISTINCT OrderID) AS PaidOrders,
       COUNT(DISTINCT CustomerID) AS ActiveCustomers,SUM(Quantity) AS Units,
       SUM(LineAmount) AS Revenue,
       CAST(SUM(LineAmount)/NULLIF(COUNT(DISTINCT OrderID),0) AS decimal(18,2)) AS AverageOrderValue
FROM dbo.vw_FactPaidSales;
EXEC dbo.usp_GetPaidOrdersByDate @FromDate='2025-01-01',@ToDateExclusive='2025-02-01';
GO
-- Thành công: tạo đơn tạm, xác nhận tồn kho giảm/giá snapshot, rồi hoàn tác.
-- Không để lại đơn thật. Có thể có khoảng trống IDENTITY sau ROLLBACK.
IF @@TRANCOUNT<>0 THROW 50213,N'Hãy đóng transaction cũ trước demo.',1;
DECLARE @Stock int=(SELECT Stock FROM dbo.Products WHERE ProductID=2),@NewID int;
BEGIN TRY
    BEGIN TRANSACTION;
    EXEC dbo.usp_CreateOrder @CustomerID=1,@ProductID=2,@Quantity=2,@OrderID=@NewID OUTPUT;
    IF @NewID IS NULL OR (SELECT Stock FROM dbo.Products WHERE ProductID=2)<>@Stock-2
        THROW 50214,N'CreateOrder không giảm tồn kho chính xác.',1;
    IF NOT EXISTS(SELECT 1 FROM dbo.OrderItems WHERE OrderID=@NewID AND ProductID=2 AND Quantity=2 AND UnitPrice=300000)
        THROW 50215,N'Snapshot giá/số lượng của đơn mới không đúng.',1;
    SELECT @NewID AS TemporaryOrderID,Stock AS TemporaryStock FROM dbo.Products WHERE ProductID=2;
    ROLLBACK;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    THROW;
END CATCH;
IF (SELECT Stock FROM dbo.Products WHERE ProductID=2)<>@Stock
    THROW 50216,N'ROLLBACK không phục hồi tồn kho.',1;
IF (SELECT COUNT(*) FROM dbo.Orders)<>8 THROW 50217,N'Demo để lại đơn mới.',1;
GO
-- Thất bại: mua quá tồn kho; proc tự ROLLBACK transaction do nó mở.
IF @@TRANCOUNT<>0 THROW 50221,N'Hãy đóng transaction cũ trước test tồn kho.',1;
DECLARE @Caught int=0,@OrderID int;
BEGIN TRY
    EXEC dbo.usp_CreateOrder @CustomerID=1,@ProductID=2,@Quantity=999999,@OrderID=@OrderID OUTPUT;
END TRY
BEGIN CATCH
    SET @Caught=ERROR_NUMBER();
END CATCH;
IF @Caught<>50205 THROW 50218,N'Expected lỗi tồn kho 50205.',1;
IF @@TRANCOUNT<>0 THROW 50219,N'Proc để lại transaction mở sau lỗi.',1;
IF (SELECT Stock FROM dbo.Products WHERE ProductID=2)<>50 OR (SELECT COUNT(*) FROM dbo.Orders)<>8
    THROW 50220,N'Thất bại không giữ nguyên tồn kho/đơn.',1;
SELECT N'PASS: views, KPI, indexes, procedure success rollback + shortage rollback' AS AdvancedResult;
GO
-- Quan sát bằng SSMS Actual/Estimated Execution Plan; tiny seed không chứng minh scale.
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT OrderID,CustomerID,OrderDate FROM dbo.Orders
WHERE Status='Paid' AND OrderDate>='2025-01-01' AND OrderDate<'2025-02-01';
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO
