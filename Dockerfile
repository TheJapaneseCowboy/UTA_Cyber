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
    
# setuptools bundles vulnerable copies of jaraco.context and wheel in _vendor/,
# and pip can't upgrade those. Not needed at runtime anyway, so remove them
# from the venv and from the system python.
RUN pip uninstall -y setuptools wheel pip && \
    /usr/local/bin/python3 -m pip uninstall -y setuptools wheel pip

COPY main.py .

# Enforce non-root execution
USER appuser

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]