# === Stage 1: Build stage ===
FROM python:3.12-slim AS builder

# Install build dependencies (minimal)
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements and install in isolated location
COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install --prefix=/install --no-cache-dir -r requirements.txt

# === Stage 2: Runtime stage ===
FROM python:3.12-slim

# Create non-root user
RUN addgroup --system app && adduser --system --ingroup app app \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy installed Python packages from builder
COPY --from=builder /install /usr/local

# Copy app source
COPY app ./app

# Switch to non-root user
USER app

# Expose port
EXPOSE 8000

# Start app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
