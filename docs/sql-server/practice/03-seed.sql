USE DQY_SQL_Lab;
GO
SET XACT_ABORT ON;
IF @@TRANCOUNT<>0 THROW 50006,N'Hãy đóng transaction hiện tại trước khi seed.',1;
IF EXISTS (SELECT 1 FROM dbo.Customers) OR EXISTS (SELECT 1 FROM dbo.Products)
   OR EXISTS (SELECT 1 FROM dbo.Orders) OR EXISTS (SELECT 1 FROM dbo.OrderItems)
    THROW 50003, N'Chỉ seed vào cả 4 bảng trống sau file 02; không trộn dữ liệu cũ.', 1;
IF EXISTS (SELECT 1 FROM sys.identity_columns
           WHERE object_id IN (OBJECT_ID(N'dbo.Customers'),OBJECT_ID(N'dbo.Products'),OBJECT_ID(N'dbo.Orders'))
             AND last_value IS NOT NULL)
    THROW 50004, N'Identity đã thay đổi. Reset LAB có chốt an toàn rồi tạo lại.', 1;
BEGIN TRY
BEGIN TRANSACTION;
INSERT dbo.Customers (FullName,Email,City,CreatedAt) VALUES
(N'Nguyễn Minh An','an@example.test',N'Hà Nội','2025-01-01T08:00:00'),
(N'Trần Thu Hà','ha@example.test',N'TP. Hồ Chí Minh','2025-01-02T08:00:00'),
(N'Lê Quốc Bình','binh@example.test',N'Đà Nẵng','2025-02-01T08:00:00'),
(N'Phạm Bảo Ngọc','ngoc@example.test',N'Hà Nội','2025-03-01T08:00:00'),
(N'Võ Gia Huy','huy@example.test',NULL,'2025-03-05T08:00:00'),
(N'Đỗ Mai Linh','linh@example.test',N'Cần Thơ','2025-04-01T08:00:00');
INSERT dbo.Products (ProductName,Category,Price,Stock) VALUES
(N'Laptop',N'Điện tử',15000000,10),
(N'Mouse',N'Phụ kiện',300000,50),
(N'Keyboard',N'Phụ kiện',700000,30),
(N'Monitor',N'Điện tử',3000000,20),
(N'Desk',N'Nội thất',2000000,8),
(N'Webcam',N'Phụ kiện',900000,15);
INSERT dbo.Orders (CustomerID,OrderDate,Status) VALUES
(1,'2025-01-05T09:00:00','Paid'),
(2,'2025-01-10T10:00:00','Paid'),
(1,'2025-02-03T09:30:00','Paid'),
(3,'2025-02-15T14:00:00','Pending'),
(4,'2025-03-08T11:00:00','Paid'),
(2,'2025-03-20T15:00:00','Cancelled'),
(3,'2025-03-25T16:00:00','Paid'),
(4,'2025-04-02T09:00:00','Paid');
INSERT dbo.OrderItems (OrderID,ProductID,Quantity,UnitPrice) VALUES
(1,1,1,15000000),(1,2,2,300000),
(2,4,3,3000000),(2,3,1,700000),
(3,2,3,300000),(3,3,1,700000),
(4,1,1,15000000),
(5,4,1,3000000),(5,5,3,2000000),
(6,3,2,700000),
(7,5,3,2000000),
(8,1,1,15000000),(8,2,1,300000);
COMMIT;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    THROW;
END CATCH;
SELECT N'Seed thành công: 6 customers, 6 products, 8 orders, 13 items' AS Result;
GO
