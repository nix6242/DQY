# Bộ thực hành CMD Windows – bắt đầu từ số 0

Bộ này đi cùng cẩm nang CMD của DQY. Bạn học bằng dữ liệu giả trên chính máy Windows, xem kết quả rồi giải thích lệnh đã làm gì. Các bài chính không cần Internet, quyền quản trị hay phần mềm phải cài thêm. Không mở cửa sổ bằng **Run as administrator**.

Máy cần Windows có `cmd.exe`, `robocopy.exe`, `findstr.exe` và **Windows PowerShell 5.1** (`powershell.exe`). Đây là những công cụ đi kèm các bản Windows 11 thông thường. Windows Terminal chỉ là cửa sổ chứa phiên CMD/PowerShell; nó không thay cú pháp của chúng. Máy doanh nghiệp có chính sách chặn PowerShell hoặc công cụ này cần người quản trị cho phép theo chính sách của đơn vị.

Trong các file CMD, PowerShell chỉ giúp kiểm tra đường dẫn, liên kết thư mục và SHA-256. Đoạn đó được ghi rõ bằng `powershell.exe ... -Command`; đó là cú pháp PowerShell gọi từ CMD. Bộ này không đổi ExecutionPolicy, không tải mã từ mạng và không bật quyền quản trị. Không tự tắt chính sách bảo mật để chạy bài.

## 1. Tải về và mở đúng cửa sổ

1. Tải `Bo-thuc-hanh-CMD.zip`. Trong Explorer, nhấp phải ZIP → **Extract All / Giải nén tất cả**. Chọn thư mục dễ nhận biết, ví dụ `C:\Users\Lan\Downloads\CMD-Kit`. Không chạy trực tiếp trong cửa sổ xem ZIP.
2. Mở thư mục giải nén. Bên trong phải thấy `00-create-lab.cmd`, `09-verify-lab.cmd`, `_lab-guard.cmd`, `fixtures` và `expected-fixtures.json`. Nếu có một lớp thư mục nữa, đi vào lớp chứa các file này.
3. Nhấn **Win + R**, nhập `cmd /d`, nhấn Enter. `/d` tắt việc CMD tự thực hiện lệnh AutoRun cấu hình trong Registry khi khởi động; nó không thay cấu hình của máy.
4. Trong Explorer, bấm thanh địa chỉ, sao chép đường dẫn thư mục bộ thực hành. Trong CMD, nhập `cd /d "đường dẫn vừa sao chép"`. Ví dụ:

```bat
cd /d "C:\Users\Lan\Downloads\CMD-Kit"
dir /b
```

`cd /d` đổi cả ổ đĩa và thư mục. Dấu ngoặc kép bảo vệ đường dẫn có khoảng trắng. Đừng chép chữ `C:\...>` đang hiện ở đầu dòng: đó là dấu nhắc, không thuộc lệnh. Nếu cửa sổ đang hiện `PS C:\...>`, bạn đang ở PowerShell; nhập `cmd /d` trước khi làm các ví dụ CMD.

Đường dẫn bộ thực hành có khoảng trắng và dấu `!` được chủ ý hỗ trợ. Với người mới, tránh ký tự `%` trong tên thư mục chứa bộ kit: `CALL` có cơ chế mở rộng biến lần hai và có thể hiểu dấu `%` trong đường dẫn là cú pháp. Không sửa biến hệ thống `USERPROFILE` để chuyển chỗ bài thực hành.

5. Mở `_lab-guard.cmd` bằng Notepad để đọc trước. Sau đó chạy:

```bat
00-create-lab.cmd
09-verify-lab.cmd
echo %ERRORLEVEL%
```

Kết quả thành công là `[PASS] Five fixture hashes and markers match.` và dòng `0`. Các thông báo `[GUARD] OK` cho biết bước kiểm tra đường dẫn đã qua. Bộ kit ghi thông báo ASCII để tránh lỗi bảng mã trên máy mới.

