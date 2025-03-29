# Build stage
FROM golang:1.24 AS builder

# Đặt thư mục làm việc
WORKDIR /build

# Copy go.mod và go.sum để tải dependency trước
COPY go.mod go.sum ./
RUN go mod tidy

# Copy toàn bộ mã nguồn
COPY . .

# Build ứng dụng cho Linux (Docker chạy trên Linux kernel)
RUN go build -o products-api

# Runtime stage
FROM alpine:latest

# Cài đặt các thư viện cần thiết cho runtime (để tránh lỗi "exec: no such file or directory")
RUN apk add --no-cache libc6-compat

# Đặt thư mục làm việc
WORKDIR /app

# Copy file thực thi từ build stage
COPY --from=builder /build/products-api .

# Mở cổng ứng dụng
EXPOSE 8082

# Định nghĩa biến môi trường (có thể override khi chạy container)
ENV MONGODB_URI="mongodb+srv://nguyenhungyen0000:Hungyen%402003@cluster0.djkgyu0.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

# Chạy ứng dụng
CMD ["./products-api"]