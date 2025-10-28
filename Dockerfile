# Use official lightweight Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY app ./app

# Expose port (Cloud Run uses PORT env var; default 8080)
ENV PORT 8080

# Run Gunicorn with Uvicorn workers (adjust workers as needed)
# --bind 0.0.0.0:$PORT to listen on the container port
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "app.main:app", "--bind", "0.0.0.0:8080"]
