import os
from app.config import get_settings


def ensure_artifacts_dir() -> str:
    settings = get_settings()
    os.makedirs(settings.artifacts_dir, exist_ok=True)
    return settings.artifacts_dir
