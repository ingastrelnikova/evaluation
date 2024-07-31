from flask import Flask, jsonify, request
import psycopg2
import os
import requests
import sys
import time
import csv

app = Flask(__name__)

# Function to write latency data to CSV
def log_latency(start_time, end_time, operation, result):
    latency = (end_time - start_time) * 1000  # Convert to milliseconds
    with open('latencies.csv', mode='a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([start_time, end_time, latency, operation, result])

# Database connection
def get_db_connection():
    conn = psycopg2.connect(
        dbname=os.getenv('DB_NAME', 'research'),
        user=os.getenv('DB_USER', 'test'),
        password=os.getenv('DB_PASSWORD', 'test'),
        host=os.getenv('DB_HOST', 'research-db'),
        port=os.getenv('DB_PORT', '5432')
    )
    return conn

# Method for access control by checking with OPA
def check_authorization():
    opa_url = os.getenv('OPA_URL', 'http://opa:8181/v1/data/authz/allow')
    input_data = {
        "input": {
            "method": request.method,
            "path": request.path
        }
    }
    start_time = time.time()
    response = requests.post(opa_url, json=input_data)
    response_json = response.json()
    end_time = time.time()
    result = response_json.get("result", False)
    log_latency(start_time, end_time, "policy checking",result)
    sys.stdout.flush()
    return result

# Endpoint to retrieve data
@app.route('/data', methods=['GET'])
def get_data():
    sys.stdout.flush()
    result = check_authorization()
    if not result:
        sys.stdout.flush()
        return "Unauthorized", 403
    try:
        start_time = time.time()
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM anonymized_patients;')
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        end_time = time.time()
        log_latency(start_time, end_time, "data retrieval", result)
        return jsonify(rows)
    except Exception as e:
        return str(e), 500

if __name__ == '__main__':
    # Ensure CSV file has a header
    with open('latencies.csv', mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["start_time", "end_time", "latency_ms", "operation", "authorized"])
    app.run(debug=True, host='0.0.0.0', port=3002)
