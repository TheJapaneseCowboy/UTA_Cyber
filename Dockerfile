# Use a minimal, secure base image
FROM python:3.11-slim-bookworm

# PATCH 1: Force update of all OS-level Debian packages to clear Trivy CVEs
# We run apt-get upgrade and immediately clear the cache to keep the image small
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# Prevent Python from writing pyc files and keep stdout unbuffered
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create a non-root user for security (Defends against privilege escalation)
RUN adduser --disabled-password --gecos "" appuser

WORKDIR /app

# Install dependencies first (leverages Docker cache)
COPY requirements.txt .

# PATCH 2: Upgrade pip itself to clear Python packaging CVEs, then install requirements
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY hookem_api.py .

# Enforce non-root execution
USER appuser

# Expose port and run
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]