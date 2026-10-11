# Dữ liệu mẫu cho Power BI khi chưa cài xong SQL Server

Ba CSV được dựng trực tiếp từ các giá trị INSERT cố định trong `03-seed.sql` bằng `tools/verify_seed.py`. Đây là **dữ liệu xuất mẫu**, không phải kết quả đã export từ engine SQL Server. Bộ học chính vẫn dùng SQL Server và views trong `07-advanced.sql`.

Trong Power BI Desktop chọn Get data → Text/CSV, import lần lượt `Customers.csv`, `Products.csv`, `FactPaidSales.csv`. Encoding UTF-8 (65001), delimiter dấu phẩy. Có UTF-8 BOM để phần mềm Windows nhận tiếng Việt. Kiểm tra headers trước Load.

- Customers: 6 dòng; CustomerID kiểu Whole number, CreatedAt Date/Time; City trống của Customer5 là thiếu dữ liệu (NULL trong SQL).
- Products: 6 dòng; ProductID/Stock Whole number, Price Fixed decimal number.
- FactPaidSales: 11 dòng; OrderID/ProductID/CustomerID/Quantity Whole number, OrderDate Date, UnitPrice/LineAmount Fixed decimal number.
- Số tiền dùng dấu chấm thập phân. Nếu locale máy hiểu khác, Transform data → Change type → Using locale → Decimal number/Fixed decimal, English (United States), rồi xác nhận `300000.00` là 300,000 VND.
- Quan hệ CustomerID/ProductID 1→many, hướng single, và Date dimension như cẩm nang. Fact grain = cặp (OrderID,ProductID), chỉ đơn Paid.
- KPI không filter: Revenue 57,200,000; Paid Orders 6; Active Customers 4; Units 20; AOV ≈ 9,533,333.33. Monthly Jan 25.3 triệu / Feb 1.6 triệu / Mar 15 triệu / Apr 15.3 triệu.

Sau khi SQL Server sẵn sàng, chạy các file 01–03–06–07 rồi thử Get data → SQL Server. Thay nguồn CSV không tự thiết lập SQL refresh/gateway. Không cần cài Python để sử dụng CSV; tool Python chỉ giúp người muốn kiểm tra cách tạo dataset.
