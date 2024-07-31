CREATE TABLE IF NOT EXISTS patients (
                                        id SERIAL PRIMARY KEY,
                                        name VARCHAR(100),
    date_of_birth VARCHAR(100),
    zip_code VARCHAR(10),
    gender VARCHAR(10),
    disease VARCHAR(100)
    );

CREATE TABLE IF NOT EXISTS anonymized_patients (
                                     anonymized_id SERIAL PRIMARY KEY,
                                     anonymized_date_of_birth VARCHAR(255),
                                     anonymized_name VARCHAR(255),
                                     disease VARCHAR(255),
                                     gender VARCHAR(50),
                                     zip_code VARCHAR(20)
);