#!/bin/bash

# Build and Push Docker Image Script for Cloud Run Deployment
# Usage: ./docker-build.sh [your-dockerhub-username] [image-name]

set -e

# Configuration
DOCKERHUB_USERNAME=${1:-"your-username"}
IMAGE_NAME=${2:-"grid-backend"}
TAG=${3:-"latest"}
FULL_IMAGE_NAME="$DOCKERHUB_USERNAME/$IMAGE_NAME:$TAG"

echo "🐋 Building Docker image for Cloud Run..."
echo "Image: $FULL_IMAGE_NAME"
echo "Platform: linux/amd64 (Cloud Run compatible)"

# Build the image with platform specification for Cloud Run
docker build --platform linux/amd64 -t $FULL_IMAGE_NAME .

echo "✅ Docker image built successfully!"

# Ask if user wants to push
read -p "Do you want to push to Docker Hub? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Pushing to Docker Hub..."
    docker push $FULL_IMAGE_NAME
    echo "✅ Image pushed successfully!"
    echo ""
    echo "📝 To deploy to Cloud Run, use:"
    echo "gcloud run deploy grid-backend \\"
    echo "  --image $FULL_IMAGE_NAME \\"
    echo "  --platform managed \\"
    echo "  --region us-central1 \\"
    echo "  --allow-unauthenticated \\"
    echo "  --port 8080 \\"
    echo "  --memory 2Gi \\"
    echo "  --cpu 1"
else
    echo "Image built but not pushed. To push later, run:"
    echo "docker push $FULL_IMAGE_NAME"
fi

echo ""
echo "🔧 To test locally:"
echo "docker run --platform linux/amd64 -p 8080:8080 $FULL_IMAGE_NAME"
