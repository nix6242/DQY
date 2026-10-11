# Cẩm nang SQL Server và Power BI bằng tiếng Việt

**30 chương, bản PDF 112 trang**, từ cơ sở dữ liệu/SQL cơ bản tới truy vấn nâng cao, báo cáo Power BI, dự án portfolio và phỏng vấn. Tài liệu dành cho người mới hoặc đã quên thao tác, ưu tiên hướng **Data Analyst / BI**.

## Tải và đọc tài liệu

- [Tải Word (.docx)](https://github.com/nix6242/DQY/raw/refs/heads/docs/sql-server-guide-downloads/docs/sql-server/Cam-nang-SQL-Server-Power-BI.docx)
- [Tải PDF (.pdf)](https://github.com/nix6242/DQY/raw/refs/heads/docs/sql-server-guide-downloads/docs/sql-server/Cam-nang-SQL-Server-Power-BI.pdf)
- [Tải bộ thực hành (.zip)](https://github.com/nix6242/DQY/raw/refs/heads/docs/sql-server-guide-downloads/docs/sql-server/Bo-thuc-hanh-SQL-Server.zip)
- [Đọc ngay trên GitHub](Cam-nang-SQL-Server.md)
- [Đọc hướng dẫn bộ thực hành](practice/README-thuc-hanh.md)

Word khoảng 0,45 MB, PDF khoảng 2,33 MB. Nếu phần xem trước không mở được, dùng liên kết tải trực tiếp hoặc nút Download raw file trên GitHub. Word có thể thay đổi số trang tùy ứng dụng; PDF giữ bố cục cố định.

## Vì sao chọn SQL Server?

SQL Server làm hệ quản trị chính, SSMS là công cụ thao tác, Power BI dùng làm báo cáo. Lựa chọn này phù hợp mục tiêu phân tích dữ liệu của bài học trong hệ sinh thái Microsoft. Kiến thức quan hệ, JOIN, tổng hợp, CTE, window functions và kiểm tra dữ liệu chuyển được sang PostgreSQL/MySQL; chương 26 giải thích các khác biệt và MongoDB.

Không cần học mọi hệ quản trị cùng lúc để hoàn thành dự án đầu tiên. SQL Server Developer dùng cho học/phát triển/kiểm thử; phiên bản/edition được giải thích theo tài liệu chính thức đối chiếu ngày 11/10/2026.

## Nội dung và đường học

- Chương 1–8: cơ sở dữ liệu, chọn/cài công cụ, thao tác SSMS, kiểu dữ liệu, NULL, khóa/constraints, DDL/CRUD và SELECT.
- Chương 9–16: JOIN, GROUP BY/HAVING, hàm, truy vấn con, CTE, window functions, views/procedures và KPI.
- Chương 17–24: transaction, isolation, khóa, indexes, execution plan, quyền, backup/restore, migrations, JSON/XML/import.
- Chương 25: kết nối SQL/CSV → Power Query → mô hình sao → Date table → DAX → dashboard → kiểm tra số liệu.
- Chương 26–30: chuyển hệ, capstone bán hàng, 30 câu phỏng vấn, lộ trình 90 ngày và bảng tra cứu.

Với hướng Data Analyst, bắt đầu chương 1–8, tiếp tục 9–16 rồi 25/27. Phần quản trị chuyên sâu có thể đọc sau theo nhu cầu công việc.

## Thực hành

Giải nén ZIP vào thư mục riêng, đọc README trong ZIP. Bộ gồm tám script SQL, Docker Compose tùy chọn, ba CSV, hướng dẫn và công cụ kiểm tra dữ liệu Python tùy chọn. Không cần Python để chạy SQL trong SSMS.

Cơ sở dữ liệu `DQY_SQL_Lab` có Customers, Products, Orders, OrderItems. Dữ liệu giả, ngày cố định năm 2025, tiền VND. View `dbo.vw_FactPaidSales` có grain một sản phẩm trong một đơn Paid.

Các mốc không lọc: **57.200.000 VND**, **6 đơn Paid**, **4 khách**, **20 đơn vị bán**, **11 dòng fact**. Giá trị đơn trung bình khoảng **9.533.333,33 VND**. Chỉ dùng UnitPrice lịch sử và đơn Paid; không đếm số dòng fact thành số đơn.

SQL chính: chạy 01 → 02 → 03 → 06, làm bài 04/05 rồi chạy 07 → 06 để kiểm tra. Tệp reset 08 mặc định bị chặn; chỉ sử dụng khi chủ động muốn xóa đúng database lab. Nếu chưa cài xong SQL Server, dùng thư mục `powerbi-csv` để luyện model/DAX theo chương 25.

Bạn tự tạo file `.pbix` theo hướng dẫn; bộ tải không có PBIX đã dựng sẵn.

## Kiểm tra và giới hạn

- Tám SQL script qua Microsoft ScriptDOM 180.117.0, parser TSql160 cho SQL Server 2022; các ví dụ T-SQL trong sách cũng được kiểm cú pháp/rà soát.
- Seed/KPI tính độc lập bằng Python; CSV được đọc lại và đối chiếu. Compose được kiểm tra cấu hình.
- Word/PDF kiểm tra cấu trúc, 30 đề mục chương, mục lục có liên kết/số trang khớp và bố cục. ZIP có 17 tệp, không chứa `.env` thật hoặc binary.
- **Chưa thực thi script trên engine SQL Server:** môi trường biên soạn chặn tải binary/container qua GET. Parser không thay kiểm thử runtime, quyền, khóa, backup hoặc hiệu năng.
- **Chưa thao tác SSMS/Power BI Desktop trên máy người học.** README hướng dẫn chạy kiểm tra runtime và đối chiếu dashboard; không tuyên bố đã publish/refresh tài khoản của bạn.

Nguồn chính thức, phiên bản và phạm vi kiểm tra được ghi ở phần cuối cẩm nang. Không có mật khẩu thật hoặc dữ liệu khách hàng thật trong bộ học.
