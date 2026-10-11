USE DQY_SQL_Lab;
GO
SET NOCOUNT ON;
-- Chạy ngay sau seed, hoặc sau các demo đã ROLLBACK. Dừng khi dữ liệu lệch.
IF @@TRANCOUNT<>0 THROW 50100,N'Đang có transaction mở; COMMIT/ROLLBACK đúng ý định trước.',1;
IF (SELECT COUNT(*) FROM dbo.Customers)<>6 THROW 50101,N'Customers phải có 6 dòng.',1;
IF (SELECT COUNT(*) FROM dbo.Products)<>6 THROW 50102,N'Products phải có 6 dòng.',1;
IF (SELECT COUNT(*) FROM dbo.Orders)<>8 THROW 50103,N'Orders phải có 8 dòng.',1;
IF (SELECT COUNT(*) FROM dbo.OrderItems)<>13 THROW 50104,N'OrderItems phải có 13 dòng.',1;
IF (SELECT COUNT(*) FROM dbo.Orders WHERE Status='Paid')<>6 THROW 50105,N'Phải có 6 đơn Paid.',1;
IF (SELECT COUNT(*) FROM dbo.Orders WHERE Status='Pending')<>1 THROW 50106,N'Phải có 1 đơn Pending.',1;
IF (SELECT COUNT(*) FROM dbo.Orders WHERE Status='Cancelled')<>1 THROW 50107,N'Phải có 1 đơn Cancelled.',1;
IF (SELECT COUNT(*) FROM dbo.Customers c WHERE NOT EXISTS(SELECT 1 FROM dbo.Orders o WHERE o.CustomerID=c.CustomerID))<>2
    THROW 50108,N'Phải có 2 khách chưa có đơn.',1;
IF (SELECT COUNT(*) FROM dbo.Products p WHERE NOT EXISTS(SELECT 1 FROM dbo.OrderItems oi WHERE oi.ProductID=p.ProductID))<>1
    THROW 50109,N'Phải có 1 sản phẩm chưa được đặt.',1;
IF (SELECT SUM(oi.Quantity*oi.UnitPrice) FROM dbo.Orders o JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID WHERE o.Status='Paid')<>57200000
    THROW 50110,N'Paid revenue phải đúng 57,200,000 VND.',1;
IF (SELECT SUM(Quantity*UnitPrice) FROM dbo.OrderItems)<>73600000
    THROW 50111,N'Tổng mọi trạng thái phải đúng 73,600,000 VND.',1;
IF (SELECT SUM(oi.Quantity) FROM dbo.Orders o JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID WHERE o.Status='Paid')<>20
    THROW 50112,N'Paid units phải đúng 20.',1;
IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE is_disabled=1 OR is_not_trusted=1)
   OR EXISTS(SELECT 1 FROM sys.check_constraints WHERE is_disabled=1 OR is_not_trusted=1)
    THROW 50113,N'FK/CHECK phải được bật và trusted.',1;

DECLARE @ExpectedMonthly TABLE(SalesMonth date PRIMARY KEY,Revenue decimal(18,2));
INSERT @ExpectedMonthly VALUES('2025-01-01',25300000),('2025-02-01',1600000),('2025-03-01',15000000),('2025-04-01',15300000);
DECLARE @ActualMonthly TABLE(SalesMonth date PRIMARY KEY,Revenue decimal(18,2));
INSERT @ActualMonthly
SELECT DATEFROMPARTS(YEAR(o.OrderDate),MONTH(o.OrderDate),1),SUM(oi.Quantity*oi.UnitPrice)
FROM dbo.Orders o JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID WHERE o.Status='Paid'
GROUP BY DATEFROMPARTS(YEAR(o.OrderDate),MONTH(o.OrderDate),1);
IF EXISTS(SELECT * FROM @ActualMonthly EXCEPT SELECT * FROM @ExpectedMonthly)
   OR EXISTS(SELECT * FROM @ExpectedMonthly EXCEPT SELECT * FROM @ActualMonthly)
    THROW 50114,N'Báo cáo tháng khác số liệu chuẩn.',1;

