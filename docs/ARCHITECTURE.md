# Architecture

MedVision AI uses a modular, clean architecture with feature-based Flutter UI and a FastAPI backend.

## Backend

- preprocessing: CLAHE, homomorphic filtering, ACO-driven band decomposition
- models: VGG19 + DenseNet121 feature extraction
- inference: PCA + SVM classification
- explainability: Grad-CAM and SHAP

## Frontend

- Riverpod state management
- GoRouter navigation
- Glassmorphism UI with animated gradients
