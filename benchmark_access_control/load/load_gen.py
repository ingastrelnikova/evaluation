import time
import csv
import psycopg2
from psycopg2 import sql
import os
from glob import glob
import random

# Environment variables
DB_HOST = os.getenv('DB_HOST', 'research-db')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'research')
DB_USER = os.getenv('DB_USER', 'test')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'test')

CSV_DIR_PATHS = [
    os.getenv('CSV_DIR_PATH_10000', '/app/anonymized_patients/10000'),
    os.getenv('CSV_DIR_PATH_1000', '/app/anonymized_patients/1000'),
    os.getenv('CSV_DIR_PATH_100', '/app/anonymized_patients/100')
]

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

def delete_data(conn, ids):
    query = sql.SQL("DELETE FROM anonymized_patients WHERE anonymized_id = ANY(%s)")
    with conn.cursor() as cursor:
        cursor.execute(query, (ids,))
    conn.commit()

def fetch_inserted_ids(conn):
    query = sql.SQL("SELECT anonymized_id FROM anonymized_patients")
    with conn.cursor() as cursor:
        cursor.execute(query)
        ids = [row[0] for row in cursor.fetchall()]
    return ids

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

def perform_experiment(conn, csv_dir_path):
    for i in range(5):  # Repeat  times
        csv_files = sorted(glob(os.path.join(csv_dir_path, '*.csv')))
        print(f"Found CSVs: {csv_files}")
        for csv_file in csv_files:
            for data in load_data_from_csv(csv_file):
                insert_data(conn, data)

            # Fetch inserted ids
            inserted_ids = fetch_inserted_ids(conn)
            quarter = len(inserted_ids) // 4
            ids_to_delete = random.sample(inserted_ids, quarter)

            # Perform deletion
            delete_data(conn, ids_to_delete)

def main():
    time.sleep(5)
    conn = create_connection()

    try:
        for csv_dir_path in CSV_DIR_PATHS:
            perform_experiment(conn, csv_dir_path)
    except Exception as e:
        print(f"Error: {e}")
    finally:
        conn.close()
        print("Database connection closed.")

if __name__ == "__main__":
    main()