DECLARE @ExpectedProduct TABLE(ProductID int PRIMARY KEY,Revenue decimal(18,2));
INSERT @ExpectedProduct VALUES(1,30000000),(2,1800000),(3,1400000),(4,12000000),(5,12000000);
DECLARE @ActualProduct TABLE(ProductID int PRIMARY KEY,Revenue decimal(18,2));
INSERT @ActualProduct
SELECT oi.ProductID,SUM(oi.Quantity*oi.UnitPrice)
FROM dbo.Orders o JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID WHERE o.Status='Paid' GROUP BY oi.ProductID;
IF EXISTS(SELECT * FROM @ActualProduct EXCEPT SELECT * FROM @ExpectedProduct)
   OR EXISTS(SELECT * FROM @ExpectedProduct EXCEPT SELECT * FROM @ActualProduct)
    THROW 50115,N'Báo cáo sản phẩm khác số liệu chuẩn.',1;

-- Negative tests: mỗi lần cố ghi dữ liệu sai đều được ROLLBACK.
-- IDENTITY có thể tăng dù INSERT thất bại; khoảng trống ID không có nghĩa mất bản ghi.
SET XACT_ABORT OFF;
DECLARE @Cases TABLE(ID int IDENTITY PRIMARY KEY,TestName nvarchar(100),Command nvarchar(max),ExpectedError int);
INSERT @Cases(TestName,Command,ExpectedError) VALUES
(N'UNIQUE email',N'INSERT dbo.Customers(FullName,Email) VALUES(N''Trùng'',''an@example.test'');',2627),
(N'FK customer',N'INSERT dbo.Orders(CustomerID,Status) VALUES(999999,''Pending'');',547),
(N'CHECK giá',N'INSERT dbo.Products(ProductName,Category,Price,Stock) VALUES(N''Sai'',N''Test'',-1,1);',547),
(N'CHECK tồn kho',N'UPDATE dbo.Products SET Stock=-1 WHERE ProductID=1;',547),
(N'CHECK số lượng',N'UPDATE dbo.OrderItems SET Quantity=0 WHERE OrderID=1 AND ProductID=1;',547),
(N'CHECK giá lịch sử',N'UPDATE dbo.OrderItems SET UnitPrice=-1 WHERE OrderID=1 AND ProductID=1;',547),
(N'CHECK trạng thái',N'UPDATE dbo.Orders SET Status=''Unknown'' WHERE OrderID=1;',547),
(N'PK chi tiết',N'INSERT dbo.OrderItems(OrderID,ProductID,Quantity,UnitPrice) VALUES(1,1,1,15000000);',2627),
(N'NOT NULL tên',N'INSERT dbo.Customers(FullName,Email) VALUES(NULL,''null-name@example.test'');',515);
DECLARE @ID int=1,@MaxID int=(SELECT MAX(ID) FROM @Cases),@TestName nvarchar(100),@Command nvarchar(max),@ExpectedError int,@CaughtError int;
WHILE @ID<=@MaxID
BEGIN
    SELECT @TestName=TestName,@Command=Command,@ExpectedError=ExpectedError FROM @Cases WHERE ID=@ID;
    SET @CaughtError=0;
    BEGIN TRY
        BEGIN TRANSACTION;
        EXEC sys.sp_executesql @Command;
        ROLLBACK;
    END TRY
    BEGIN CATCH
        SET @CaughtError=ERROR_NUMBER();
        IF XACT_STATE()<>0 ROLLBACK;
    END CATCH;
    IF @CaughtError<>@ExpectedError
    BEGIN
        DECLARE @Message nvarchar(2048)=CONCAT(N'Test ',@TestName,N' sai: kỳ vọng ',@ExpectedError,N', nhận ',@CaughtError);
        THROW 50116,@Message,1;
    END;
    PRINT CONCAT(N'PASS negative: ',@TestName,N' (',@CaughtError,N')');
    SET @ID+=1;
END;

-- Atomicity: thay đổi tồn kho rồi INSERT FK sai phải hoàn tác cả thay đổi trước.
DECLARE @StockBefore int=(SELECT Stock FROM dbo.Products WHERE ProductID=1);
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE dbo.Products SET Stock=Stock-1 WHERE ProductID=1;
    INSERT dbo.Orders(CustomerID,Status) VALUES(999999,'Pending');
    ROLLBACK;
    THROW 50117,N'FK không chặn trường hợp sai.',1;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    IF ERROR_NUMBER()<>547 THROW;
END CATCH;
IF (SELECT Stock FROM dbo.Products WHERE ProductID=1)<>@StockBefore
    THROW 50118,N'Atomicity thất bại: tồn kho không được phục hồi.',1;
IF @@TRANCOUNT<>0 THROW 50119,N'Validate để lại transaction mở.',1;
SET XACT_ABORT ON;
SELECT N'PASS: seed, 9 negative tests, atomicity rollback' AS ValidationResult;
GO
