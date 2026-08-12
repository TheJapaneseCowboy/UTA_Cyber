# UT Austin ISO Challenge: Secure CI/CD Pipeline

## Overview
This repository contains a lightweight Python FastAPI application demonstrating a "Secure by Design" approach. The goal of this architecture is to enforce security checks before any code is allowed to reach a deployable state.

## The Application
I used the FastAPI to build a simple REST API (Hook 'em!). To minimize the attack surface, the `Dockerfile` uses a minimal Debian base image (`slim-bookworm`) and explicitly drops root privileges by running the process as a dedicated non-root user (`appuser`).

## Pipeline Architecture
The CI/CD pipeline (`.github/workflows/secure-pipeline.yml`) is split into two primary jobs:

1. **CodeQL Static Analysis (SAST):** Scans the raw Python source code for known vulnerability patterns, injection flaws, and anti-patterns. This is the semantic type of work, workflows much used.
2. **Build, Scan, & Publish:** - Builds the Docker image locally.
   - Runs **Trivy** to scan the compiled container image for OS-level and dependency CVEs. The pipeline will fail, if any `HIGH` or `CRITICAL` vulnerabilities are detected. Once all security gates passed, pipeline deploys the image to the Github Container Registry. 

## Security Guardrails Implemented
* **Least Privilege IAM:** The workflow utilizes the `permissions` block to default to `contents: read`. Elevated permissions (like `packages: write` for GHCR) are scoped explicitly to the jobs that need them.
* **Fail-Closed Design:** The build job `needs: sast-codeql`. If the static code analysis fails, the container is never built or pushed.
* **Non-Root Container:** The Dockerfile prevents privilege escalation attacks by enforcing execution via a restricted user.

## How to Run / Reproduce
1. Fork or clone this repository.
2. Trigger the pipeline by opening a Pull Request or pushing a commit to the `main` branch.
3. To pull the deployed container: 
   `docker pull ghcr.io/[YOUR_GITHUB_USERNAME]/[REPO_NAME]/secure-api:latest`
