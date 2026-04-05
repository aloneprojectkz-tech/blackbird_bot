# ──────────────────────────────────────────────────────────────────────────────
# Blackbird OSINT — Telegram Bot + Web App
# ──────────────────────────────────────────────────────────────────────────────
FROM python:3.12-slim

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy entire project
COPY . .

# Create necessary directories
RUN mkdir -p logs data

# Default env values (override via docker-compose or -e flags)
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    WEB_PORT=5000 \
    RUN_MODE=both

# Expose web port
EXPOSE 5000

# Healthcheck for web app
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD curl -sf http://localhost:5000/api/health || exit 1

# Entrypoint
CMD ["python", "entrypoint.py"]
