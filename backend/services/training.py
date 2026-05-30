import logging
import os
from concurrent.futures import ThreadPoolExecutor
from typing import List, Tuple
import numpy as np
import tensorflow as tf
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
    def __init__(self, batch_size: int = 16) -> None:
        self.batch_size = batch_size
        self._configure_gpu()
        self.vgg = VGG19(weights="imagenet", include_top=False, pooling="avg")
        self.densenet = DenseNet121(weights="imagenet", include_top=False, pooling="avg")

    def _configure_gpu(self) -> None:
        gpus = tf.config.list_physical_devices("GPU")
        if gpus:
            logging.info("Using GPU devices: %s", ", ".join(g.name for g in gpus))
            try:
                tf.keras.mixed_precision.set_global_policy("mixed_float16")
                logging.info("Mixed precision enabled")
            except Exception:
                logging.exception("Failed to enable mixed precision")
        else:
            logging.info("No GPU detected, using CPU")
        for gpu in gpus:
            try:
                tf.config.experimental.set_memory_growth(gpu, True)
            except Exception:
                pass

    def _extract_features_batch(self, img_paths: List[str]) -> np.ndarray:
        images = []
        for img_path in img_paths:
            img = keras_image.load_img(img_path, target_size=(224, 224), color_mode="rgb")
            images.append(keras_image.img_to_array(img))
        arr = np.stack(images, axis=0).astype(np.float32)
        vgg_feat = self.vgg.predict(vgg_pre(arr), verbose=0)
        dense_feat = self.densenet.predict(dense_pre(arr), verbose=0)
        return np.concatenate([vgg_feat, dense_feat], axis=1)

    def _load_images(self, roots: List[str]) -> Tuple[np.ndarray, np.ndarray]:
        samples = []
        for root in roots:
            for label_name, label_value in [("Non-Cancer", 0), ("Cancer", 1)]:
                folder = os.path.join(root, label_name)
                for fname in os.listdir(folder):
                    if not fname.lower().endswith((".png", ".jpg", ".jpeg")):
                        continue
                    samples.append((os.path.join(folder, fname), label_value))

        def _preprocess(entry: tuple[str, int]) -> tuple[str, int] | None:
            path, label = entry
            preprocessed = preprocess_image(path, None)
            if not preprocessed:
                return None
            return preprocessed, label

        processed = []
        with ThreadPoolExecutor(max_workers=os.cpu_count() or 4) as executor:
            for result in executor.map(_preprocess, samples):
                if result:
                    processed.append(result)

        if not processed:
            return np.array([]), np.array([])

        features = []
        labels = []
        for i in range(0, len(processed), self.batch_size):
            batch = processed[i : i + self.batch_size]
            batch_paths = [item[0] for item in batch]
            batch_labels = [item[1] for item in batch]
            feats = self._extract_features_batch(batch_paths)
            features.append(feats)
            labels.extend(batch_labels)

        logging.info("Loaded %d samples from %d dataset roots", len(labels), len(roots))
        return np.vstack(features), np.array(labels)

    def train(self, dataset_dirs: List[str]) -> None:
        features, labels = self._load_images(dataset_dirs)
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
