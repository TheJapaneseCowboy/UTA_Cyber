# Use a minimal, secure base image
FROM python:3.11-slim-bookworm

# Force update of all OS-level Debian packages to clear OS CVEs
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create a non-root user for security (Defends against privilege escalation)
RUN adduser --disabled-password --gecos "" appuser

WORKDIR /app

COPY requirements.txt .

# THE FINAL PATCH: 
# Explicitly force pip to overwrite the vulnerable base-image versions 
# with the exact fixed versions Trivy requested.
RUN pip install --no-cache-dir --upgrade pip "setuptools>=78.1.1" "msgpack>=1.2.1" wheel && \
    pip install --no-cache-dir -r requirements.txt

COPY hookem_api.py .

# Enforce non-root execution
USER appuser

# Expose port and run
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]