## 2. Bộ này tạo gì trên máy?

Thư mục cố định là `%USERPROFILE%\CMD-Lab`, ví dụ `C:\Users\Lan\CMD-Lab`. Không dùng Documents vì Documents có thể đã chuyển sang OneDrive hoặc thư mục khác. Mở bằng Explorer bằng cách dán `%USERPROFILE%\CMD-Lab` vào thanh địa chỉ.

```text
CMD-Lab\
  .cmd-lab-marker
  data\
    readme.txt
    notes with spaces.txt
    customers.csv
    logs\app.log
    code\hello.cmd
  outputs\
    .cmd-lab-output-marker
    report.txt       [tạo bởi bài 02]
    report.sha256    [tạo bởi bài 02]
  backups\
    demo\           [chỉ được copy khi bài 03 có /apply]
```

- Hai marker là dấu nhận diện của bộ bài: `.cmd-lab-marker` có `DQY_CMD_LAB_V1` cộng kết thúc dòng CRLF; `.cmd-lab-output-marker` có `DQY_CMD_OUTPUT_V1` cộng CRLF. Không sửa hay tự tạo marker cho thư mục dữ liệu thật.
- 5 file trong `data` là dữ liệu giả, tổng cộng có 3 khách hàng, 8 dòng log và 2 dòng chứa `ERROR` (dòng 4 và 7). Không có mật khẩu hay thông tin cá nhân thật.
- `00-create-lab.cmd` chỉ copy fixture nếu file đích chưa có. Chạy lại **giữ nguyên file dữ liệu đã tồn tại**, kể cả file bạn đã sửa. Không coi việc chạy lại bài 00 là khôi phục dữ liệu.
- Nếu `%USERPROFILE%\CMD-Lab` đã tồn tại mà không có marker đúng, script từ chối nhận thư mục đó. Hãy mở bằng Explorer, xem dữ liệu và sao lưu/đổi tên bằng tay nếu đó là thư mục riêng của bạn. Bộ này không tự xóa hoặc tự nhận quyền sở hữu thư mục có sẵn.
- Guard từ chối junction, symbolic link và các reparse point khác trong lab hoặc đường dẫn hồ sơ người dùng. Việc này ngăn một bài tưởng chạy trong lab lại đi theo liên kết tới chỗ khác. Không tạo liên kết trong lab để né kiểm tra.

Marker và hash là kiểm tra tránh thao tác nhầm trong môi trường học, không phải cơ chế chống một người cố tình thay đổi đồng thời các file. Chạy từng bài một; đừng sửa/thay đường dẫn trong lúc script đang chạy.

## 3. Lộ trình chạy từng bài

| File | Bạn học gì? | Điều gì thay đổi? |
|---|---|---|
| `00-create-lab.cmd` | Gọi helper, kiểm tra lỗi, copy có điều kiện, chạy lại an toàn | Tạo lab/marker/thư mục, bổ sung fixture còn thiếu |
| `01-file-tour.cmd` | `dir`, `tree`, `type`, `pushd`/`popd`, đường dẫn có khoảng trắng | Chỉ đọc dữ liệu và đổi thư mục tạm trong script |
| `02-search-report.cmd` | `findstr /n /i /c`, `>`/`>>`, mã trả về tìm kiếm, hash | Tạo báo cáo và manifest; không ghi đè báo cáo bạn đã sửa |
| `03-backup-demo.cmd` | `robocopy`, xem trước `/L`, codes 0–7 và ≥8 | Mặc định chỉ xem trước; `/apply` mới copy dữ liệu giả |
| `04-arguments.cmd` | Tham số, `%~1`, `%~2`, `%~dp0`, `%~nx0`, mã lỗi sử dụng | Chỉ nhận hai tên mẫu tin cậy, không sửa file |
| `05-loops.cmd` | `FOR`, `FOR /R`, `FOR /F`, đọc biến sau vòng lặp | Chỉ đọc; yêu cầu fixture vẫn đúng trước khi phân tích CSV |
| `06-errorlevels.cmd` | Lưu mã trả về ngay, `IF ERRORLEVEL`, `&&`, `||` | Chạy tiến trình CMD con trả mã 7 và 3 có chủ ý |
| `07-run-all.cmd` | Gọi batch bằng `CALL`, dừng khi lỗi, kiểm tra trường hợp sai | Tạo lab và report, backup vẫn xem trước, không cleanup |
| `08-cleanup-demo.cmd` | Cờ xác nhận, giới hạn đích xóa, kiểm tra hash | Chỉ xóa report chưa sửa và manifest, giữ thư mục/dữ liệu/backup |
| `09-verify-lab.cmd` | Kiểm tra 5 fixture và kết quả thực tế bằng SHA-256 | Chỉ đọc và trả 0/1 |

