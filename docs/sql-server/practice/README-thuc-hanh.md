# Bộ thực hành SQL Server — DQY_SQL_Lab

Đây là dữ liệu bán hàng giả để học SQL và làm báo cáo Power BI. Email đuôi `.test`, không có thông tin khách thật. Dữ liệu tiền tính bằng VND, `decimal(18,2)`; thời gian seed cố định năm 2025. LAB không phải phần mềm bán hàng hoàn chỉnh.

## 1. Chọn cách chạy

**Người mới dùng Windows:** cài SQL Server Developer và SSMS. SQL Server là engine lưu/truy vấn dữ liệu; SSMS là cửa sổ điều khiển engine. Cài riêng SSMS không tự tạo SQL Server.

- SQL Server downloads: <https://www.microsoft.com/sql-server/sql-server-downloads>.
- SSMS: <https://learn.microsoft.com/ssms/install/install>.
- SQL Server 2022 Developer hoặc SQL Server 2025 Developer đều dùng được các script này. Developer dành cho phát triển/kiểm thử, không có quyền dùng làm máy chủ production.
- Với SQL Server 2025, chọn edition Developer phù hợp installer; không giả định tên nút giống installer 2022. Express có giới hạn khác, không phải lựa chọn chính của bộ học.

**macOS/Linux hoặc người quen Docker:** xem mục 7. SQL Server container là image Linux x86-64; máy Apple Silicon không được đảm bảo chạy trực tiếp. Có thể kết nối tới một máy Windows/Linux x86-64 được phép thay vì ép emulator. Power BI Desktop là ứng dụng Windows; macOS có thể học SQL và dùng báo cáo mẫu/Windows VM phù hợp.

## 2. Cài engine trên Windows, từng bước

1. Tải installer Developer từ trang Microsoft. Đọc edition/license trước khi cài.
2. Người mới có thể chọn Basic nếu installer cung cấp. Giữ tên instance/đường dẫn installer hiển thị; chụp hoặc ghi lại tên instance. Nếu Custom, chọn Database Engine Services và thêm tài khoản Windows hiện tại làm SQL Server administrator.
3. Chọn Windows Authentication để bắt đầu; không cần bật tài khoản `sa` cho lộ trình Windows này.
4. Khi hoàn tất, ghi **Server name/Instance name**. Default instance thường kết nối bằng `localhost`; named instance dùng `localhost\TEN_INSTANCE`. Chỉ dùng `localhost\SQLEXPRESS` nếu bạn thực sự đã cài instance tên SQLEXPRESS.
5. Cài SSMS, mở ứng dụng, chọn kết nối SQL Server/Database Engine. Server name đúng mục 4, Authentication = Windows Authentication, rồi Connect.
6. SQL Server Configuration Manager hoặc Windows Services cho biết dịch vụ instance đã Running chưa. Chưa Running thì SSMS không có engine để kết nối.
7. Máy học local có thể dùng chứng chỉ tự ký của instance. Nếu SSMS báo chain chứng chỉ không được tin cậy, chỉ đánh dấu Trust server certificate cho **kết nối LAB local mà bạn kiểm soát**. Với server doanh nghiệp, dùng CA/hostname do quản trị cung cấp; không tắt xác minh TLS để xử lý lỗi chung.
8. Chọn New Query, chạy `SELECT @@VERSION AS EngineVersion;`. Có dòng kết quả nghĩa là đã kết nối được engine. Đây khác với việc chỉ mở thành công SSMS.

## 3. Giải nén và chạy đúng thứ tự

Giải nén ZIP ra một thư mục dễ nhớ, ví dụ `Documents\DQY-SQL-Lab`. Lưu file bài làm riêng cạnh kit; không cần sửa các đáp án trước khi học.

