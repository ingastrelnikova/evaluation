import os
import psycopg2
import pandas as pd
import time
import sys
from prometheus_client import start_http_server, Gauge, Histogram
from dotenv import load_dotenv

# load parameters from .env
load_dotenv()

# parameters for database connection from .env
dbname = os.getenv('DB_NAME')
user = os.getenv('DB_USER')
password = os.getenv('DB_PASSWORD')
host = os.getenv('DB_HOST')
port = os.getenv('DB_PORT')

def create_histogram(max_bucket_value):
    # Create buckets dynamically from 1 up to the maximum value observed
    buckets = list(range(1, max_bucket_value + 1))
    return Histogram('equivalence_class_size', 'Distribution of equivalence class sizes', buckets=buckets)

# Prometheus metrics
K_ANONYMITY_GAUGE = Gauge('k_anonymity', 'Minimum k-anonymity value observed')
DATA_VOLUME_GAUGE = Gauge('data_volume', 'Number of records processed')
K_VOLUME_RATIO_GAUGE = Gauge('k_volume_ratio', 'Ratio of k-anonymity to data volume')
AVG_K_ANONYMITY_GAUGE = Gauge('avg_k_anonymity', 'Average k-anonymity over the last minute')
K_ANONYMITY_FLUCTUATION_RATE = Gauge('k_anonymity_fluctuation_rate', 'Percentage change in k-anonymity')
MAX_DELETIONS_TO_DEGRADE = Gauge('max_deletions_to_degrade', 'Maximum deletions to degrade k-anonymity')
EQUIVALENCE_CLASS_HISTOGRAM = create_histogram(1000)

def update_histogram(data):
    global EQUIVALENCE_CLASS_HISTOGRAM
    max_value = data['num_of_elements'].max()

    # Recreate the histogram if new data exceeds current bucket limits
    if max_value > EQUIVALENCE_CLASS_HISTOGRAM._upper_bounds[-1]:
        EQUIVALENCE_CLASS_HISTOGRAM = create_histogram(max_value)

    for _, row in data.iterrows():
        num_of_elements = row['num_of_elements']
        num_of_classes = row['num_of_classes']
        for _ in range(num_of_classes):
            EQUIVALENCE_CLASS_HISTOGRAM.observe(num_of_elements)


# method to connect to the database
def connect_to_db():
    try:
        conn = psycopg2.connect(
            dbname=dbname,
            user=user,
            password=password,
            host=host,
            port=port
        )
        # print("Connected")
        sys.stdout.flush()
        return conn
    except psycopg2.Error as e:
        # print(f"Error: {e}")
        sys.stdout.flush()
        return None

# method to get the data from the database
def fetch_data(conn):
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT zip_code, anonymized_date_of_birth FROM anonymized_patients;")
        rows = cursor.fetchall()
        sys.stdout.flush()
        return rows
    except psycopg2.Error as e:
        print(f"Error: {e}")
        sys.stdout.flush()
        return []
    finally:
        cursor.close()



# method to calculate k anonymity
def calculate_k_anonymity(df):
    unique_groups = df.groupby(['zip_code', 'date_of_birth']).size().reset_index(name='num_elements')
    k_anonymity_value = unique_groups['num_elements'].min()
    return k_anonymity_value, len(df)

# method to get the anonymity classes
def calculate_anonymity_sets(df):
    unique_groups = df.groupby(['zip_code', 'date_of_birth']).size().reset_index(name='num_elements')
    anonymity_sets_counts = unique_groups['num_elements'].value_counts().reset_index()
    anonymity_sets_counts.columns = ['num_of_elements', 'num_of_classes']
    return anonymity_sets_counts

# method to calculate k anon fluctuation rate
def calculate_k_anonymity_fluctuation_rate(current_k, previous_k):
    print(current_k)
    print(previous_k)
    if previous_k == 0.0:
        return 0
    return ((current_k - previous_k) / previous_k) * 100

