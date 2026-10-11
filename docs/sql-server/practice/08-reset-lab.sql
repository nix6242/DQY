-- NGUY HIỂM CÓ CHỦ Ý: chỉ dùng để xóa đúng LAB của bộ học này.
-- Mặc định chặn. Đọc README, đóng các cửa sổ kết nối LAB, backup bài làm.
USE master;
GO
DECLARE @ConfirmReset bit=0; -- Chỉ đổi thành 1 khi BẠN muốn xóa LAB.
IF @ConfirmReset<>1 THROW 50301,N'Reset bị chặn. Đọc hướng dẫn trước khi đổi ConfirmReset=1.',1;
IF DB_ID(N'DQY_SQL_Lab') IS NULL THROW 50302,N'Không có DQY_SQL_Lab để xóa.',1;
DECLARE @Purpose nvarchar(100);
EXEC sys.sp_executesql
    N'SELECT @V=CONVERT(nvarchar(100),value) FROM DQY_SQL_Lab.sys.extended_properties
      WHERE class=0 AND name=N''DQY_Lab_Purpose'';',
    N'@V nvarchar(100) OUTPUT',@V=@Purpose OUTPUT;
IF @Purpose IS NULL OR @Purpose<>N'SQL_LEARNING_LAB_ONLY'
    THROW 50303,N'Database không có dấu LAB của bộ học. Không được xóa.',1;
-- Tên cố định, không nhận input từ user. Chỉ sau khi vượt tất cả chốt ở trên.
ALTER DATABASE DQY_SQL_Lab SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE DQY_SQL_Lab;
SELECT N'LAB đã xóa. Chạy lại 01,02,03 để học lại từ đầu.' AS Result;
GO
