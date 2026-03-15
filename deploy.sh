#!/bin/bash
set -e

# Parker's Sandbox Game Engine - Deployment Script
# Usage: ./deploy.sh [dev|stage|prod]

ENV=${1:-dev}
REGISTRY_URL="ghcr.io"
IMAGE_NAME="parkers-sandbox-game-engine"
PORT=8200

case $ENV in
  dev)
    echo "🔧 Deploying to Development..."
    docker compose up --build -d
    ;;
  stage)
    echo "🚀 Deploying to Staging..."
    docker compose -f docker-compose.yml -f docker-compose.stage.yml up -d
    ;;
  prod)
    echo "⚡ Deploying to Production..."
    docker compose -f docker-compose.prod.yml up -d
    ;;
  *)
    echo "Usage: $0 [dev|stage|prod]"
    exit 1
    ;;
esac

# Wait for container to be healthy
echo "⏳ Waiting for container to be healthy..."
for i in {1..30}; do
  if docker compose ps | grep -q "healthy"; then
    echo "✅ Container is healthy"
    break
  fi
  echo "  Waiting... ($i/30)"
  sleep 2
done

# Health check
echo "🔍 Running health check..."
HEALTH_URL="http://localhost:$PORT/engine/health"
if curl -f $HEALTH_URL > /dev/null 2>&1; then
  echo "✅ Health check passed"
  echo ""
  echo "📊 Deployment Summary:"
  docker compose ps
  echo ""
  echo "🌐 API available at: $HEALTH_URL"
else
  echo "❌ Health check failed"
  echo "📋 Logs:"
  docker compose logs --tail=50
  exit 1
fi
