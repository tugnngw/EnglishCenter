# English Center - Docker Setup

## Cấu trúc Docker

Dự án sử dụng Docker Compose với 2 services:
- **PostgreSQL**: Database server
- **Spring Boot App**: Ứng dụng Java

## Yêu cầu

- Docker Desktop hoặc Docker Engine
- Docker Compose

## Cách sử dụng

### 1. Khởi động toàn bộ ứng dụng

```bash
docker-compose up -d
```

Lệnh này sẽ:
- Build Docker image cho Spring Boot application
- Khởi động PostgreSQL database
- Khởi động Spring Boot application
- Tự động kết nối database

### 2. Xem logs

```bash
# Xem logs của tất cả services
docker-compose logs -f

# Xem logs của app
docker-compose logs -f app

# Xem logs của database
docker-compose logs -f postgres
```

### 3. Dừng ứng dụng

```bash
docker-compose down
```

### 4. Dừng và xóa dữ liệu

```bash
docker-compose down -v
```

### 5. Rebuild application

Sau khi thay đổi code:

```bash
docker-compose up -d --build
```

## Truy cập ứng dụng

- **Application**: http://localhost:8080
- **PostgreSQL**: localhost:5432
  - Database: `englishcenter`
  - Username: `myuser`
  - Password: `secret`

## Cấu hình môi trường

Bạn có thể thay đổi cấu hình trong file `compose.yaml`:

```yaml
environment:
  - 'SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/englishcenter'
  - 'SPRING_DATASOURCE_USERNAME=myuser'
  - 'SPRING_DATASOURCE_PASSWORD=secret'
```

## Development

### Chạy local (không dùng Docker)

1. Khởi động chỉ database:
```bash
docker-compose up -d postgres
```

2. Chạy Spring Boot từ IDE hoặc Maven:
```bash
./mvnw spring-boot:run
```

### Kết nối database từ local

Application sẽ tự động kết nối đến database ở `localhost:5432`

## Troubleshooting

### Application không kết nối được database

Kiểm tra database đã chạy chưa:
```bash
docker-compose ps
```

### Port đã được sử dụng

Nếu port 8080 hoặc 5432 đã được sử dụng, thay đổi trong `compose.yaml`:
```yaml
ports:
  - '8081:8080'  # Thay đổi port bên ngoài
```

### Xem trạng thái containers

```bash
docker-compose ps
```

### Vào bên trong container

```bash
# Vào app container
docker exec -it englishcenter-app bash

# Vào postgres container
docker exec -it englishcenter-db psql -U myuser -d englishcenter
```
