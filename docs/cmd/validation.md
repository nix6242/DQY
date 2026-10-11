# Kiểm chứng cẩm nang và bộ thực hành CMD

Ngày hoàn tất: **11/10/2026**. Hướng dẫn chính dùng Windows 11 còn được hỗ trợ; môi trường biên soạn tài liệu là Linux.

## Kiểm thử Windows thực tế

Bộ kit vượt qua [GitHub Actions run 38132486347](https://github.com/nix6242/DQY/actions/runs/38132486347), trạng thái **Success**, trên runner `windows-2025`, dùng CMD và Windows PowerShell thực tế. Commit mã được kiểm thử: `d435723`.

Các trường hợp được harness kiểm tra:

- Từ chối thư mục có sẵn chưa có marker và giữ tệp sentinel.
- Khởi tạo, chạy lại, giữ dữ liệu nguồn đã sửa; xác minh năm fixture bằng SHA-256.
- Chạy bộ tổng hợp, nhận đúng kết quả và xác nhận mặc định backup chỉ xem trước.
- Áp dụng backup, đối chiếu hash từng tệp và giữ tệp chỉ có ở đích.
- Tham số hợp lệ/không hợp lệ, mã lỗi chủ ý 7 và nhánh thực thi.
- Báo cáo đúng nội dung/hash; tạo lại; từ chối báo cáo đã sửa hoặc chỉ đọc và manifest bất nhất/chỉ đọc.
- Cleanup cần `/confirm`, chỉ xóa báo cáo chưa sửa cùng manifest, giữ nguồn, backup và marker.
- Thư mục bộ kit có khoảng trắng và `!`; backup tệp có dấu `!`.
- Từ chối junction, giữ nguyên tệp ở đích ngoài lab; tháo junction thử nghiệm không xóa đệ quy.

[Harness](validation/verify-kit.ps1) chỉ cho phép chạy trong GitHub Windows runner mới, từ chối chạm vào lab có sẵn. Đây là mã kiểm thử dành cho CI; người học sử dụng `09-verify-lab.cmd` theo README.

## Tài liệu và tệp tải

DOCX mở được như một ZIP hợp lệ, XML hợp lệ, đủ chương 1–30. PDF có 75 trang, 32 mục lục liên kết và số trang khớp đề mục. Bố cục được kiểm tra toàn bộ và xem mẫu bìa, mục lục, bảng, code và sơ đồ; không thấy chữ nằm ngoài vùng trang.

Bộ ZIP có 19 tệp. Toàn bộ 12 tệp CMD, tính cả fixture `hello.cmd`, dùng ASCII/CRLF không BOM; các dòng lệnh dưới giới hạn 8.191 ký tự. Manifest SHA-256 khớp byte năm fixture. `.gitattributes` giữ nguyên byte các script/fixture trong Git, tránh đổi xuống dòng làm sai hash. Hồ sơ cấu trúc và hash nằm trong [checks](checks/).

## Phạm vi kết luận

Kiểm thử runtime áp dụng cho bộ kit và các tình huống được harness nêu, không phải mọi ví dụ trong sách. Windows Server 2025 và Windows 11 có khác biệt về giao diện/chính sách. Chưa thực hiện Task Scheduler, nâng quyền, giao diện Windows hay cài công cụ ngoài CMD trên máy người học.

Các lệnh mạng cần kết nối/server phù hợp. Marker/hash giúp tránh thao tác nhầm trong lab tin cậy; không phải cơ chế chống người cố tình thay đổi tệp đồng thời. Không có thông tin đăng nhập hay dữ liệu khách hàng thật trong kit.
