import base64
import os
from typing import Optional
import numpy as np
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC
from tensorflow.keras.applications import VGG19, DenseNet121
from tensorflow.keras.applications.vgg19 import preprocess_input as vgg_pre
from tensorflow.keras.applications.densenet import preprocess_input as dense_pre
from tensorflow.keras.preprocessing import image as keras_image
from app.config import get_settings
from models.schemas import PredictionRequest, PredictionResult
from preprocessing.pipeline import preprocess_image
from explainability.gradcam import GradCamGenerator
from explainability.shap_explain import ShapExplainer
from services.storage import upload_bytes_image


class InferenceService:
    def __init__(self) -> None:
        settings = get_settings()
        self.artifacts_dir = settings.artifacts_dir
        self.scaler: Optional[StandardScaler] = None
        self.pca: Optional[PCA] = None
        self.svm: Optional[SVC] = None
        self.vgg = VGG19(weights="imagenet", include_top=False, pooling="avg")
        self.densenet = DenseNet121(weights="imagenet", include_top=False, pooling="avg")
        self.gradcam = GradCamGenerator(self.vgg, last_conv_layer_name="block5_conv4")
        self.shap = ShapExplainer()
        self._load_artifacts()

    def _load_artifacts(self) -> None:
        scaler_path = os.path.join(self.artifacts_dir, "scaler.npy")
        pca_path = os.path.join(self.artifacts_dir, "pca.npy")
        svm_path = os.path.join(self.artifacts_dir, "svm.npy")

        if os.path.exists(scaler_path):
            self.scaler = np.load(scaler_path, allow_pickle=True).item()
        if os.path.exists(pca_path):
            self.pca = np.load(pca_path, allow_pickle=True).item()
        if os.path.exists(svm_path):
            self.svm = np.load(svm_path, allow_pickle=True).item()
        if self.svm and self.scaler and self.pca:
            self.shap = ShapExplainer(self.svm, self.scaler, self.pca)

    def _extract_features(self, img_path: str) -> np.ndarray:
        img = keras_image.load_img(img_path, target_size=(224, 224), color_mode="rgb")
        arr = keras_image.img_to_array(img)
        arr = np.expand_dims(arr, axis=0)
        vgg_feat = self.vgg.predict(vgg_pre(arr), verbose=0).flatten()
        dense_feat = self.densenet.predict(dense_pre(arr), verbose=0).flatten()
        return np.concatenate([vgg_feat, dense_feat])

    def _predict_with_svm(self, features: np.ndarray) -> tuple[str, float, float]:
        if self.scaler is None or self.pca is None or self.svm is None:
            raise RuntimeError("Model artifacts are not available. Train and export artifacts first.")

        scaled = self.scaler.transform([features])
        reduced = self.pca.transform(scaled)
        proba = self.svm.predict_proba(reduced)[0][1]
        label = "MALIGNANT" if proba >= 0.5 else "BENIGN"
        confidence = float(max(proba, 1 - proba))
        return label, confidence, float(proba)

    def predict(self, payload: PredictionRequest) -> Optional[PredictionResult]:
        img_path = preprocess_image(payload.image_url, payload.image_base64)
        if not img_path:
            return None

        features = self._extract_features(img_path)
        label, confidence, proba = self._predict_with_svm(features)
        risk = "HIGH" if proba >= 0.7 else "MEDIUM" if proba >= 0.4 else "LOW"

        gradcam_path = self.gradcam.generate(img_path)
        gradcam_url = None
        if gradcam_path:
            with open(gradcam_path, "rb") as handle:
                result = upload_bytes_image(handle.read())
                gradcam_url = result.get("secure_url") if result else None

        shap_values = self.shap.explain(features)

        return PredictionResult(
            label=label,
            confidence=confidence,
            probability=proba,
            risk_level=risk,
            processing_time_ms=0,
            gradcam_url=gradcam_url,
            shap_values=shap_values,
        )