# method to calculate max deletions to degrade
def calculate_max_deletions_to_degrade(equivalence_class_counts):

    # add the check for empty

    min_count = equivalence_class_counts['num_of_elements'].min()
    total_deletions = 0

    for index, row in equivalence_class_counts.iterrows():
        total_deletions += (row['num_of_elements'] - min_count) * row['num_of_classes']

    return total_deletions + 1

def main():
    iteration = 0
    previous_k_anonymity = 0
    k_anonymity_values = []

    # server start to expose the metrics
    start_http_server(9290)
    sys.stdout.flush()
    while True:
        print(f"Iteration {iteration}")
        sys.stdout.flush()
        iteration += 1
        conn = connect_to_db()
        if conn:
            records = fetch_data(conn)
            if records:
                df = pd.DataFrame(records, columns=['zip_code', 'date_of_birth'])

                if not df.empty:
                    k_anonymity_value, num_records = calculate_k_anonymity(df)

                    latest_k_value = k_anonymity_value
                    latest_volume_value = num_records
                    k_volume_ratio = latest_k_value / latest_volume_value if latest_volume_value > 0 else 0
                    k_anonymity_fluctuation_rate = calculate_k_anonymity_fluctuation_rate(latest_k_value, previous_k_anonymity)
                    previous_k_anonymity = latest_k_value

                    anonymity_sets_counts = calculate_anonymity_sets(df)
                    max_deletions_to_degrade = calculate_max_deletions_to_degrade(anonymity_sets_counts)

                    # print metrics for debugging
                    print(f"Collected Metrics: k-anonymity: {latest_k_value}, data volume: {latest_volume_value}, k/volume ratio: {k_volume_ratio}, k-anonymity fluctuation rate: {k_anonymity_fluctuation_rate}, max deletions to degrade: {max_deletions_to_degrade}")
                    sys.stdout.flush()

                    # update Prometheus
                    K_ANONYMITY_GAUGE.set(latest_k_value)
                    DATA_VOLUME_GAUGE.set(latest_volume_value)
                    K_VOLUME_RATIO_GAUGE.set(k_volume_ratio)
                    K_ANONYMITY_FLUCTUATION_RATE.set(k_anonymity_fluctuation_rate)
                    MAX_DELETIONS_TO_DEGRADE.set(max_deletions_to_degrade)

                    # k-anonymity values for average k anonymity calculation
                    k_anonymity_values.append(latest_k_value)
                    if len(k_anonymity_values) > 6:
                        k_anonymity_values.pop(0)

                    avg_k_value = sum(k_anonymity_values) / len(k_anonymity_values)
                    AVG_K_ANONYMITY_GAUGE.set(avg_k_value)

                    sys.stdout.flush()

                    print("Anonymity sets:")
                    print(anonymity_sets_counts)

                    update_histogram(anonymity_sets_counts)

                    for index, row in anonymity_sets_counts.iterrows():
                        # EQUIVALENCE_CLASS_HISTOGRAM.observe(row['num_of_elements'])
                        print(f"Anonymity set size: {row['num_of_elements']}, count: {row['num_of_classes']}")
                        sys.stdout.flush()
            else:
                # set metrics to 0 if no records
                K_ANONYMITY_GAUGE.set(0)
                DATA_VOLUME_GAUGE.set(0)
                K_VOLUME_RATIO_GAUGE.set(0)
                AVG_K_ANONYMITY_GAUGE.set(0)
                K_ANONYMITY_FLUCTUATION_RATE.set(0)
                MAX_DELETIONS_TO_DEGRADE.set(0)
                sys.stdout.flush()
                print("no records")

            conn.close()
            sys.stdout.flush()
        else:
            sys.stdout.flush()
        sys.stdout.flush()
        time.sleep(10)

if __name__ == "__main__":
    sys.stdout.flush()
    main()
