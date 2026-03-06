# ── Build stage ──────────────────────────────────────────────
FROM python:3.11-slim AS builder

WORKDIR /build

# Patch vulnerabilities
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Runtime stage ────────────────────────────────────────────
FROM python:3.11-slim

LABEL org.opencontainers.image.title="parkers-sandbox-game-engine"
LABEL org.opencontainers.image.description="Game Model API and ADK endpoint"

WORKDIR /app

# Patch vulnerabilities
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# Copy installed packages from builder
COPY --from=builder /install /usr/local

COPY . .

EXPOSE 8200

HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8200/engine/health')" || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8200"]