Chạy các dòng sau **từng dòng một** và đọc màn hình:

```bat
01-file-tour.cmd
02-search-report.cmd
03-backup-demo.cmd
04-arguments.cmd /name "Lan Nguyen"
05-loops.cmd
06-errorlevels.cmd
09-verify-lab.cmd
```

Báo cáo mẫu phải có đúng 4 dòng:

```text
DQY CMD LAB GENERATED REPORT V1
Search: ERROR in data\logs\app.log
4:2026-10-01 09:03:00 ERROR Demo request failed
7:2026-10-01 09:06:00 ERROR Demo timeout
```

`findstr` trả 0 khi tìm thấy, 1 khi không có kết quả, 2 trở lên khi lỗi. Bài 02 chấp nhận trường hợp log không có `ERROR` là một kết quả tìm kiếm hợp lệ; nhưng bài 09 sẽ báo fixture đã đổi nếu log khác dữ liệu mẫu.

`FOR /F` trong bài 05 chỉ minh họa file CSV mẫu rất đơn giản, không có trường đặt trong ngoặc kép, dấu phẩy trong tên hay dòng nhiều hàng. Không đem đoạn đó phân tích CSV thực tế hoặc dữ liệu không tin cậy. Bộ script nhận tham số tin cậy do bạn tự nhập; batch không phải công cụ cách ly mã lệnh từ dữ liệu bên ngoài.

## 4. Chạy trọn bộ và đọc mã kết quả

```bat
07-run-all.cmd
echo %ERRORLEVEL%
```

Bài 07 cần kết thúc với `[PASS] All exercises passed. Backup was a dry run.` và mã `0`. Nó cố tình gọi bài 04 với tham số không hỗ trợ, nhận mã `2`, rồi ghi `[PASS] Unsupported arguments returned 2 as expected.`. Đây là kiểm tra hành vi sai có chủ ý.

Bài 06 cố tình tạo tiến trình con trả `7`, cho thấy `IF ERRORLEVEL 7` nghĩa là **lớn hơn hoặc bằng 7**, không chỉ bằng 7. Chính bài 06 trả 0 khi minh họa đúng. Không coi mọi số khác 0 xuất hiện trong màn hình là toàn bộ bài thất bại.

Lệnh `echo %ERRORLEVEL%` phải chạy ngay sau lệnh bạn muốn kiểm tra. Nếu chạy thêm lệnh khác ở giữa, con số có thể là kết quả của lệnh khác. Trong các block ngoặc, biến `%...%` có thể được mở rộng trước lúc cả block chạy; phần cẩm nang giải thích cách tránh đọc giá trị cũ.

## 5. Backup có thay đổi thật nhưng chỉ trong lab

Đầu tiên xem trước:

```bat
03-backup-demo.cmd
```

Màn hình phải có `[DRY RUN] /L is active`. Nếu muốn thực hành copy thật sau khi đọc đích nguồn/đích:

```bat
03-backup-demo.cmd /apply
dir /s /b "%USERPROFILE%\CMD-Lab\backups\demo"
```

