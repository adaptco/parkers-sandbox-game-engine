from fastapi.testclient import TestClient
from main import app
import logging

client = TestClient(app)

def test_engine_health():
    """
    Tests the health check endpoint.
    """
    response = client.get("/engine/health")
    assert response.status_code == 200
    assert response.json() == {"status": "online", "message": "Parker's Sandbox Game Engine is running."}

def test_execute_game_tick():
    """
    Tests the game tick simulation endpoint with valid data.
    """
    state_payload = {
        "world_seed": 12345,
        "active_entities": 100,
        "physics_tick_rate": 60.0
    }
    response = client.post("/engine/tick", json=state_payload)
    assert response.status_code == 200
    json_response = response.json()
    assert json_response["status"] == "computed"
    assert json_response["new_tick_rate"] == 60.0 * 1.01

def test_execute_game_tick_invalid_payload():
    """
    Tests the game tick endpoint with a missing field in the payload.
    """
    invalid_payload = {
        "world_seed": 12345,
        "active_entities": 100
        # Missing physics_tick_rate
    }
    response = client.post("/engine/tick", json=invalid_payload)
    assert response.status_code == 422  # Unprocessable Entity

def test_publish_game_engine_success():
    """
    Tests the publish endpoint with a valid payload and auth header.
    """
    publish_payload = {
        "version": "1.1.0",
        "release_notes": "New features and bug fixes."
    }
    headers = {"Authorization": "Bearer dummy-jwt-token"}
    response = client.post("/app/publish", json=publish_payload, headers=headers)
    assert response.status_code == 200
    json_response = response.json()
    assert json_response["status"] == "success"
    assert json_response["action"] == "published"
    assert json_response["version"] == "1.1.0"
    assert json_response["app_id"] == "2690725"

def test_publish_game_engine_no_auth():
    """
    Tests that the publish endpoint fails without an Authorization header.
    """
    publish_payload = {
        "version": "1.1.0",
        "release_notes": "This should fail."
    }
    response = client.post("/app/publish", json=publish_payload)
    assert response.status_code == 401
    assert response.json() == {"detail": "Missing Authorization header"}


def test_execute_game_tick_bad_data_type():
    """
    Tests the game tick endpoint with an incorrect data type in the payload.
    """
    invalid_payload = {
        "world_seed": 12345,
        "active_entities": "one hundred", # Should be an int
        "physics_tick_rate": 60.0
    }
    response = client.post("/engine/tick", json=invalid_payload)
    assert response.status_code == 422  # Unprocessable Entity


def test_execute_game_tick_logs_message(caplog):
    """
    Tests that the game tick endpoint logs the correct information.
    """
    state_payload = {
        "world_seed": 999,
        "active_entities": 50,
        "physics_tick_rate": 30.0
    }
    with caplog.at_level(logging.INFO):
        response = client.post("/engine/tick", json=state_payload)
        assert response.status_code == 200
    assert "Executing tick for world 999 with 50 entities." in caplog.text


def test_publish_game_engine_logs_message(caplog):
    """
    Tests that the publish endpoint logs the correct information.
    """
    publish_payload = {
        "version": "1.2.0",
        "release_notes": "Testing logging."
    }
    headers = {"Authorization": "Bearer dummy-jwt-token"}
    with caplog.at_level(logging.INFO):
        response = client.post("/app/publish", json=publish_payload, headers=headers)
        assert response.status_code == 200
    assert "Authenticating via GitHub App ID: 2690725" in caplog.text
    assert "Publishing release 1.2.0..." in caplog.text
