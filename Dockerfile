# Sử dụng image Python chính thức
FROM python:3.9-slim

# Đặt thư mục làm việc trong container
WORKDIR /app

# Sao chép file yêu cầu dependency (nếu có requirements.txt) hoặc cài trực tiếp
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Sao chép toàn bộ code vào container
COPY . .

ENV MONGODB_URI="mongodb+srv://nguyenhungyen0000:Hungyen%402003@cluster0.djkgyu0.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

# Mở port mà Flask app chạy
EXPOSE 8082

# Lệnh chạy Flask app
CMD ["python", "main.py"]