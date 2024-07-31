FROM python:3.9

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY research_service.py app.py

CMD ["python", "app.py"]
