package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Product struct {
	ID    primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	Name  string             `json:"name" bson:"name"`
	Price int                `json:"price" bson:"price"`
}

var client *mongo.Client

func getProducts(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	collection := client.Database("shop").Collection("products")

	cursor, err := collection.Find(context.TODO(), bson.M{})
	if err != nil {
		http.Error(w, "Error fetching products", http.StatusInternalServerError)
		return
	}
	defer cursor.Close(context.TODO())

	var products []Product
	if err := cursor.All(context.TODO(), &products); err != nil {
		http.Error(w, "Error decoding products", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(products)
}

func createProduct(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	var product Product
	if err := json.NewDecoder(r.Body).Decode(&product); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	collection := client.Database("shop").Collection("products")
	result, err := collection.InsertOne(context.TODO(), product)
	if err != nil {
		http.Error(w, "Error inserting product", http.StatusInternalServerError)
		return
	}

	product.ID = result.InsertedID.(primitive.ObjectID)
	json.NewEncoder(w).Encode(product)
}

func main() {
	// Lấy MongoDB URI từ biến môi trường
	mongoURI := os.Getenv("MONGODB_URI")
	if mongoURI == "" {
		log.Fatal("Missing MongoDB URI")
	}

	// Kết nối MongoDB
	var err error
	client, err = mongo.Connect(context.TODO(), options.Client().ApplyURI(mongoURI))
	if err != nil {
		log.Fatal(err)
	}

	http.HandleFunc("/products", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodGet {
			getProducts(w, r)
		} else if r.Method == http.MethodPost {
			createProduct(w, r)
		} else {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		}
	})

	log.Println("🚀 Server running on port 8082")
	http.ListenAndServe(":8082", nil)
}
