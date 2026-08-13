# Use a minimal, secure base image
FROM python:3.11-slim-bookworm

# Force update of all OS-level Debian packages to clear OS CVEs
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create a non-root user for security
RUN adduser --disabled-password --gecos "" appuser

WORKDIR /app

# --- The Virtual Environment Patch ---
# Create a venv and ensure our PATH uses the venv's python and pip
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY requirements.txt .

# Install dependencies strictly into the venv
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
    
COPY main.py .

# Change ownership of the venv and app files to our non-root user
RUN chown -R appuser:appuser /app /opt/venv

# Enforce non-root execution
USER appuser

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]