Nguồn chỉ là `CMD-Lab\data`; đích chỉ là `CMD-Lab\backups\demo`. `/E` copy cả thư mục con; `/R:1 /W:1` hạn chế số lần/thời gian thử lại; `/XJ` bỏ junction và guard đã từ chối reparse point trước đó. Không có `/MIR` hay `/PURGE`; file thừa ở đích được giữ. Một file ở backup có cùng tên có thể được cập nhật theo nguồn khi bạn chạy `/apply` lại: đừng lưu tài liệu riêng ở thư mục backup mẫu.

Robocopy dùng mã trạng thái: **0–7 không phải lỗi nghiêm trọng; từ 8 trở lên là thất bại**. Script in mã gốc rồi chuyển thành 0/1 phù hợp bộ chạy bài. `/L` là xem trước việc copy, không phải chứng minh rằng lần copy thật sẽ luôn thành công; quyền truy cập, dung lượng và trạng thái file vẫn có thể thay đổi.

Đây là bài copy một bộ file giả, không phải giải pháp backup máy tính, phiên bản lịch sử hay khôi phục thảm họa. Backup hữu ích phải có bản ở nơi độc lập và được thử khôi phục.

## 6. Cleanup được giới hạn thế nào?

Lệnh không có cờ xác nhận chỉ in cách dùng và trả `2`:

```bat
08-cleanup-demo.cmd
```

Khi bạn muốn xóa **đúng báo cáo mẫu đã sinh**, chạy:

```bat
08-cleanup-demo.cmd /confirm
```

Script kiểm tra marker và reparse point, tính SHA-256 hiện tại của `outputs\report.txt` rồi so với `report.sha256`. Chỉ khi trùng mới xóa hai file cụ thể đó. Không dùng `rd /s`, không xóa root, không đụng `data`, `backups`, `exercises` hay file khác trong outputs. Nếu không còn report, script báo không có báo cáo cần xóa và trả 0.

Nếu bạn sửa report trong Notepad, cleanup **từ chối xóa**, bài 02 cũng **từ chối ghi đè**. Bạn cần quyết định bằng tay: lưu bản đã sửa vào nơi khác, rồi xử lý đúng report/manifest do mình đã xem. Đừng tự sửa manifest để ép guard xóa một file đang cần giữ. Sau cleanup có thể chạy bài 02 để sinh lại; bài 09 vẫn kiểm tra 5 fixture nếu chưa có report.

## 7. Lỗi thường gặp

| Hiện tượng | Vì sao và cách xử lý |
|---|---|
| `'00-create-lab.cmd' is not recognized...` | Đang sai thư mục, ZIP chưa giải nén hết hoặc tên bị thành `.cmd.txt`. Dùng `dir /b`; trong Explorer bật **View → Show → File name extensions**. |
| Cửa sổ bật rồi tắt | Bạn nhấp đúp script. Mở CMD và chạy bằng tên file để đọc kết quả sau khi kết thúc. Không thêm `pause` vào bài dùng cho tự động hóa. |
| `Existing lab is not marked` | Thư mục có sẵn không được bộ này tạo. Mở bằng Explorer và giữ dữ liệu; không tự xóa hoặc tạo marker để qua kiểm tra. |
| `Reparse point...` | Có junction/symlink/đường dẫn hồ sơ dùng reparse point. Không chạy để đi theo liên kết. Dùng môi trường học thông thường hoặc nhờ quản trị giải thích cấu hình máy. |
| `Fixture changed...` | Bạn đã sửa dữ liệu hoặc file tải lỗi. Bài 00 giữ file có sẵn nên không khôi phục tự động. Sao lưu bản đã sửa, rồi copy đúng fixture từ bộ ZIP nếu muốn trở lại dữ liệu mẫu. |
| `Expected 5 data files...` | Bạn thêm file trong data. Đặt bài riêng ở `CMD-Lab\exercises` hoặc nơi khác để bộ mẫu vẫn có 5 file. |
| `Report was edited...` | Hash không còn trùng, vì report/manifest đã đổi hoặc tạo báo cáo chưa hoàn tất. Guard giữ file. Xem nội dung và quyết định lưu/đổi tên bằng tay trước khi sinh lại. |
| `powershell.exe` không có hoặc bị chặn | Guard không thể chứng minh đường dẫn an toàn nên dừng. Không bỏ guard; kiểm tra bản Windows/chính sách máy với người quản trị. |
| Robocopy `Access denied`, mã ≥8 | Đọc đường dẫn được in, kiểm tra quyền trong lab, file đang mở và dung lượng. Không mở admin ngay để thử trên thư mục hệ thống. |
| Chữ tiếng Việt lỗi | Bộ script/fixture dùng ASCII để bài chính không phụ thuộc bảng mã. File bạn tự thêm cần chọn bảng mã và công cụ đọc phù hợp; `chcp 65001` không sửa mọi vấn đề Unicode. |

