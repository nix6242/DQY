USE DQY_SQL_Lab;
GO
-- E01
SELECT ProductID,ProductName,Price FROM dbo.Products ORDER BY Price,ProductID;
-- E02
SELECT CustomerID,FullName,City FROM dbo.Customers WHERE City IS NULL;
-- E03
SELECT TOP (3) ProductID,ProductName,Price FROM dbo.Products ORDER BY Price DESC,ProductID;
-- E04: nửa khoảng mở, không bỏ ngày cuối khi cột có giờ.
SELECT OrderID,OrderDate,Status FROM dbo.Orders
WHERE OrderDate >= '2025-01-01' AND OrderDate < '2025-02-01' ORDER BY OrderDate,OrderID;
-- E05
SELECT o.OrderID,c.FullName,p.ProductName,oi.Quantity,oi.UnitPrice,
       oi.Quantity*oi.UnitPrice AS LineTotal
FROM dbo.Orders o JOIN dbo.Customers c ON c.CustomerID=o.CustomerID
JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID
JOIN dbo.Products p ON p.ProductID=oi.ProductID
ORDER BY o.OrderID,p.ProductID;
-- E06
SELECT c.CustomerID,c.FullName FROM dbo.Customers c
WHERE NOT EXISTS (SELECT 1 FROM dbo.Orders o WHERE o.CustomerID=c.CustomerID)
ORDER BY c.CustomerID;
-- E07
SELECT p.ProductID,p.ProductName FROM dbo.Products p
WHERE NOT EXISTS (SELECT 1 FROM dbo.OrderItems oi WHERE oi.ProductID=p.ProductID);
-- E08
SELECT o.OrderID,o.Status,SUM(oi.Quantity*oi.UnitPrice) AS OrderTotal
FROM dbo.Orders o JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID
GROUP BY o.OrderID,o.Status ORDER BY o.OrderID;
-- E09
SELECT SUM(oi.Quantity*oi.UnitPrice) AS PaidRevenue
FROM dbo.Orders o JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID WHERE o.Status='Paid';
-- E10
SELECT DATEFROMPARTS(YEAR(o.OrderDate),MONTH(o.OrderDate),1) AS SalesMonth,
       SUM(oi.Quantity*oi.UnitPrice) AS Revenue
FROM dbo.Orders o JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID WHERE o.Status='Paid'
GROUP BY DATEFROMPARTS(YEAR(o.OrderDate),MONTH(o.OrderDate),1) ORDER BY SalesMonth;
-- E11: lọc Paid trong ON giữ được khách chưa có đơn Paid.
SELECT c.CustomerID,c.FullName,COALESCE(SUM(oi.Quantity*oi.UnitPrice),0) AS PaidRevenue
FROM dbo.Customers c LEFT JOIN dbo.Orders o ON o.CustomerID=c.CustomerID AND o.Status='Paid'
LEFT JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID
GROUP BY c.CustomerID,c.FullName ORDER BY c.CustomerID;
-- E12: gom đúng grain sản phẩm trước khi xếp hạng; Paid filter trước OUTER JOIN.
WITH PaidByProduct AS (
    SELECT oi.ProductID,SUM(oi.Quantity*oi.UnitPrice) AS Revenue
    FROM dbo.OrderItems oi JOIN dbo.Orders o ON o.OrderID=oi.OrderID
    WHERE o.Status='Paid' GROUP BY oi.ProductID
), ProductRevenue AS (
    SELECT p.ProductID,p.ProductName,COALESCE(b.Revenue,0) AS Revenue
    FROM dbo.Products p LEFT JOIN PaidByProduct b ON b.ProductID=p.ProductID
)
SELECT ProductID,ProductName,Revenue,DENSE_RANK() OVER(ORDER BY Revenue DESC) AS RevenueRank
FROM ProductRevenue ORDER BY Revenue DESC,ProductID;
-- E13
WITH Monthly AS (
    SELECT DATEFROMPARTS(YEAR(o.OrderDate),MONTH(o.OrderDate),1) AS SalesMonth,
           SUM(oi.Quantity*oi.UnitPrice) AS Revenue
    FROM dbo.Orders o JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID WHERE o.Status='Paid'
    GROUP BY DATEFROMPARTS(YEAR(o.OrderDate),MONTH(o.OrderDate),1)
)
SELECT SalesMonth,Revenue,SUM(Revenue) OVER(ORDER BY SalesMonth ROWS UNBOUNDED PRECEDING) AS RunningRevenue
FROM Monthly ORDER BY SalesMonth;
-- E14
WITH Latest AS (
    SELECT OrderID,CustomerID,OrderDate,Status,
           ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate DESC,OrderID DESC) AS rn
    FROM dbo.Orders
)
SELECT OrderID,CustomerID,OrderDate,Status FROM Latest WHERE rn=1 ORDER BY CustomerID;
-- E15
SELECT ProductID,ProductName,Price,
       CASE WHEN Price>=3000000 THEN N'Cao' WHEN Price>=1000000 THEN N'Trung bình' ELSE N'Thấp' END AS PriceGroup
FROM dbo.Products ORDER BY ProductID;
-- E16
SELECT COUNT(*) AS Customers,COUNT(City) AS KnownCities FROM dbo.Customers;
-- E17
SELECT COUNT(o.OrderID) AS CountAfterJoin,COUNT(DISTINCT o.OrderID) AS ActualOrders
FROM dbo.Orders o JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID;
GO
-- E18: mọi thay đổi được hoàn tác trong cùng một batch.
IF @@TRANCOUNT<>0 THROW 50501,N'Hãy đóng transaction cũ trước demo E18.',1;
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE dbo.Products SET Price=Price+10000 WHERE ProductID=2;
    SELECT ProductID,Price AS TemporaryPrice FROM dbo.Products WHERE ProductID=2;
    ROLLBACK;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    THROW;
END CATCH;
SELECT ProductID,Price AS RestoredPrice FROM dbo.Products WHERE ProductID=2;
GO
-- E19/E20: xem README và file07. Không suy luận hiệu năng từ 8 đơn.
