# Cẩm nang CMD Windows bằng tiếng Việt

**30 chương, bản PDF 75 trang**, từ mức 0 đến thao tác Windows, chẩn đoán lỗi và viết batch có thể kiểm tra. Dành cho người mới hoặc đã quên cách dùng dòng lệnh. Có bài tập, đáp án, 35 câu tự kiểm tra, ba dự án và lộ trình 90 ngày.

## Tải và đọc

- [Tải Word (.docx)](https://github.com/nix6242/DQY/raw/refs/heads/docs/cmd-guide-downloads/docs/cmd/Cam-nang-CMD-Windows.docx)
- [Tải PDF (.pdf)](https://github.com/nix6242/DQY/raw/refs/heads/docs/cmd-guide-downloads/docs/cmd/Cam-nang-CMD-Windows.pdf)
- [Tải bộ thực hành (.zip)](https://github.com/nix6242/DQY/raw/refs/heads/docs/cmd-guide-downloads/docs/cmd/Bo-thuc-hanh-CMD.zip)
- [Đọc ngay trên GitHub](Cam-nang-CMD-Windows.md)
- [Đọc README bộ thực hành](practice/README.md)

Nếu xem trước không mở được, dùng liên kết tải trực tiếp hoặc nút **Download raw file** trên GitHub. Bản Word có thể thay đổi số trang tùy ứng dụng; PDF giữ bố cục cố định.

## Bạn sẽ học gì?

- Chương 1–8: CMD/PowerShell/Terminal, mở cửa sổ, trợ giúp, đường dẫn, xem và xử lý tệp giả, tìm kiếm, biến môi trường, pipe và chuyển hướng.
- Chương 9–16: tiến trình, chẩn đoán mạng, HTTP/curl, quan sát Windows, Robocopy, mã hóa tiếng Việt, công cụ Git/Node/SQL và xử lý lỗi.
- Chương 17–24: file `.cmd`/`.bat`, tham số, điều kiện, mã kết thúc, vòng lặp, delayed expansion, subroutine, log và Task Scheduler.
- Chương 25–30: báo cáo thư mục, backup/phục hồi demo, workflow dữ liệu, đọc script, lộ trình học và bảng tra cứu.

Các phần giải thích việc cần làm, lý do, cách kiểm tra kết quả và lỗi thường gặp. Mục tiêu thành thạo được đánh giá bằng khả năng tự làm và bàn giao dự án; việc đọc hết không tự bảo đảm trình độ hay công việc.

## Bắt đầu

Lộ trình chính dùng Windows 11 còn được hỗ trợ. CMD có sẵn; các bài chính không cần admin, Internet hay cài thêm phần mềm. Kit gọi Windows PowerShell có sẵn để kiểm tra đường dẫn, marker và hash; giải thích riêng cú pháp của hai công cụ.

Giải nén ZIP, đọc README rồi mở CMD thường. Tại thư mục chứa các script, chạy `00-create-lab.cmd`, tiếp đến `09-verify-lab.cmd`. Học chương 1–5 trước khi chạy toàn bộ. Lab cố định tại `%USERPROFILE%\CMD-Lab`, dùng năm tệp dữ liệu giả.

`03-backup-demo.cmd` mặc định xem trước bằng `/L`; `/apply` mới copy vào `backups\demo`. Script này có thể cập nhật tệp trùng tên trong đích demo; không dùng thư mục dữ liệu thật. `08-cleanup-demo.cmd /confirm` chỉ xóa báo cáo do kit tạo khi marker/hash đúng; giữ dữ liệu nguồn, backup và bài học riêng. Marker/hash giúp tránh thao tác nhầm, không bảo vệ trước người cố tình sửa đồng thời tệp.

## Kiểm tra

Word/PDF được kiểm tra cấu trúc, đủ 30 chương, mục lục 32 liên kết và số trang khớp; kiểm tra bố cục không thấy chữ tràn khỏi trang. ZIP có 19 tệp, gồm 11 script bài học/helper, một script fixture, dữ liệu mẫu, manifest, README và `.gitattributes` giữ nguyên byte xuống dòng.

Đối chiếu cú pháp với các tài liệu Microsoft chính thức, rà soát thủ công quy tắc mở rộng biến/mã lỗi và kiểm tra tĩnh định dạng/fixture hash. Hồ sơ kiểm tra runtime và giới hạn Windows được ghi trong [hồ sơ kiểm chứng](validation.md).

Giao diện Windows, Task Scheduler, quyền quản trị và công cụ cài riêng cần thử theo máy thực tế. Các ví dụ về mạng cần kết nối hoặc server đang chạy đúng như phần hướng dẫn; ping thành công không chứng minh API hoạt động.
