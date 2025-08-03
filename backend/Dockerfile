# Use Python 3.10 slim image for smaller size
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_TIMEOUT=1000

# Set work directory
WORKDIR /app

# Install system dependencies required for your ML libraries
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    build-essential \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies in smaller chunks to avoid timeouts
RUN pip install --default-timeout=1000 --no-cache-dir fastapi uvicorn[standard] pydantic
RUN pip install --default-timeout=1000 --no-cache-dir numpy pandas scikit-learn
RUN pip install --default-timeout=1000 --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu
RUN pip install --default-timeout=1000 --no-cache-dir sentence-transformers spacy rapidfuzz
RUN pip install --default-timeout=1000 --no-cache-dir -r requirements.txt

# Download spaCy model (since it's referenced in requirements)
RUN python -m spacy download en_core_web_sm

# Copy the application code
COPY . .

# Create a non-root user for security
RUN useradd --create-home --shell /bin/bash app && chown -R app:app /app
USER app

# Expose the port that FastAPI will run on
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Command to run the application
# Using uvicorn with production settings for Cloud Run
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080", "--workers", "1"]
