# MedVision AI

MedVision AI is a full-stack medical imaging application with a FastAPI backend and a Flutter frontend. It supports breast cancer prediction with explainability (Grad-CAM and SHAP), report generation, and authenticated user history.

## Features

- Image upload and storage
- Breast cancer prediction with confidence and risk levels
- Explainability outputs (Grad-CAM heatmaps and SHAP values)
- PDF report generation
- Authenticated history and profile endpoints
- Flutter app for Android, iOS, web, and desktop

## Architecture

- Backend: FastAPI + SQLModel + Postgres + Redis
- ML pipeline: preprocessing (CLAHE, homomorphic filtering, ACO/EWT), VGG19 + DenseNet121 features, PCA + SVM classifier
- Explainability: Grad-CAM (CNN heatmaps) and SHAP (feature attribution)
- Frontend: Flutter with Riverpod state management and GoRouter

## Tech Stack

- Backend: FastAPI, SQLModel, PostgreSQL, Redis, TensorFlow, scikit-learn
- Frontend: Flutter, Riverpod, Firebase Auth
- Infra: Docker, Docker Compose

## Repo Layout

- backend: FastAPI API and ML services
- frontend: Flutter app
- docs: Detailed docs (architecture, setup, deployment, API)
- docker: Docker Compose for local backend stack
- Firebase_files: Firebase platform config files

## Prerequisites

### Core

- Python 3.10 or 3.11
- Flutter (stable channel)
- Git

### Platform-specific

- Android: Android Studio + SDKs + emulator/device
- iOS: Xcode (macOS only)
- Web: Chrome
- Docker (optional, for Postgres/Redis)

## Quickstart (Local)

### 1) Backend setup

From the repo root:

#### Windows (PowerShell)

```powershell
python -m venv backend\.venv
backend\.venv\Scripts\Activate.ps1
pip install -r backend\requirements.txt
```

#### macOS / Linux

```bash
python3 -m venv backend/.venv
source backend/.venv/bin/activate
pip install -r backend/requirements.txt
```

### 2) Configure environment variables

Copy the example file and update values:

```powershell
Copy-Item backend\.env.example backend\.env
```

```bash
cp backend/.env.example backend/.env
```

Required variables (see backend/.env.example):

- APP_ENV, LOG_LEVEL
- JWT_SECRET, JWT_ISSUER, JWT_AUDIENCE, JWT_EXP_MINUTES
- DATABASE_URL
- REDIS_URL
- CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET
- FIREBASE_PROJECT_ID, FIREBASE_CREDENTIALS_PATH
- ARTIFACTS_DIR

Notes:

- CLOUDINARY_* is required for image and PDF storage.
- FIREBASE_CREDENTIALS_PATH should point to a Firebase Admin SDK JSON file.

### 3) Start Postgres and Redis

Option A: Docker (recommended)

```powershell
Set-Location docker
docker compose up -d
```

```bash
cd docker
docker compose up -d
```

Option B: Use your own Postgres and Redis and update DATABASE_URL and REDIS_URL in backend/.env.

### 4) Run the backend

```powershell
Set-Location backend
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

```bash
cd backend
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

API docs:

- Swagger: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### 5) Frontend setup

```powershell
Set-Location frontend
flutter pub get
```

```bash
cd frontend
flutter pub get
```

### 6) Firebase configuration

- Place Android config in frontend/android/app/google-services.json
- Place iOS config in frontend/ios/Runner/GoogleService-Info.plist
- The repo includes copies under Firebase_files/; replace them with your own project files if needed.

### 7) Run the Flutter app

#### Android (emulator/device)

```powershell
Set-Location frontend
flutter run -d android
```

#### iOS (simulator, macOS only)

```bash
cd frontend
flutter run -d ios
```

#### Web

```powershell
Set-Location frontend
flutter run -d chrome
```

### 8) Set API base URL in the app

The Flutter app uses a hardcoded base URL. Update it to match your backend host for devices and emulators.

- File: [frontend/lib/core/providers/app_providers.dart](frontend/lib/core/providers/app_providers.dart#L22)
- Example values:
  - Android emulator: http://10.0.2.2:8000
  - iOS simulator: http://localhost:8000
  - Physical device: http://<your-lan-ip>:8000

## ML Artifacts and Training

Inference requires SVM artifacts in the artifacts directory (scaler.npy, pca.npy, svm.npy).

Train artifacts:

```powershell
Set-Location backend
python scripts\train_breast_cancer.py --dataset <path-to-dataset>
```

Dataset layout:

```
<dataset-root>/
  Cancer/
    img1.png
  Non-Cancer/
    img2.png
```

Artifacts are saved to ARTIFACTS_DIR (default: backend/artifacts).

## Tests

### Backend

```powershell
pytest backend/tests
```

### Frontend

```powershell
Set-Location frontend
flutter test
```

## Docker (Backend stack)

Run the backend with Postgres and Redis:

```powershell
Set-Location docker
docker compose up --build
```

Update backend/.env with real secrets, then run the API container:

```powershell
Set-Location docker
docker compose up -d api
```

## API Endpoints (Summary)

- POST /auth/exchange
- POST /upload/image
- POST /predict/breast-cancer
- POST /report/generate
- GET /history
- GET /profile

For detailed schemas, see docs/API.md.

## Troubleshooting

- Backend fails to start: verify backend/.env and running Postgres/Redis.
- Prediction error about missing artifacts: run training to generate scaler/pca/svm files.
- Flutter auth issues: confirm Firebase files and enable Email/Google/Apple providers in Firebase console.
- Android emulator cannot reach backend: use http://10.0.2.2:8000.

## Docs

- docs/SETUP.md
- docs/ARCHITECTURE.md
- docs/DEPLOYMENT.md
- docs/SECURITY.md
- docs/TESTING.md