## 8. Bạn hiểu bài khi tự giải thích được

- Vì sao đường dẫn phải có ngoặc kép? `cd /d` khác `cd` thế nào?
- Bài 00 chạy lại giữ được file đã sửa nhưng bài 09 có thể thất bại vì sao?
- Vì sao tìm không thấy từ khóa khác lỗi không đọc được file?
- Mã 1 của Robocopy khác mã 1 của `findstr` thế nào?
- Đâu là điểm chuyển từ xem trước sang thao tác copy thật?
- Vì sao gọi một batch từ batch khác cần `CALL`?
- Vì sao `IF ERRORLEVEL 7` phải hiểu theo ngưỡng? Khi nào `%ERRORLEVEL%` có thể cũ?
- Vì sao cleanup kiểm tra hash trước khi xóa mà vẫn không phải biện pháp chống người cố tình sửa marker/hash?
- Vì sao `FOR /F` không đủ để đọc CSV doanh nghiệp?

Nếu trả lời được, tạo bài riêng trong `%USERPROFILE%\CMD-Lab\exercises` với dữ liệu giả. Đừng đổi script mẫu sang thư mục dữ liệu công việc trước khi hiểu đầy đủ lệnh và có bản sao.

## 9. Kiểm chứng và giới hạn

`09-verify-lab.cmd` kiểm tra marker/đường dẫn, đúng 5 fixture, SHA-256 từng fixture và nội dung/hash báo cáo nếu report tồn tại. Nó trả 0 khi đúng, 1 khi sai. Chạy bài này trên máy Windows của bạn để xác nhận kết quả tại máy đó; đọc thông báo `[PASS]` trước khi kết luận.

Bộ kit được xây dựng trong môi trường Linux; kết quả kiểm tra chạy CMD Windows, nếu có, được ghi riêng trong tài liệu kiểm chứng của bản phát hành. Windows Server trên GitHub Actions và Windows 11 có nhiều công cụ giống nhau nhưng không thay thế việc thử các thao tác giao diện/chính sách trên chính máy bạn. Không coi kiểm tra file văn bản trên Linux là bằng chứng đã chạy Windows CMD.

Bài 02 dựng báo cáo mới trong `outputs\report.pending.txt`, tạo hash ứng viên trong `report.sha256.pending.txt`, rồi mới chuyển từng file hoàn chỉnh thành tên chính thức. Nó không ghi đè tên pending đã có. Khi lỗi, file pending được giữ để bạn xem; hãy lưu hoặc đổi tên bằng tay sau khi đã kiểm tra nội dung. Thay thế từng file không làm cho cặp report/hash trở thành một giao dịch: mất điện hoặc lỗi ghi đĩa ở giữa vẫn có thể để cặp không khớp; bài 09/guard sẽ phát hiện và dừng thay vì cố xóa dữ liệu. File report/manifest đặt thuộc tính chỉ đọc cũng làm bài 02 dừng và giữ file cũ.
