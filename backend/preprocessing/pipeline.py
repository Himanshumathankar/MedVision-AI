import base64
import os
import tempfile
from typing import Optional
import cv2
import numpy as np
import requests
from preprocessing.clahe import apply_clahe
from preprocessing.homomorphic import homomorphic_filter
from preprocessing.aco_ewt import aco_ewt_decompose


def _decode_base64_image(data: str) -> Optional[str]:
    payload = data.split(",")[-1]
    binary = base64.b64decode(payload)
    fd, path = tempfile.mkstemp(suffix=".png")
    with os.fdopen(fd, "wb") as tmp:
        tmp.write(binary)
    return path


def _download_image(url: str) -> Optional[str]:
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        content_type = response.headers.get("Content-Type", "")
        suffix = ".png" if "png" in content_type else ".jpg"
        fd, path = tempfile.mkstemp(suffix=suffix)
        with os.fdopen(fd, "wb") as tmp:
            tmp.write(response.content)
        return path
    except Exception:
        return None


def preprocess_image(image_url: Optional[str], image_base64: Optional[str]) -> Optional[str]:
    if image_base64:
        img_path = _decode_base64_image(image_base64)
    elif image_url:
        if os.path.exists(image_url):
            img_path = image_url
        else:
            local_path = os.path.abspath(image_url)
            img_path = local_path if os.path.exists(local_path) else _download_image(image_url)
    else:
        return None

    if not img_path:
        return None

    img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        return None

    img = _auto_crop_black(img)
    img = cv2.resize(img, (512, 512))
    img = apply_clahe(img)
    img = homomorphic_filter(img)
    subbands = aco_ewt_decompose(img)
    enhanced = np.mean(np.stack(subbands, axis=0), axis=0)

    cv2.imwrite(img_path, enhanced)
    return img_path


def _auto_crop_black(image: np.ndarray, threshold: int = 10) -> np.ndarray:
    mask = image > threshold
    if np.any(mask):
        coords = np.argwhere(mask)
        y0, x0 = coords.min(axis=0)
        y1, x1 = coords.max(axis=0) + 1
        return image[y0:y1, x0:x1]
    return image
