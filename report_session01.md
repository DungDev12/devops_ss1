
# BÁO CÁO THỰC HÀNH BUỔI 1


## 1. Mục đích
- Tạo nhóm người dùng trên Linux.
- Tạo một user để chạy ứng dụng.
- Tạo thư mục chứa ứng dụng.
- Phân quyền cho thư mục để đảm bảo an toàn.

## 2. Các bước thực hiện

### Bước 1: Tạo nhóm người dùng

Đầu tiên, em sử dụng lệnh sau để tạo nhóm có tên `quickbite-apps`.

```bash
sudo groupadd quickbite-apps
```

Sau đó, em kiểm tra nhóm đã tạo bằng lệnh:

```bash
getent group quickbite-apps
```

Nếu lệnh hiển thị thông tin nhóm thì có nghĩa là nhóm đã được tạo.

### Bước 2: Tạo user chạy ứng dụng

Tiếp theo, em tạo user có tên `user-svc` và cho user này thuộc nhóm `quickbite-apps`.

```bash
sudo useradd --system --no-create-home \
--gid quickbite-apps \
--shell /usr/sbin/nologin user-svc
```

Trong đó:

- `--system`: Tạo user hệ thống.
- `--no-create-home`: Không tạo thư mục home.
- `--gid`: Chỉ định nhóm cho user.
- `--shell /usr/sbin/nologin`: Không cho user đăng nhập trực tiếp.

Sau khi tạo, em kiểm tra lại bằng lệnh:

```bash
id user-svc
```

Lệnh này sẽ hiển thị thông tin user và nhóm mà user đang thuộc về.

### Bước 3: Tạo thư mục chứa ứng dụng

Em tạo thư mục để chứa ứng dụng User Service trong môi trường Development.

```bash
sudo mkdir -p /opt/quickbite/dev/user-service
```

Trong đó, `mkdir` là lệnh tạo thư mục và `-p` giúp tạo luôn các thư mục cha nếu chưa có.

Sau đó, em kiểm tra bằng lệnh:

```bash
ls -ld /opt/quickbite/dev/user-service
```

### Bước 4: Thay đổi quyền sở hữu thư mục

Để user `user-svc` có thể quản lý thư mục ứng dụng, em sử dụng lệnh:

```bash
sudo chown -R user-svc:quickbite-apps /opt/quickbite/dev/user-service
```

Trong đó:

- `chown`: Thay đổi người sở hữu.
- `-R`: Áp dụng cho cả thư mục và các file bên trong.
- `user-svc`: User sở hữu.
- `quickbite-apps`: Nhóm sở hữu.

### Bước 5: Phân quyền thư mục

Tiếp theo, em phân quyền `750` cho thư mục bằng lệnh:

```bash
sudo chmod -R 750 /opt/quickbite/dev/user-service
```

Ý nghĩa của `750`:

- `7`: Người sở hữu được đọc, ghi và thực thi.
- `5`: Nhóm được đọc và thực thi.
- `0`: Những người dùng khác không có quyền.

Sau đó, em kiểm tra lại:

```bash
ls -ld /opt/quickbite/dev/user-service
```

Kết quả:

```text
drwxr-x--- user-svc quickbite-apps user-service
```


## 3. Các lệnh Linux đã sử dụng

| STT | Lệnh | Công dụng |
|---|---|---|
| 1 | `sudo groupadd quickbite-apps` | Tạo nhóm |
| 2 | `getent group quickbite-apps` | Kiểm tra nhóm |
| 3 | `sudo useradd ... user-svc` | Tạo user |
| 4 | `id user-svc` | Kiểm tra thông tin user |
| 5 | `sudo mkdir -p ...` | Tạo thư mục |
| 6 | `sudo chown -R ...` | Thay đổi người sở hữu |
| 7 | `sudo chmod -R 750 ...` | Phân quyền thư mục |
| 8 | `ls -ld ...` | Kiểm tra quyền thư mục |

## 4. Kết quả thực hành

Sau khi thực hiện các bước trên, em cần kiểm tra lại:

- Nhóm `quickbite-apps` đã được tạo.
- User `user-svc` đã được tạo và thuộc nhóm `quickbite-apps`.
- Đã có thư mục `/opt/quickbite/dev/user-service`.
- Thư mục được gán cho user `user-svc`.
- Quyền của thư mục được thiết lập là `750`.

