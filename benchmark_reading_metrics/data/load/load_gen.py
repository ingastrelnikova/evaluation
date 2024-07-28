import time
import csv
import psycopg2
from psycopg2 import sql
import os
from glob import glob
import pandas as pd

# Environment variables
DB_HOST = os.getenv('DB_HOST', 'research')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'research')
DB_USER = os.getenv('DB_USER', 'test')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'test')

CSV_DIR_PATHS = [
    os.getenv('CSV_DIR_PATH_10000', '/app/anonymized_patients/100'),
    os.getenv('CSV_DIR_PATH_1000', '/app/anonymized_patients/1000'),
    os.getenv('CSV_DIR_PATH_100', '/app/anonymized_patients/10000')
]
LOG_CSV_PATH = os.getenv('LOG_CSV_PATH', '/app/write_log.csv')

def create_connection():
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )
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

def delete_all_data(conn):
    query = sql.SQL("DELETE FROM anonymized_patients")
    with conn.cursor() as cursor:
        cursor.execute(query)
    conn.commit()

def load_data_from_csv(csv_file_path):
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

def log_transaction(start_time, end_time, duration, record_count, tps, latency, transaction_type):
    with open(LOG_CSV_PATH, mode='a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([start_time, end_time, duration, record_count, tps, latency, transaction_type])

def format_timestamp(ts):
    return ts.strftime('%Y-%m-%d %H:%M:%S.%f') + ' +0000 UTC m=+' + str(ts.second) + '.' + str(ts.microsecond).zfill(6)

def perform_experiment(conn, csv_dir_path):
    for i in range(5):  # Repeat 5 times
        csv_files = sorted(glob(os.path.join(csv_dir_path, '*.csv')))
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

            log_transaction(start_time_str, end_time_str, duration, record_count, tps, latency, "insertion")
            time.sleep(5)

        # Perform deletion
        start_time = pd.Timestamp.now()
        delete_all_data(conn)
        end_time = pd.Timestamp.now()
        duration = (end_time - start_time).total_seconds()
        tps = record_count / duration if duration > 0 else 0
        latency = duration * 1000  # Convert to milliseconds

        # Format timestamps
        start_time_str = format_timestamp(start_time)
        end_time_str = format_timestamp(end_time)

        log_transaction(start_time_str, end_time_str, duration, record_count, tps, latency, "deletion")

def main():
    time.sleep(5)
    print("Waited for 5 seconds. Proceeding...")
    conn = create_connection()

    # Initialize log CSV file
    if not os.path.exists(LOG_CSV_PATH):
        with open(LOG_CSV_PATH, mode='w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(['start_time', 'end_time', 'duration_seconds', 'record_count', 'transactions_per_second', 'latency_ms', 'transaction_type'])

    try:
        for csv_dir_path in CSV_DIR_PATHS:
            print(f"Starting experiment for CSV directory: {csv_dir_path}")
            perform_experiment(conn, csv_dir_path)
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        conn.close()
        print("Database connection closed.")

if __name__ == "__main__":
    main()
