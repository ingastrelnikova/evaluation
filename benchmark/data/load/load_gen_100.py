import time
import csv
import psycopg2
from psycopg2 import sql
import os
from glob import glob
import pandas as pd

DB_HOST = os.getenv('DB_HOST', 'research')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'research')
DB_USER = os.getenv('DB_USER', 'test')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'test')

CSV_DIR_PATH = os.getenv('CSV_DIR_PATH', 'anonymized_patients/10000')
LOG_CSV_PATH = os.getenv('LOG_CSV_PATH', 'write_log.csv')

def create_connection():
    print("Creating connection to the database...")
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )
    print("Connection created.")
    return conn

def insert_data(conn, data):
    query = sql.SQL("""
        INSERT INTO anonymized_patients (
            anonymized_date_of_birth, anonymized_name, disease, gender, zip_code
        ) VALUES (%s, %s, %s, %s, %s)
    """)
    with conn.cursor() as cursor:
        cursor.execute(query, data)
    conn.commit()

def load_data_from_csv(csv_file_path):
    print(f"Loading data from CSV file: {csv_file_path}")
    with open(csv_file_path, mode='r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            yield (
                row['dateOfBirth'],
                row['name'],
                row['disease'],
                row['gender'],
                row['zipcode']
            )

def log_write_transaction(start_time, end_time, duration, record_count, tps, latency):
    with open(LOG_CSV_PATH, mode='a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([start_time, end_time, duration, record_count, tps, latency])

def format_timestamp(ts):
    return ts.strftime('%Y-%m-%d %H:%M:%S.%f') + ' +0000 UTC m=+' + str(ts.second) + '.' + str(ts.microsecond).zfill(6)

def main():
    time.sleep(5)
    print("Waited for 5 seconds. Proceeding...")
    conn = create_connection()

    # Initialize log CSV file
    if not os.path.exists(LOG_CSV_PATH):
        with open(LOG_CSV_PATH, mode='w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(['start_time', 'end_time', 'duration_seconds', 'record_count', 'transactions_per_second', 'latency_ms'])

    try:
        while True:
            csv_files = sorted(glob(os.path.join(CSV_DIR_PATH, '*.csv')))
            print(f"Found CSV files: {csv_files}")
            for csv_file in csv_files:
                start_time = pd.Timestamp.now()
                record_count = 0
                for data in load_data_from_csv(csv_file):
                    insert_data(conn, data)
                    record_count += 1
                end_time = pd.Timestamp.now()
                duration = (end_time - start_time).total_seconds()
                tps = record_count / duration if duration > 0 else 0
                latency = duration * 1000  # Convert to milliseconds

                # Format timestamps
                start_time_str = format_timestamp(start_time)
                end_time_str = format_timestamp(end_time)

                log_write_transaction(start_time_str, end_time_str, duration, record_count, tps, latency)
                time.sleep(5)
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        conn.close()
        print("Database connection closed.")

if __name__ == "__main__":
    main()
