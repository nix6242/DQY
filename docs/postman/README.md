# Cẩm nang Postman bằng tiếng Việt

24 chương, bản PDF 72 trang, dành cho người mới hoặc đã quên cách dùng Postman. Tài liệu hướng dẫn từng bước, giải thích vì sao thực hiện và cách kiểm tra kết quả; kèm lộ trình học 30 ngày.

## Tải tài liệu

- [Tải Word (.docx)](https://github.com/nix6242/DQY/raw/refs/heads/docs/postman-guide-downloads/docs/postman/Cam-nang-Postman.docx)
- [Tải PDF (.pdf)](https://github.com/nix6242/DQY/raw/refs/heads/docs/postman-guide-downloads/docs/postman/Cam-nang-Postman.pdf)
- [Tải bộ thực hành (.zip)](https://github.com/nix6242/DQY/raw/refs/heads/docs/postman-guide-downloads/docs/postman/Bo-thuc-hanh-Postman.zip)
- [Đọc nội dung trực tiếp trên GitHub](Cam-nang-Postman.md)

Các tệp có dung lượng nhỏ hơn 2 MB. Nếu phần xem trước không mở được, dùng liên kết tải ở trên hoặc nút Download raw file của GitHub. File Word có thể mở bằng Microsoft Word hoặc ứng dụng tương thích; số trang có thể khác nhẹ so với PDF.

## Nội dung

- API/HTTP, cài ứng dụng, agent, URL/Params, headers, JSON/form/upload và xác thực.
- Variables/environment, Vault, CRUD, collection, scripts, chuỗi token/ID, Runner, CSV/JSON.
- Console và xử lý lỗi, cộng tác, OpenAPI, tài liệu API và mocks.
- Newman, Postman CLI, GitHub Actions, monitors, hiệu năng, GraphQL/WebSocket/gRPC/SOAP và các giao thức khác.
- Bảo vệ bí mật, quyền truy cập, bài tổng hợp, thuật ngữ và kế hoạch học 30 ngày.

## Bắt đầu thực hành

1. Đọc phần **Bắt đầu từ đây**, sau đó chương 1–4.
2. Giải nén ZIP vào một thư mục riêng trên máy bạn.
3. Mở `README-thuc-hanh.md` trong ZIP; cài Node LTS đang được hỗ trợ, phiên bản 20 trở lên, và Postman Desktop.
4. Mở terminal tại thư mục giải nén, chạy `node demo-server.mjs`; giữ cửa sổ này mở.
5. Import hai tệp JSON vào Postman, chọn environment **Postman Local** và thử `/health`.
6. Trước Runner, mở request 08 và chọn lại `sample-upload.txt`.

API chỉ chạy trên máy bạn ở `http://127.0.0.1:4010`, dùng dữ liệu giả và RAM; dừng/khởi động lại để đặt lại bài học. Không cần `npm install` để khởi động API. Khi dùng Postman Web phải chọn Desktop Agent có thể truy cập máy đó; Cloud Agent không truy cập trực tiếp localhost của laptop.

ZIP chứa server Node không dependency, collection JSON v2.1 với 21 request, environment sạch, CSV bốn dòng, tệp upload mẫu và README. JSON v2.1 được chọn để tương thích Newman; các định dạng collection mới cần runner phù hợp.

## Kết quả kiểm tra

Đã kiểm tra ngày 11/10/2026 với Node 24.19.0, Newman 6.2.3 và Postman CLI 1.73.0:

- API: 32 kiểm tra HTTP độc lập đạt.
- Newman luồng chính: 20 request, 60 assertion đạt; chạy lại cũng đạt.
- Newman CSV: bốn dòng dữ liệu, 13 assertion đạt; có tự dọn sản phẩm tạo thành công.
- Postman CLI luồng chính: 20 request, 60 assertion đạt, không cần đăng nhập cho lượt chạy cục bộ này.
- Bản sao có assertion sai trả mã thoát 1 như kỳ vọng; bản mẫu được chia sẻ giữ các assertion đúng.
- Word/PDF: kiểm tra cấu trúc, mục lục có liên kết và số trang khớp; ZIP mở được, token/ID mẫu trống.

Tài liệu có nguồn tham khảo chính thức và ghi rõ những phần phụ thuộc phiên bản, gói hoặc quyền tài khoản. Các giao thức nâng cao không phải endpoint có sẵn trong API lab. Không có token thật hay tệp môi trường runtime trong bộ tải.
