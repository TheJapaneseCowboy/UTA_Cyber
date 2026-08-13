# Use a minimal, secure base image
FROM python:3.11-slim-bookworm

# Force update of all OS-level Debian packages to clear OS CVEs
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create a non-root user for security
RUN adduser --disabled-password --gecos "" appuser

WORKDIR /app

COPY requirements.txt .

# THE SURGICAL EXCISION: 
# 1. Uninstall the base packages. 
# 2. Force-delete any ghost metadata files Trivy is reading. 
# 3. Install the secure versions.
# 4. TODO: re-write this part. . . 
RUN pip uninstall -y setuptools msgpack wheel || true && \
    rm -rf /usr/local/lib/python3.11/site-packages/setuptools* \
           /usr/local/lib/python3.11/site-packages/msgpack* && \
    pip install --no-cache-dir --upgrade pip "setuptools>=78.1.1" "msgpack>=1.2.1" wheel && \
    pip install --no-cache-dir -r requirements.txt

COPY main.py .

# Enforce non-root execution
USER appuser

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]