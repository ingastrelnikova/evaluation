FROM python:3.9-slim

ENV DB_HOST=research-db
ENV DB_PORT=5432
ENV DB_NAME=research
ENV DB_USER=test
ENV DB_PASSWORD=test
ENV CSV_DIR_PATH=/anonymized_patients

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir -r requirements.txt

ENV PYTHONUNBUFFERED=1

CMD ["python", "load_gen.py"]
