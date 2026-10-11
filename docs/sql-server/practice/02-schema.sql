USE DQY_SQL_Lab;
GO
SET XACT_ABORT ON;
GO
IF @@TRANCOUNT<>0 THROW 50005,N'Hãy đóng transaction hiện tại trước khi tạo schema.',1;
IF OBJECT_ID(N'dbo.Customers', N'U') IS NOT NULL
    THROW 50002, N'Schema đã tồn tại. Không chạy file 02 lần hai.', 1;
BEGIN TRY
BEGIN TRANSACTION;
CREATE TABLE dbo.Customers (
    CustomerID int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Customers PRIMARY KEY,
    FullName nvarchar(100) NOT NULL,
    Email varchar(200) NOT NULL CONSTRAINT UQ_Customers_Email UNIQUE,
    City nvarchar(100) NULL,
    CreatedAt datetime2(0) NOT NULL CONSTRAINT DF_Customers_CreatedAt DEFAULT SYSUTCDATETIME()
);
CREATE TABLE dbo.Products (
    ProductID int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Products PRIMARY KEY,
    ProductName nvarchar(120) NOT NULL,
    Category nvarchar(80) NOT NULL,
    Price decimal(18,2) NOT NULL CONSTRAINT CK_Products_Price CHECK (Price >= 0),
    Stock int NOT NULL CONSTRAINT CK_Products_Stock CHECK (Stock >= 0)
);
CREATE TABLE dbo.Orders (
    OrderID int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Orders PRIMARY KEY,
    CustomerID int NOT NULL CONSTRAINT FK_Orders_Customers REFERENCES dbo.Customers(CustomerID),
    OrderDate datetime2(0) NOT NULL CONSTRAINT DF_Orders_OrderDate DEFAULT SYSUTCDATETIME(),
    Status varchar(20) NOT NULL CONSTRAINT CK_Orders_Status CHECK (Status IN ('Pending','Paid','Cancelled'))
);
CREATE TABLE dbo.OrderItems (
    OrderID int NOT NULL CONSTRAINT FK_OrderItems_Orders REFERENCES dbo.Orders(OrderID),
    ProductID int NOT NULL CONSTRAINT FK_OrderItems_Products REFERENCES dbo.Products(ProductID),
    Quantity int NOT NULL CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0),
    UnitPrice decimal(18,2) NOT NULL CONSTRAINT CK_OrderItems_UnitPrice CHECK (UnitPrice >= 0),
    CONSTRAINT PK_OrderItems PRIMARY KEY (OrderID,ProductID)
);
COMMIT;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    THROW;
END CATCH;
GO
