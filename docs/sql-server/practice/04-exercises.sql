USE DQY_SQL_Lab;
GO
-- Bài làm: thêm SELECT dưới mỗi TODO. File hiện tại chỉ đọc, không sửa dữ liệu.
-- E01: Liệt kê 6 sản phẩm theo Price tăng dần, dùng ProductID làm tie-breaker.
-- E02: Khách có City NULL. Dùng IS NULL, không dùng = NULL.
-- E03: 3 sản phẩm đắt nhất; trả đúng 3 dòng và kết quả ổn định.
-- E04: Đơn tháng 01/2025. Dùng >= '2025-01-01' và < '2025-02-01'.
-- E05: Chi tiết từng đơn: OrderID, FullName, ProductName, Quantity, UnitPrice, LineTotal.
-- E06: 2 khách chưa có bất kỳ đơn nào. Dùng NOT EXISTS hoặc LEFT JOIN.
-- E07: 1 sản phẩm chưa từng xuất hiện trong OrderItems.
-- E08: Tổng tiền từng đơn; giữ cả Pending/Cancelled và không cộng nhầm Price hiện tại.
-- E09: Chỉ tính Paid revenue, kỳ vọng 57,200,000.00 VND.
-- E10: Paid revenue từng tháng, kỳ vọng Jan25.3m/Feb1.6m/Mar15m/Apr15.3m.
-- E11: Paid revenue từng khách, giữ cả khách doanh thu bằng 0.
-- E12: Paid revenue sản phẩm, DENSE_RANK giảm dần; Monitor và Desk cùng hạng 2.
-- E13: Lũy kế Paid revenue theo tháng bằng SUM() OVER.
-- E14: Mới nhất từng khách bằng ROW_NUMBER; nếu trùng giờ thì OrderID lớn hơn trước.
-- E15: CASE phân nhóm sản phẩm Price>=3m là Cao, >=1m là Trung bình, còn lại là Thấp.
-- E16: COUNT(*) so với COUNT(City), giải thích 6 khác 5.
-- E17: Vì sao JOIN Customers->Orders->OrderItems khiến COUNT(OrderID) thành 13? Sửa bằng COUNT(DISTINCT).
-- E18: Trong BEGIN TRAN/ROLLBACK, tăng Price ProductID=2 thêm10,000 rồi kiểm tra phục hồi.
-- E19: Xem Estimated Execution Plan của E04/E09, ghi nhận Scan/Seek theo dữ liệu thực.
-- E20: Đọc usp_CreateOrder trong file07; thử số lượng hợp lệ bên trong transaction rồi ROLLBACK.
SELECT DB_NAME() AS CurrentDatabase,
       (SELECT COUNT(*) FROM dbo.Customers) AS CustomerCount,
       (SELECT COUNT(*) FROM dbo.Products) AS ProductCount;
GO
