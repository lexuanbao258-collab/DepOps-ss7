# QuickBite - Session 05 Docker & Spring Boot

Project thực hành gồm 4 Spring Boot microservice độc lập:

- `user-service` - port 8081
- `restaurant-service` - port 8082
- `order-service` - port 8083
- `notification-service` - port 8084

Project đáp ứng 4 phần bài tập:

1. Đóng gói 4 service thành Docker image bằng `eclipse-temurin:17-jre-alpine`.
2. Chạy 4 backend bằng Docker Compose trên external network `quickbite-net`.
3. Tách cấu hình sang `.env` với prefix riêng cho từng service.
4. Dùng Hibernate `ddl-auto=update`; `user-service` tự tạo các bảng `users`, `user_addresses`, `user_wallets`.

## Yêu cầu máy

- JDK 17
- Docker Desktop / Docker Engine
- Docker Compose v2
- Internet ở lần build đầu tiên để Gradle tải dependency và Docker tải image.

Kiểm tra Java:

```powershell
java -version
```

Phải là Java 17.

## 1. Chuẩn bị external network và database độc lập

Nếu Session 4 của bạn **đã có** network `quickbite-net` và container `quickbite-db`, bỏ qua phần này.

Nếu chưa có, chạy tại thư mục gốc project:

```powershell
.\setup-infrastructure.ps1
```

Script sẽ:

- tạo `quickbite-net` nếu chưa có;
- chạy PostgreSQL độc lập với container name `quickbite-db`;
- tạo 4 database:
  - `quickbite_user_db`
  - `quickbite_restaurant_db`
  - `quickbite_order_db`
  - `quickbite_notification_db`

Kiểm tra:

```powershell
docker network ls | findstr quickbite-net
docker ps | findstr quickbite-db
```

## 2. Build 4 JAR và Docker image

Chạy:

```powershell
.\build-all.ps1
```

Script build lần lượt:

```text
quickbite-user-service:latest
quickbite-restaurant-service:latest
quickbite-order-service:latest
quickbite-notification-service:latest
```

Kiểm tra theo yêu cầu bài 1:

```powershell
docker images | findstr quickbite
```

Chụp màn hình kết quả và lưu tại:

```text
homework/session_05/exercise_01/build_images.png
```

## 3. Kiểm tra nội suy `.env`

```powershell
docker compose config
```

Kết quả không được có cảnh báo biến chưa được khai báo.

## 4. Chạy 4 backend

```powershell
docker compose up -d
```

Hoặc theo yêu cầu bài Hibernate:

```powershell
docker compose up -d --build
```

> Vì Dockerfile của đề chỉ COPY JAR đã build sẵn, hãy chạy `.\build-all.ps1` ít nhất một lần trước lệnh `docker compose up -d --build`.

Kiểm tra:

```powershell
docker compose ps
```

Kỳ vọng 4 container đều `Up` và map port 8081-8084.

Test HTTP:

```powershell
curl.exe http://localhost:8081/health
curl.exe http://localhost:8082/health
curl.exe http://localhost:8083/health
curl.exe http://localhost:8084/health
```

## 5. Xác minh Hibernate DDL-Auto

Cả 4 service dùng:

```properties
spring.jpa.hibernate.ddl-auto=${DDL_AUTO:update}
```

Main compose truyền `DDL_AUTO=update` cho từng service.

Kiểm tra `user-service` đã tạo bảng:

```powershell
docker exec -it quickbite-db psql -U postgres -d quickbite_user_db -c "\dt"
```

Kết quả cần có tối thiểu:

```text
users
user_addresses
user_wallets
```

## 6. Dừng hệ thống

Dừng 4 backend:

```powershell
docker compose down
```

Database độc lập vẫn chạy. Nếu muốn dừng database local do project này tạo:

```powershell
docker compose -f infrastructure/docker-compose-db.yml down
```

Không dùng `-v` nếu muốn giữ dữ liệu PostgreSQL.

## Ghi chú bài tập

- `quickbite-net` trong `docker-compose.yml` là `external: true`; Compose chính không tự tạo mạng này.
- `quickbite-db` không nằm trong Compose chính, đúng mô hình database chạy độc lập.
- `.env` có giá trị local để chạy bài ngay; `.env.example` là mẫu an toàn để đẩy Git.
- Dockerfile cố ý không dùng multi-stage build để bám đúng đề: Gradle build JAR trước, sau đó Docker chỉ đóng gói JAR bằng JRE 17.
