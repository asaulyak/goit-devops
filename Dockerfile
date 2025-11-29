FROM python:3.12-slim

WORKDIR /app

# Install system dependencies (optional but recommended for psycopg2, Pillow, etc.)
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Expose port Django will run on
EXPOSE 8000

# Run Django server
CMD ["python", "rid/manage.py", "runserver", "0.0.0.0:8000"]
