from fastapi import FastAPI
import os

app = FastAPI(title="Secure API API", version="1.0.0")

@app.get("/")
def read_root():
    # Demonstrating a clean, stateless endpoint
    environment = os.getenv("ENVIRONMENT", "production")
    return {"status": "healthy", "environment": environment, "message": "Hook 'em, Longhorns!"}

@app.get("/healthz")
def health_check():
    return {"status": "ok"}