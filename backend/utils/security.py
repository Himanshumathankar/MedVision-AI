from datetime import datetime, timedelta
from typing import Any, Dict, Optional
from jose import jwt
from app.config import Settings


def create_access_token(user_id: str, settings: Settings) -> str:
    now = datetime.utcnow()
    payload = {
        "sub": user_id,
        "iss": settings.jwt_issuer,
        "aud": settings.jwt_audience,
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(minutes=settings.jwt_exp_minutes)).timestamp()),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm="HS256")


def decode_jwt(token: str, settings: Settings) -> Optional[Dict[str, Any]]:
    try:
        return jwt.decode(
            token,
            settings.jwt_secret,
            algorithms=["HS256"],
            audience=settings.jwt_audience,
            issuer=settings.jwt_issuer,
        )
    except Exception:
        return None
