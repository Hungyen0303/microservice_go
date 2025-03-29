from flask import Flask, request, jsonify, Response
import os
import pymongo
from bson.objectid import ObjectId
import logging

# Khởi tạo Flask app
app = Flask(__name__)

# Cấu hình logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

mongo_uri = os.getenv("MONGODB_URI")
if not mongo_uri:
    logger.error("MONGODB_URI environment variable not set")
    exit(1)

try:
    client = pymongo.MongoClient(mongo_uri)
    db = client["shop"]  # Database tên "shop"
    collection = db["products"]  # Collection tên "products"
    logger.info("Connected to MongoDB")
except Exception as e:
    logger.error(f"Failed to connect to MongoDB: {e}")
    exit(1)

class Product:
    def __init__(self, name, price, id=None):
        self.id = id
        self.name = name
        self.price = price

    def to_dict(self):
        return {
            "_id": str(self.id) if self.id else None,
            "name": self.name,
            "price": self.price
        }

# Endpoint GET /products
@app.route("/products", methods=["GET"])
def get_products():
    try:
        products = []
        for product in collection.find():
            products.append({
                "id": str(product["_id"]),
                "name": product["name"],
                "price": product["price"]
            })
        return jsonify(products)
    except Exception as e:
        logger.error(f"Error fetching products: {e}")
        return Response("Error fetching products", status=500)

# Endpoint POST /products
@app.route("/products", methods=["POST"])
def create_product():
    try:
        data = request.get_json()
        if not data or "name" not in data or "price" not in data:
            return Response("Invalid request body", status=400)

        product = Product(name=data["name"], price=data["price"])
        result = collection.insert_one({"name": product.name, "price": product.price})
        
        product.id = result.inserted_id
        return jsonify(product.to_dict()), 201  # Trả về mã 201 Created
    except Exception as e:
        logger.error(f"Error inserting product: {e}")
        return Response("Error inserting product", status=500)

# Xử lý các method không được phép
@app.route("/products", methods=["PUT", "DELETE", "PATCH"])
def method_not_allowed():
    return Response("Method not allowed", status=405)

# Chạy ứng dụng

PORT = 8082 
if __name__ == "__main__":
    logger.info(f"🚀 Server running on port {PORT}")
    app.run(host="0.0.0.0", port=PORT, debug=True)