| File | Cách dùng | Thay đổi dữ liệu |
|---|---|---|
| `01-create-database.sql` | Chỉ chạy lần đầu, tạo database có dấu LAB | Tạo database; không xóa database cũ |
| `02-schema.sql` | Chạy sau 01, tạo 4 bảng/constraints | Tạo bảng |
| `03-seed.sql` | Chạy sau 02, nạp dữ liệu giả | Thêm 6/6/8/13 dòng |
| `04-exercises.sql` | Đề 20 bài; thêm SELECT vào bản sao của bạn | Hiện tại chỉ đọc |
| `05-solutions.sql` | Đáp án E01–E18; E19/E20 xem hướng dẫn/file07 | Chỉ đọc; update demo được rollback |
| `06-validate.sql` | Xác nhận số liệu và 9 trường hợp ghi sai bị chặn | Ghi thử rồi rollback; IDENTITY có thể tăng |
| `07-advanced.sql` | View/proc/index, KPI, giao dịch thành công/thất bại | Tạo objects; demo đơn/stock đều rollback |
| `08-reset-lab.sql` | Chỉ khi chủ động muốn học lại từ đầu | Xóa toàn bộ LAB, mặc định bị chặn |

Mỗi file: trong SSMS chọn File → Open → File, chọn file `.sql`, kiểm tra đúng kết nối, bỏ lựa chọn vùng text nếu muốn chạy toàn file, nhấn F5 hoặc Execute. Đọc cả **Results** và **Messages**. Có dòng lỗi đỏ thì dừng, xử lý trước khi mở file tiếp theo.

Chạy 01 → 02 → 03 → 06. Khi file06 trả `PASS: seed, 9 negative tests, atomicity rollback`, bắt đầu bài04. Sau khi làm bài có thể đọc05 rồi chạy07. Cuối cùng chạy06 thêm lần nữa để xác nhận các demo đã phục hồi dữ liệu.

Mỗi file tự chọn database bằng `USE`; file01 và08 chọn `master` vì thao tác trên database. `GO` là dấu tách batch do SSMS/sqlcmd xử lý, **không phải lệnh T-SQL của engine**. Không gửi cả chuỗi có `GO` qua API database driver như một statement.

Các file tạo schema/seed có chốt chặn chạy lại. Đừng xóa chốt hoặc tiếp tục sau lỗi. Muốn học lại toàn bộ, dùng quy trình reset ở mục6.

## 4. Kiểm tra số liệu để biết đang làm đúng

Sau seed, 4 bảng: Customers6, Products6, Orders8, OrderItems13. Orders có Paid6, Pending1, Cancelled1. Customers5/6 chưa có đơn; Product6 Webcam chưa từng được đặt. `City` của Customer5 là NULL.

- Revenue chỉ lấy **Paid** và `Quantity × OrderItems.UnitPrice` (giá lịch sử). Kết quả 57,200,000.00 VND.
- Tổng mọi trạng thái 73,600,000.00 VND. Không gọi số này là Paid revenue.
- Paid revenue từng tháng: 01/2025 = 25,300,000; 02 = 1,600,000; 03 = 15,000,000; 04 = 15,300,000.
- Paid customer revenue: IDs1/2/3/4 = 17,200,000 / 9,700,000 / 6,000,000 / 24,300,000; IDs5/6 = 0.
- Paid product revenue: Laptop30,000,000; Monitor12,000,000; Desk12,000,000; Mouse1,800,000; Keyboard1,400,000; Webcam0. Monitor/Desk cùng hạng2 với DENSE_RANK.
- Các giao dịch minh họa mới dùng `SYSUTCDATETIME()`, khác với ngày seed cố định. IDENTITY không hứa liền nhau: test INSERT lỗi/ROLLBACK có thể tiêu hao số. Các seed ban đầu vẫn IDs1–8; không hard-code ID của đơn tạo mới.

Tồn kho seed là ảnh chụp hiện tại giả định, **không được suy từ số bán trong lịch sử**. `usp_CreateOrder` trong07 bắt đầu kiểm soát stock cho đơn mới; học rollback để giữ ảnh chụp seed.

## 5. Kết nối Power BI Desktop sau file07

