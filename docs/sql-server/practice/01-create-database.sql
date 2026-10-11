-- Chỉ tạo LAB mới. Script dừng nếu tên đã tồn tại, không xóa dữ liệu.
USE master;
GO
IF @@TRANCOUNT<>0 THROW 50000,N'Hãy đóng transaction hiện tại trước khi tạo LAB.',1;
IF DB_ID(N'DQY_SQL_Lab') IS NOT NULL
    THROW 50001, N'DQY_SQL_Lab đã tồn tại. Không tạo lại; xem README và script reset có chốt an toàn.', 1;
-- CREATE DATABASE được chạy trong batch riêng bằng EXEC, cùng nhánh an toàn phía trên.
EXEC(N'CREATE DATABASE DQY_SQL_Lab;');
EXEC(N'USE DQY_SQL_Lab;
       EXEC sys.sp_addextendedproperty @name=N''DQY_Lab_Purpose'',
            @value=N''SQL_LEARNING_LAB_ONLY'';');
SELECT N'DQY_SQL_Lab đã tạo. Tiếp tục file 02-schema.sql.' AS Result;
GO
