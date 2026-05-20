import base64
import os
from typing import Tuple
import numpy as np
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC
from tensorflow.keras.applications import VGG19, DenseNet121
from tensorflow.keras.applications.vgg19 import preprocess_input as vgg_pre
from tensorflow.keras.applications.densenet import preprocess_input as dense_pre
from tensorflow.keras.preprocessing import image as keras_image
from preprocessing.pipeline import preprocess_image
from utils.file_paths import ensure_artifacts_dir


class Trainer:
    def __init__(self) -> None:
        self.vgg = VGG19(weights="imagenet", include_top=False, pooling="avg")
        self.densenet = DenseNet121(weights="imagenet", include_top=False, pooling="avg")

    def _extract_features(self, img_path: str) -> np.ndarray:
        img = keras_image.load_img(img_path, target_size=(224, 224), color_mode="rgb")
        arr = keras_image.img_to_array(img)
        arr = np.expand_dims(arr, axis=0)
        vgg_feat = self.vgg.predict(vgg_pre(arr), verbose=0).flatten()
        dense_feat = self.densenet.predict(dense_pre(arr), verbose=0).flatten()
        return np.concatenate([vgg_feat, dense_feat])

    def _load_images(self, root: str) -> Tuple[np.ndarray, np.ndarray]:
        features = []
        labels = []
        for label_name, label_value in [("Non-Cancer", 0), ("Cancer", 1)]:
            folder = os.path.join(root, label_name)
            for fname in os.listdir(folder):
                if not fname.lower().endswith((".png", ".jpg", ".jpeg")):
                    continue
                path = os.path.join(folder, fname)
                preprocessed = preprocess_image(None, self._to_base64(path))
                if not preprocessed:
                    continue
                feat = self._extract_features(preprocessed)
                features.append(feat)
                labels.append(label_value)
        return np.array(features), np.array(labels)

    def _to_base64(self, path: str) -> str:
        with open(path, "rb") as f:
            encoded = base64.b64encode(f.read()).decode("utf-8")
        return "data:image/png;base64," + encoded

    def train(self, dataset_dir: str) -> None:
        features, labels = self._load_images(dataset_dir)
        scaler = StandardScaler()
        features_scaled = scaler.fit_transform(features)
        pca = PCA(n_components=min(100, features_scaled.shape[1]))
        features_pca = pca.fit_transform(features_scaled)

        svm = SVC(kernel="rbf", probability=True)
        svm.fit(features_pca, labels)

        artifacts_dir = ensure_artifacts_dir()
        np.save(os.path.join(artifacts_dir, "scaler.npy"), scaler, allow_pickle=True)
        np.save(os.path.join(artifacts_dir, "pca.npy"), pca, allow_pickle=True)
        np.save(os.path.join(artifacts_dir, "svm.npy"), svm, allow_pickle=True)