1. Mở Power BI Desktop trên Windows, Get data → SQL Server.
2. Server giống SSMS (`localhost` hoặc instance đúng); Docker dùng `localhost,14330`. Database `DQY_SQL_Lab`.
3. Chọn Import cho bài học đầu; Windows Authentication cho engine Windows, Database credentials cho Docker. Không đăng/screenshot mật khẩu.
4. Chọn `dbo.Customers`, `dbo.Products`, `dbo.vw_FactPaidSales`; đổi tên trong model lần lượt DimCustomer, DimProduct, FactPaidSales nếu muốn.
5. Fact có đúng 7 cột: OrderID, ProductID, CustomerID, OrderDate (date), Quantity, UnitPrice, LineAmount. Grain một dòng = một cặp (OrderID,ProductID) của đơn Paid. Không join fact lại với cả Orders rồi kéo thêm tiền trùng dòng.
6. Tạo Date table liên tục năm2025, đánh dấu Date table, quan hệ Date[Date]1→many FactPaidSales[OrderDate]. CustomerID và ProductID cũng 1→many, hướng lọc single từ dimension sang fact.
7. Kiểm tra: Fact11rows, Revenue57.2m, Paid Orders6, Active Customers4, Units20, Average Order Value = 57.2m/6 ≈ 9,533,333.33 VND. AOV là doanh thu trên đơn, không chia cho11factrows.
8. So sánh visual tháng với mục4 trước khi trang trí dashboard. Thay đổi filter thì card thay đổi theo ngữ cảnh; số chuẩn ở đây là khi không có filter.

SQL chấp nhận login không có nghĩa Power BI Service sau publish có thể truy cập localhost của máy bạn. Nếu muốn refresh Service với SQL Server local, cần gateway và cấu hình credentials/quyền đúng; học bước này sau khi dashboard Desktop đã chạy.

## 6. Học lại từ đầu, có chốt bảo vệ

1. Lưu bài làm/ảnh báo cáo. Đây là **xóa database**, không phải Undo một query.
2. Chỉ thực hiện trên engine học tập của bạn. Đóng cửa sổ Query/Power BI đang giữ kết nối vào LAB để tránh mất session.
3. Mở08. Kiểm tra tên cứng `DQY_SQL_Lab`, dấu extended property `SQL_LEARNING_LAB_ONLY`. File từ chối database thiếu dấu LAB.
4. Mặc định `@ConfirmReset bit=0` nên chạy sẽ bị chặn. Chỉ khi đã chủ động muốn xóa, đổi riêng dòng này thành1 rồi chạy.
5. File dùng SINGLE_USER WITH ROLLBACK IMMEDIATE, có thể ngắt session trên **LAB này**, rồi DROP LAB. Không thay tên bằng database công ty.
6. Chạy lại01 → 02 → 03 → 06. File01 luôn từ chối database cùng tên đã tồn tại, không tự overwrite.

## 7. Docker tùy chọn cho người đã quen terminal

Không cần Docker khi engine Windows đã hoạt động. Cần Docker Engine/Desktop hỗ trợ Linux x86-64, khoảng 4 GB RAM dành cho container, quyền tải image Microsoft và chấp nhận EULA phù hợp.

`compose.yaml` tham chiếu SQL Server 2022 theo **digest manifest chính thức kiểm tra ngày 11/10/2026**. Digest giúp không âm thầm đổi build khi tag `2022-latest` cập nhật. Tải image cần mạng tới registry/layer; đọc được manifest chưa chắc tải được layer.

1. Copy `.env.example` thành `.env` trong thư mục kit.
2. Mở `.env`, đặt `MSSQL_SA_PASSWORD` riêng ít nhất 12 ký tự với hoa/thường/số/ký hiệu. Đây là mật khẩu LAB, không dùng password thật. Ký tự `$` cần quy tắc quote/interpolation của Compose; người mới chọn mật khẩu dài không có `$` để tránh nhầm parser. Không upload `.env` lên GitHub.
3. Trong terminal đúng thư mục, chạy:

```text
docker compose up -d
docker compose logs sqlserver
```

