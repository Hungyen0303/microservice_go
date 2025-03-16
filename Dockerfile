# Build stage
FROM golang:1.24 AS builder

# Đặt thư mục làm việc
WORKDIR /app

# Copy tất cả files vào container
COPY . .

# Tải các thư viện
RUN go mod tidy

# Build ứng dụng
RUN go build -o main .

# Runtime stage (chạy ứng dụng)
FROM alpine:latest

WORKDIR /root/

# Cài đặt thư viện cần thiết cho runtime
RUN apk add --no-cache ca-certificates

# Copy file đã build từ builder
COPY --from=builder /app/main .

# Mở cổng ứng dụng
EXPOSE 8082

# Định nghĩa biến môi trường
ENV MONGODB_URI="mongodb+srv://nguyenhungyen0000:Hungyen%402003@cluster0.qfr7n.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

# Chạy ứng dụng
CMD ["./app/main"]
