#!/bin/bash
set -e

# Parker's Sandbox Game Engine - Release Script
# Usage: ./release.sh v1.0.0

VERSION=${1}

if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Usage: $0 <version>"
  echo "Version format: v1.0.0"
  exit 1
fi

REGISTRY="ghcr.io"
IMAGE_NAME="parkers-sandbox-game-engine"
FULL_IMAGE="$REGISTRY/$IMAGE_NAME"

echo "📦 Building release for $VERSION..."

# Build image
docker build -t $FULL_IMAGE:$VERSION -t $FULL_IMAGE:latest .

# Login to registry (assumes credentials are set up)
echo "🔐 Logging in to registry..."
# docker login $REGISTRY

# Push tags
echo "📤 Pushing to registry..."
docker push $FULL_IMAGE:$VERSION
docker push $FULL_IMAGE:latest

# Create git tag
echo "🏷️  Creating git tag..."
git tag -a $VERSION -m "Release $VERSION"
git push origin $VERSION

echo "✅ Release $VERSION complete!"
echo "   Image: $FULL_IMAGE:$VERSION"
