# Setup Guide

## Backend

1. Create a virtual environment.
2. Install requirements from backend/requirements.txt.
3. Copy backend/.env.example to backend/.env and fill credentials.
4. Run the API with uvicorn main:app --reload.

## Frontend

1. cd frontend
2. flutter pub get
3. flutter run

## Docker

Run docker-compose from the docker directory to start the backend, Postgres, and Redis.
