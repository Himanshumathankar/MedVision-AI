from typing import List, Optional
import shap
import numpy as np


class ShapExplainer:
    def __init__(self, model=None, scaler=None, pca=None) -> None:
        self.model = model
        self.scaler = scaler
        self.pca = pca
        self.background = np.zeros((1, 1))

    def _predict(self, data: np.ndarray) -> np.ndarray:
        if self.scaler is None or self.pca is None or self.model is None:
            return np.zeros((data.shape[0], 1))
        scaled = self.scaler.transform(data)
        reduced = self.pca.transform(scaled)
        return self.model.predict_proba(reduced)

    def explain(self, features: np.ndarray) -> List[float]:
        features = np.array(features).reshape(1, -1)
        if self.background.shape[1] != features.shape[1]:
            self.background = np.zeros((1, features.shape[1]))
        explainer = shap.KernelExplainer(self._predict, self.background)
        values = explainer.shap_values(features, nsamples=50)
        if isinstance(values, list):
            return values[1].flatten().tolist() if len(values) > 1 else values[0].flatten().tolist()
        return values.flatten().tolist()
