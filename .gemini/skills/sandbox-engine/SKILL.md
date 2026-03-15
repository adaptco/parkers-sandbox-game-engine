---
name: sandbox-engine
description: Specialized workflows for the Parker's Sandbox Game Engine. Use when developing, testing, or deploying the FastAPI-based Game Model Simulator and MCP integration.
---

# Parker's Sandbox Game Engine Skill

Specialized workflows and domain expertise for the Sandbox Game Engine.

## Project Overview
- **Framework**: FastAPI
- **Port**: 8200
- **Primary Logic**: `main.py`
- **MCP Integration**: Designed for backend API for Game Model Simulator and MCP ADK.

## Core Workflows

### 1. Local Development
- **Run Server**: `python main.py` or `uvicorn main:app --port 8200 --reload`
- **Health Check**: `curl http://localhost:8200/engine/health`
- **Simulate Tick**: 
  ```bash
  curl -X POST http://localhost:8200/engine/tick -H "Content-Type: application/json" -d '{"world_seed": 123, "active_entities": 10, "physics_tick_rate": 60.0}'
  ```

### 2. GitHub App Integration (ID: 2690725)
- **Publish Endpoint**: `/app/publish`
- **Requirement**: Proper JWT authentication is required for real environments.
- **Action**: Use for publishing game engine releases.

### 3. Deployment
- **Staging/Prod**: Use `./deploy.sh [stage|prod]`
- **Docker**: The project uses `docker-compose.yml` and `docker-compose.prod.yml`.
- **CI/CD**: GitHub Actions workflows are located in `.github/workflows/`.

## Coding Standards
- **Pydantic**: Use `BaseModel` for all request/response schemas.
- **Logging**: Use the `parkers-sandbox` logger.
- **Error Handling**: Raise `HTTPException` for API errors.

## MCP Integration
- This engine serves as a backend for MCP ADK components.
- Ensure any new endpoints follow the `GameState` or `PublishRequest` patterns.
