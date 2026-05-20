from typing import Optional
import base64
import os
import tempfile
import cloudinary
import cloudinary.uploader
from app.config import get_settings


def _configure_cloudinary() -> bool:
    settings = get_settings()
    if settings.cloudinary_cloud_name:
        cloudinary.config(
            cloud_name=settings.cloudinary_cloud_name,
            api_key=settings.cloudinary_api_key,
            api_secret=settings.cloudinary_api_secret,
            secure=True,
        )
        return True
    return False


def upload_base64_image(data_base64: str) -> Optional[dict]:
    if not _configure_cloudinary():
        return _save_local(base64.b64decode(data_base64.split(",")[-1]), ".png")
    if not data_base64:
        return None
    payload = data_base64.split(",")[-1]
    binary = base64.b64decode(payload)
    result = cloudinary.uploader.upload(binary, folder="medvision")
    return result


def upload_bytes_image(data: bytes, suffix: str = ".png", resource_type: str = "image") -> Optional[dict]:
    if not _configure_cloudinary():
        return _save_local(data, suffix)
    result = cloudinary.uploader.upload(data, folder="medvision", resource_type=resource_type)
    return result


def _save_local(data: bytes, suffix: str) -> dict:
    os.makedirs("./artifacts/uploads", exist_ok=True)
    fd, path = tempfile.mkstemp(suffix=suffix, dir="./artifacts/uploads")
    with os.fdopen(fd, "wb") as tmp:
        tmp.write(data)
    return {"asset_id": os.path.basename(path), "secure_url": path}
