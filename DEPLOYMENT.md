# Deployment Configuration Guide

## Overview

This deployment pipeline automates testing, building, and deploying the Parker's Sandbox Game Engine using GitHub Actions and Docker.

## GitHub Actions Workflow

The pipeline (`.github/workflows/deploy.yml`) has three stages:

### 1. **Test Stage**
- Runs on every push and pull request
- Installs dependencies
- Tests health check endpoint
- Tests game engine tick endpoint

### 2. **Build & Push Stage**
- Runs after tests pass on `main` and `develop` branches
- Builds Docker image using multi-stage build
- Pushes to GitHub Container Registry (ghcr.io)
- Tags with branch, version, and commit SHA

### 3. **Deploy Stage**
- Runs after build on `main` branch only
- SSH deploys to production server
- Pulls latest image
- Restarts containers with docker compose
- Verifies health check

## Setup Instructions

### 1. Configure GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets and Variables → Actions):

- **`DEPLOY_HOST`**: Production server IP/hostname
- **`DEPLOY_USER`**: SSH user (e.g., `ubuntu`)
- **`DEPLOY_KEY`**: SSH private key (generate: `ssh-keygen -t ed25519`)
- **`DEPLOYMENT_URL`**: Full URL for health check (e.g., `your-server.com:8200`)

### 2. Configure Production Server

```bash
# SSH into production server
ssh ubuntu@your-server.com

# Create deployment directory
sudo mkdir -p /opt/sandbox-game-engine
sudo chown -R ubuntu:ubuntu /opt/sandbox-game-engine

# Clone repo or copy files
cd /opt/sandbox-game-engine
git clone https://github.com/your-username/your-repo.git .

# Create .env file
cat > .env << EOF
PYTHONUNBUFFERED=1
LOG_LEVEL=INFO
EOF
```

### 3. Enable Docker Pull Authentication

On production server, log in to GitHub Container Registry:

```bash
echo $GHCR_TOKEN | docker login ghcr.io -u your-username --password-stdin
```

Where `GHCR_TOKEN` is a GitHub Personal Access Token with `read:packages` scope.

## Local Deployment

Use the provided `deploy.sh` script for manual deployment:

```bash
# Development (builds from source)
./deploy.sh dev

# Staging (uses staging compose override)
./deploy.sh stage

# Production (uses production compose config)
./deploy.sh prod
```

## Release Process

Create a release with semantic versioning:

```bash
./release.sh v1.0.1
```

This will:
1. Build Docker image
2. Tag as `v1.0.1` and `latest`
3. Push to ghcr.io
4. Create git tag and push

## Continuous Integration Flow

```
Push to main/develop
         ↓
    Run Tests (pytest)
         ↓
  Build Docker Image (buildx)
         ↓
   Push to Registry (ghcr.io)
         ↓
  Deploy to Production (ssh)
         ↓
   Run Health Checks
```

## Monitoring

### Check deployment status:
```bash
# View GitHub Actions
https://github.com/your-username/your-repo/actions

# View production logs
docker compose logs -f web

# Check health
curl http://your-server.com:8200/engine/health
```

### Common issues:

**Image pull failed**: Ensure docker login is configured on production server
**Health check timeout**: Check firewall, ensure port 8200 is accessible
**SSH deployment fails**: Verify deploy key is added to GitHub secrets and authorized on server

## Rollback

To rollback to a previous version:

```bash
# On production server
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d

# Or manually specify image tag
docker pull ghcr.io/username/parkers-sandbox-game-engine:v1.0.0
```
