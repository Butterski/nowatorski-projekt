FROM python:3.9-slim as builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt -t /app/dependencies

FROM python:3.9-slim

WORKDIR /app
COPY --from=builder /app/dependencies /app/dependencies
ENV PYTHONPATH=/app/dependencies
COPY main.py .
COPY cleanup.py .

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]