4. Chờ thông báo engine sẵn sàng nhận kết nối. Container “Up” chưa bảo đảm engine khởi động xong.
5. SSMS: server `localhost,14330`, SQL Server Authentication, login `sa`, password ở `.env`. Đây chỉ là LAB; ứng dụng thật không nên dùng `sa`. Kết nối loopback có thể cần Trust server certificate vì chứng chỉ tự ký của container.
6. Chạy các file theo mục 3. Trên Linux/macOS dùng client hỗ trợ `GO` như sqlcmd hoặc SQL Server extension cho VS Code. SSMS là lộ trình Windows, không có SSMS native cho macOS.
7. Kết thúc: `docker compose down` dừng/xóa container nhưng volume vẫn giữ database. Chỉ thêm `-v` khi bạn thực sự muốn xóa cả volume LAB.
8. Đổi password trong `.env` sau khi volume đã có database không tự đổi password `sa` đang lưu. Học ALTER LOGIN/password rotation phù hợp, hoặc reset volume LAB có chủ ý.

Compose chỉ publish `127.0.0.1:14330`; máy khác không kết nối được cổng này qua mạng. Giữ thiết lập loopback cho bài học local.

## 8. Lỗi thường gặp

- **Invalid object name dbo.Customers:** chưa chạy 02, đang sai database, hoặc 02 bị lỗi. Kiểm tra `SELECT DB_NAME();`; mở lại file đúng thứ tự.
- **Database exists/schema exists:** chốt chặn đang làm đúng. Không seed thêm. Đọc mục 6 nếu muốn reset.
- **Login/instance not found:** kiểm tra instance, service Running, authentication. Tên default instance khác SQLEXPRESS.
- **57.2 triệu thành 73.6 triệu:** thiếu Paid filter; kiểm tra từng trạng thái.
- **Doanh thu bị phóng đại:** join sai grain hoặc cộng Price hiện tại; xem E05/E09/E11.
- **Không tìm thấy City NULL:** dùng `IS NULL`; `= NULL` không đúng.
- **Negative tests:** file 06 bắt và xác minh error number. PASS nghĩa là constraints chặn đúng, không cần xóa constraint. Nếu THROW 501xx thì dữ liệu/schema lệch; đọc Messages.
- **Query bị treo/transaction mở:** kiểm tra `SELECT @@TRANCOUNT, XACT_STATE();`, rollback đúng transaction demo. Transaction production cần quy trình riêng.
- **Docker pull 403:** registry/layer host có thể bị mạng chặn. Dùng cách cài Windows hoặc đề nghị quản trị cho phép đúng domain; không tắt TLS/proxy.

## 9. Học Power BI khi chưa cài xong SQL Server

Thư mục `powerbi-csv` có `Customers.csv`, `Products.csv`, `FactPaidSales.csv` và hướng dẫn import. Đây là dữ liệu xuất mẫu, dựng trực tiếp từ giá trị INSERT của `03-seed.sql`, **không phải export đã chạy trên engine SQL Server**. Bạn có thể học Get data → Text/CSV trong Power BI Desktop ngay, rồi dùng Get data → SQL Server khi LAB sẵn sàng.

CSV có UTF-8 BOM, dấu phẩy ngăn cột, ngày ISO, dấu chấm thập phân. Counts 6/6/11; KPI Revenue 57.2 triệu, Orders 6, Active Customers 4, Units 20. Đọc README trong thư mục CSV để đặt kiểu dữ liệu/locale và quan hệ đúng.

## 10. Phạm vi kiểm tra bộ kit

Cả 8 file SQL đã qua parser chính thức **Microsoft.SqlServer.TransactSql.ScriptDom 180.117.0, TSql160Parser (cú pháp SQL Server 2022)**. Dữ liệu seed/KPI được tính độc lập bằng Python từ INSERT literals, và CSV được đọc lại để kiểm tra counts/sums. Các kiểm tra này không thay cho engine execution/binding/permissions/concurrency.

**Môi trường biên soạn bị proxy chặn GET binary SQL Server (403), nên chưa chạy script trên engine SQL Server thực.** Chạy 01 → 02 → 03 → 06 → 07 → 06 trên SQL Server của bạn là bước xác minh thực tế. Parser/CSV không được coi là kết quả đã kiểm thử database runtime.

Tests trong 06/07 được thiết kế để engine xác minh constraints/rollback khi bạn chạy. Scripts không chứa đăng nhập thật, không tự xóa database đã tồn tại; reset 08 bị chặn mặc định. Không cần Python để dùng SQL/CSV; `tools/verify_seed.py` chỉ dành cho người muốn xem cách kiểm tra/tạo CSV.
