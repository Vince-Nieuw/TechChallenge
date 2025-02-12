from flask import Flask, request, jsonify, render_template
from pymongo import MongoClient
import os
from datetime import datetime, timedelta

app = Flask(__name__)

# MongoDB Configuration (INTENTIONAL WEAKNESS: Hardcoded credentials)
MONGO_URI = os.getenv("MONGO_URI", "mongodb://admin:password@your-ec2-ip:27017/expenseDB")
client = MongoClient(MONGO_URI)
db = client.expenseDB
expenses = db.expenses

@app.route('/')
def index():
    return render_template("index.html")

@app.route('/add_expense', methods=['POST'])
def add_expense():
    data = request.json
    if not data.get("amount") or not data.get("category"):
        return jsonify({"error": "Missing required fields"}), 400
    
    data["date"] = datetime.utcnow()
    expenses.insert_one(data)
    return jsonify({"message": "Expense added successfully!"})

@app.route('/expenses', methods=['GET'])
def get_expenses():
    all_expenses = list(expenses.find({}, {"_id": 0}))
    return jsonify(all_expenses)

@app.route('/forecast', methods=['GET'])
def forecast():
    days = int(request.args.get("days", 30))
    past_expenses = list(expenses.find({}, {"_id": 0}))
    
    if not past_expenses:
        return jsonify({"message": "No expenses recorded yet."})
    
    total_spent = sum(e["amount"] for e in past_expenses)
    daily_avg = total_spent / max(len(past_expenses), 1)
    forecasted = daily_avg * days
    
    return jsonify({"forecasted_expense": forecasted, "days": days})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

