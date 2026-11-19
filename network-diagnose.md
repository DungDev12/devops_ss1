1. Tình huống 1: Xử lý trùng cổng 8080

Mô tả: Khi chạy ứng dụng user-service thì gặp lỗi Address already in use do cổng 8080 đã có chương trình khác sử dụng.

Bước 1: Kiểm tra cổng 8080

sudo ss -tulpn | grep :8080

Giải thích: Lệnh này dùng để kiểm tra xem cổng 8080 có chương trình nào đang sử dụng hay không và tìm PID của chương trình đó.

Ví dụ kết quả:

tcp LISTEN 0 100 0.0.0.0:8080 0.0.0.0:* users:(("java",pid=1234,fd=10))

Ở đây PID của chương trình là 1234.

Bước 2: Tắt tiến trình đang sử dụng cổng

sudo kill -9 1234

Giải thích: Lệnh này dùng để tắt tiến trình có PID là 1234 nhằm giải phóng cổng 8080.

Lưu ý: PID 1234 chỉ là ví dụ, khi thực hành cần thay bằng PID thực tế. Nên thử sudo kill 1234 trước, nếu tiến trình không dừng mới sử dụng kill -9.

Bước 3: Kiểm tra lại cổng 8080

sudo ss -tulpn | grep :8080

Kết quả mong đợi: Không hiển thị kết quả nào, nghĩa là không còn tiến trình đang lắng nghe trên cổng 8080.

2. Tình huống 2: Kiểm tra kết nối PostgreSQL

Mô tả: Ứng dụng user-service không thể kết nối đến Database PostgreSQL có địa chỉ IP 10.0.1.20 và cổng 5432.

Bước 1: Kiểm tra kết nối đến máy chủ Database

ping -c 4 10.0.1.20

Giải thích: Lệnh ping dùng để kiểm tra máy chủ Database có phản hồi qua mạng hay không. Tham số -c 4 là gửi 4 gói tin kiểm tra.

Nếu nhận được phản hồi thì máy chủ có thể liên lạc qua ICMP. Nếu không nhận được phản hồi thì có thể do lỗi mạng, máy chủ không hoạt động hoặc bị Firewall chặn ping.

Bước 2: Kiểm tra cổng PostgreSQL 5432

nc -zv -w 3 10.0.1.20 5432

Giải thích: Lệnh này dùng để kiểm tra xem cổng 5432 của Database có chấp nhận kết nối TCP hay không.

Nếu hiện thông báo:

Connection to 10.0.1.20 5432 port [tcp/postgresql] succeeded!

Nghĩa là máy có thể kết nối tới cổng PostgreSQL.

Nếu hiện Connection refused hoặc timed out thì có thể Database chưa chạy, chưa mở cổng, bị Firewall chặn hoặc có vấn đề về mạng.

Bước 3: Kiểm tra bằng curl

curl -v --connect-timeout 3 telnet://10.0.1.20:5432

Giải thích: Lệnh này kiểm tra khả năng tạo kết nối TCP đến cổng 5432. Nếu kết nối thành công thì cổng có thể truy cập được, nhưng chưa chắc đã đăng nhập được vào Database.

3. Kết luận

Qua bài thực hành này, em đã biết cách:

Sử dụng lệnh ss để kiểm tra cổng mạng đang được sử dụng.

Sử dụng lệnh kill để dừng tiến trình và giải phóng cổng.

Sử dụng lệnh ping để kiểm tra kết nối đến máy chủ.

Sử dụng lệnh nc và curl để kiểm tra cổng kết nối Database PostgreSQL.