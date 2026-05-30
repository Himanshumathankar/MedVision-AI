from typing import Optional, Dict
import logging
import firebase_admin
from firebase_admin import auth, credentials
from app.config import get_settings
from utils.security import create_access_token

_firebase_app = None


def _init_firebase() -> None:
    global _firebase_app
    settings = get_settings()
    if _firebase_app is None and settings.firebase_credentials_path:
        try:
            cred = credentials.Certificate(settings.firebase_credentials_path)
            _firebase_app = firebase_admin.initialize_app(
                cred,
                {"projectId": settings.firebase_project_id},
            )
            logging.info("Firebase Admin initialized for project %s", settings.firebase_project_id)
        except Exception:
            logging.exception("Failed to initialize Firebase Admin")
            _firebase_app = None


def verify_firebase_token(token: str) -> Optional[Dict[str, str]]:
    _init_firebase()
    if _firebase_app is None:
        return None
    try:
        decoded = auth.verify_id_token(token, clock_skew_seconds=60)
        return {"sub": decoded.get("uid"), "email": decoded.get("email")}
    except Exception:
        logging.exception("Failed to verify Firebase ID token")
        return None


def exchange_firebase_token(token: str) -> Optional[str]:
    settings = get_settings()
    user = verify_firebase_token(token)
    if not user:
        return None
    return create_access_token(user["sub"], settings)
