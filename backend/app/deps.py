import logging
from fastapi import Depends, HTTPException, Request, status
from app.config import get_settings
from utils.security import decode_jwt
from services.auth import verify_firebase_token


def get_current_user(request: Request):
    settings = get_settings()
    auth_header = request.headers.get("Authorization", "")
    firebase_token = request.headers.get("X-Firebase-Token")

    if firebase_token:
        user = verify_firebase_token(firebase_token)
        if user:
            logging.info("Auth via Firebase token")
            return user
        logging.warning("Firebase token present but invalid")

    if auth_header.startswith("Bearer "):
        token = auth_header.replace("Bearer ", "", 1)
        payload = decode_jwt(token, settings)
        if payload:
            logging.info("Auth via JWT")
            return payload
        logging.warning("Bearer token present but invalid")

    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unauthorized")
