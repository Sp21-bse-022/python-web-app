# =========================
# Stage 1: Build environment
# =========================
FROM python:3.12-slim AS builder

# Set working directory
WORKDIR /app

# Install build dependencies (remove them in runtime later)
RUN apt-get update && apt-get install -y --no-install-recommends gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements and install inside a virtualenv
COPY requirements.txt .
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# Copy project code
COPY devops/ ./devops


# =========================
# Stage 2: Distroless runtime
# =========================
FROM gcr.io/distroless/python3-debian12

# Set working directory
WORKDIR /app/devops

# Copy venv and project from builder stage
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app/devops /app/devops

# Add virtualenv to PATH
ENV PATH="/opt/venv/bin:$PATH"

# Expose Django port
EXPOSE 8000

# Start Django development server
CMD ["manage.py", "runserver", "0.0.0.0:8000"]

